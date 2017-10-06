//
//  IFMapViewController_iPhone.m
//  WOIAF
//
//  Created by Simon Hardie on 06/11/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import "IFMapViewController_iPhone.h"
#import "IFRootViewController_iPhone.h"
#import "IFCoreDataStore.h"
#import "IFTableViewCell.h"
#import "IFPin.h"

#import "IFLockViewController_iPhone.h"

#import "ItemBase.h"
#import "MapLocation.h"
#import "Place.h"
#import "Map.h"

#import "ItemBase+LockState.h"

#import <QuartzCore/QuartzCore.h>

@interface IFMapViewController_iPhone ()

@end

@implementation IFMapViewController_iPhone {
    
    // Pin management
    NSMutableSet                *recycledPins;
    IFPinView                   *pinWithBannerShown;
    
    // World parameters
    CGSize                      worldSize;                  // Overall size of the world, in "world units"
	CGFloat                     worldScale;                 // Scales world units to pixels
    
    // Pin storage
    NSMutableArray              *allPins;
    NSMutableArray              *groupedPins;
    
    // Multi-pin
    IFPinGroup                  *multipleItem;
    
    // Lock subview
    IFLockViewController_iPhone         *lockViewController;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Lock view controller

    if (!lockViewController) {
        
        lockViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"lock"];
        lockViewController.rootViewController = self.rootViewController;
        
        // Add the view as a subview if we haven't already
        if (lockViewController.view.superview != self.view) [self.view addSubview:lockViewController.view];
        
        lockViewController.view.center = lockedView.center;
    }
    
    // Pin recycling setup
    recycledPins = [NSMutableSet new];
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    
    // Recycle all pins…
    for (IFPinView *pinView in mapView.subviews) [self recyclePin:pinView];
    
    // Release recycled pins.
    recycledPins = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Actions

- (IBAction)hideMultipinOverlay:(id)sender {
    
    multiLocationView.hidden = YES;
}

#pragma mark - Pin view handling

- (IFPinView *)addPinViewAtLocation:(id <IFPin>)mapLocation {
    
    IFPinView   *pinView;
    CGPoint     pinPoint;
    
    BOOL multiple = isPinMultiple(mapLocation);
    
    // Align to 2-pixel if this isn't a retina device (min. zoom value = 0.5)
    if ([UIScreen mainScreen].scale < 2.0) {
        
        int x = (int)(self.mapOrigin.x + (mapLocation.pos.x));
        int y = (int)(self.mapOrigin.y + (mapLocation.pos.y));
        
        if (x % 2) x++;
        if (y % 2) y++;
        
        pinPoint.x = x;
        pinPoint.y = y;
        
    } else
        pinPoint = CGPointMake(roundf(self.mapOrigin.x + mapLocation.pos.x), roundf(self.mapOrigin.y + mapLocation.pos.y));
    
    
    // Recycle a view if possible
    if (recycledPins.count) {
        
        pinView = [recycledPins anyObject];
        [recycledPins removeObject:pinView];
        
    } else pinView = [[[NSBundle mainBundle] loadNibNamed:@"Pin" owner:self options:nil] objectAtIndex:0];
    
    // Set pinview parameters
    pinView.hidden = NO;
    [CATransaction setDisableActions:YES];
    pinView.center = pinPoint;
    [CATransaction setDisableActions:NO];
    pinView.transform = CGAffineTransformMakeScale(worldScale, worldScale);
    
    pinView.delegate = self;
    pinView.location = mapLocation;
    
    if (multiple) {
        
        IFPinGroup *group = mapLocation;
        [pinView setMultiLocation:group.pins.count];
        
    } else {
        
        IFPin *pin = mapLocation;
        [pinView setSingleLocation:pin.location.place.name];
    }
    
    // Add it to the map view
    [mapView addSubview:pinView];
    
    return pinView;
}


- (void)recyclePin:(IFPinView *)pinView {
    
    [recycledPins addObject:pinView];
    
    [pinView recycle];
}

#pragma mark - Item loading

- (void)loadMap:(Map *)map {
    
    //static CGPoint iPhoneScaleFactor = {0.26644370122631, 0.26644370122631};
    static CGPoint iPhoneScaleFactor = {0.25, 0.25};
    //static CGPoint iPhoneScaleFactor = {0.5, 0.5};
    
    // Clean up after possible previous
    [self hideMultipinOverlay:nil];
    
    // Set the correct map offset
    //self.mapOrigin = CGPointMake(77, 120);
    self.mapOrigin = CGPointMake(90, 125);
    
    //mapView.image = [UIImage imageNamed:[NSString stringWithFormat:@"iphone_map_%@.png", map.uid]];
    mapView.image = [UIImage imageNamed:[NSString stringWithFormat:@"map_%@.png", map.uid]];
    
    // Recycle all pins…
    for (IFPinView *pinView in mapView.subviews) [self recyclePin:pinView];
    
    // Add all un-spoilered pins locations
    allPins = [NSMutableArray array];
    groupedPins = [NSMutableArray array];
    
    for (MapLocation *mapLocation in map.mapLocations) {
        
        if (mapLocation.book.intValue <= [IFCoreDataStore defaultDataStore].lastBookRead) {
            
            IFPin *pin = [IFPin new];
            
            pin.pos = CGPointMake(mapLocation.x.floatValue * iPhoneScaleFactor.x, mapLocation.y.floatValue * iPhoneScaleFactor.y);
            pin.location = mapLocation;
            
            [allPins addObject:pin];
        }
    }
    
    // Sort the 'app pins' array of pins in x sub y order
    [allPins sortUsingComparator:^NSComparisonResult(IFPin *obj1, IFPin *obj2) {
        
        if (obj1.pos.x > obj2.pos.x) return NSOrderedDescending;                // x1 > x2
        
        else if (obj1.pos.x == obj2.pos.x) {                                    // x1 = x2
            
            if (obj1.pos.y > obj2.pos.y) return NSOrderedDescending;            // y1 > y2
            else if (obj1.pos.y == obj2.pos.y) return NSOrderedSame;            // y1 = y2
            else return NSOrderedAscending;                                     // y1 < y2
            
        } else return NSOrderedAscending;                                       // x1 < x2
    }];
    
    // Set up world parameters
    scrollView.zoomScale = 0.5;
    worldSize = mapView.bounds.size;
    worldScale = 1.0 / scrollView.zoomScale;
    
    [self doPinGrouping];
    [self placeGroupedPins];
}

- (void)doPinGrouping {
    
    const float xThreshold = 23.0 / scrollView.zoomScale;
    const float yThreshold = 23.0 / scrollView.zoomScale;
    
    //NSLog(@"Group compare x = %f y = %f", xThreshold, yThreshold);
    
    [groupedPins removeAllObjects];
    
    NSMutableArray *ungroupedPins = [allPins mutableCopy];
    
    // Group the pins together
    for (;ungroupedPins.count;) {
        
        NSMutableArray  *group = [NSMutableArray array];
        IFPin           *groupPin = [ungroupedPins objectAtIndex:0];
        
        //NSLog(@"Group compare pin = %@", groupPin);
        
        for (IFPin *pin in ungroupedPins) {
            
            if (pin.pos.x - groupPin.pos.x > xThreshold) break;
            
            if (fabs(pin.pos.y - groupPin.pos.y) > yThreshold) continue;
            
            [group addObject:pin];
            //NSLog(@"Group add pin = %@", pin);
        }
        
        [ungroupedPins removeObjectsInArray:group];
        
        // See if the group has multiple points in it
        if (group.count > 1) {
            
            IFPinGroup *pinGroup = [IFPinGroup new];
            pinGroup.pins = group;
            
            [pinGroup recalculateAveragePosition];
            
            [groupedPins addObject:pinGroup];
            
        } else {
            
            [groupedPins addObject:groupPin];
        }
    }
}

- (void)placeGroupedPins {
    
    pinWithBannerShown = nil;
    for (IFPinView *pinView in mapView.subviews) [self recyclePin:pinView];
    for (id <IFPin> pin in groupedPins) [self addPinViewAtLocation:pin];
}

#pragma mark IFPinViewDelegate conformance

- (void)clickedPinView:(IFPinView *)pinView {
    
    BOOL multiple = ([pinView.location isKindOfClass:[IFPinGroup class]]);
    
    if (!multiple) {
        
        IFPin *pin = pinView.location;
        
        // Get the referenced place and display it
        ItemBase *item = pin.location.place;
        [self.rootViewController itemSelected:item];
        
        // Add the item to the history
        [[IFCoreDataStore defaultDataStore] addItemToHistory:item];
        
    } else {
        
        multipleItem = pinView.location;
        
        [tableView reloadData];
        multiLocationView.hidden = NO;
    }
}

- (void)toggledBannerView:(UIView *)bannerView inPinView:(IFPinView *)pinView {
    
    if (!bannerView.hidden) {
        
        if (pinView != pinWithBannerShown) {
            
            [pinWithBannerShown toggleBannerView:self];
            
            pinWithBannerShown = pinView;
        }
        
        // Bring this view to the front
        [mapView bringSubviewToFront:pinView];
        
    } else if (pinView == pinWithBannerShown) pinWithBannerShown = nil;
}

#pragma mark - UIScrollViewDelegate conformance

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    // We want the map view to zoom
    return mapView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)sv withView:(UIView *)view atScale:(float)scale {
    
    [self scrollViewDidScroll:sv];
}

- (void)scrollViewDidZoom:(UIScrollView *)sv {
    
    //CGFloat lastWorldScale = worldScale;
    worldScale = 1.0 / sv.zoomScale;
    
    [self doPinGrouping];
    [self placeGroupedPins];
}

- (void)scrollViewDidScroll:(UIScrollView *)sv {
    
    // Current viewport
    CGRect viewport = [mapView convertRect:scrollView.bounds fromView:scrollView];
    
	// Cull pin points
    for (IFPinView *pinView in mapView.subviews) {
        
        CGRect cullFrame = CGRectInset(pinView.frame, 0, 0);
        pinView.hidden = !CGRectIntersectsRect(viewport, cullFrame);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return multipleItem.pins.count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifiers[] = { @"IFTableViewCell-1", @"IFTableViewCell-2", @"IFTableViewCell-3", @"IFTableViewCell-4" };
    
    IFTableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cellIdentifiers[indexPath.row % 4]];
    if (!cell) cell = [[IFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifiers[indexPath.row % 4]];
    IFPin *pin = [multipleItem.pins objectAtIndex:indexPath.row];
    ItemBase *itemBase = pin.location.place;
    cell.textLabel.text = itemBase.name;
    
    UIImage *thumbImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_tumbnail.png", itemBase.uid]];
    
    // If there's no thumbnail image associated with the item's uid, bung in a default…
    if (!thumbImage) thumbImage = getDefaultThumbImageForItem(itemBase);
    
    cell.imageView.image = thumbImage;
    
    NSString *cellBackgroundImageName;
    
    if (itemBase.isPurchaseLocked) cellBackgroundImageName = @"_lock";
    else if (itemBase.isSpoilerLocked) cellBackgroundImageName = @"_spoiler";
    else cellBackgroundImageName = @"_arrow";
    
    ((UIImageView *)cell.backgroundView).image = [UIImage imageNamed:[NSString stringWithFormat:@"iphone_listbackground%@_%d.png", cellBackgroundImageName, cell.tag]];
    
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Immediately deselect the selected row
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    IFPin *pin = [multipleItem.pins objectAtIndex:indexPath.row];
    ItemBase *item = pin.location.place;
    if (![lockViewController showItem:item]) {
        
        // Inform the root VC that an item's been selected from the list
        [self.rootViewController itemSelected:item];
        
        // Add the item to the history
        [[IFCoreDataStore defaultDataStore] addItemToHistory:item];
    }
    else [self.parentViewController dismissModalViewControllerAnimated:NO];
}

@end
