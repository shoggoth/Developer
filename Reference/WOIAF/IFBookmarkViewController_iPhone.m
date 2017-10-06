//
//  IFBookmarkViewController_iPhone.m
//  WOIAF
//
//  Created by Simon Hardie on 06/11/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import "IFBookmarkViewController_iPhone.h"
#import "IFRootViewController_iPhone.h"
#import "IFTableViewCell.h"
#import "IFCoreDataStore.h"
#import "ItemBase.h"
#import "IFLockViewController_iPhone.h"
#import "IFItemViewController_iPhone.h"

#import "ItemBase+LockState.h"


static NSString *kIFBookmarkKey = @"BookmarksKey";

@interface IFBookmarkViewController_iPhone ()

@end

@implementation IFBookmarkViewController_iPhone {
    
    NSMutableArray      *bookmarks;
    
    // Lock subview
    IFLockViewController_iPhone         *lockViewController;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if ((self = [super initWithCoder:aDecoder])) {
        
        bookmarks = [NSMutableArray new];
    }
    
    return self;
}

- (void)dealloc {
    
    bookmarks = nil;
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
	return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Operations

- (IBAction)closeBookmarks:(id)sender {
    [self.itemViewController hideBoomarkView];
}

- (void)loadSavedBookmarks {
    
    NSArray *savedBookmarkUIDs = [[NSUserDefaults standardUserDefaults] objectForKey:kIFBookmarkKey];
    
    for (NSString *uid in savedBookmarkUIDs) {
        
        ItemBase *item = [[IFCoreDataStore defaultDataStore] fetchItemWithUID:uid];
        
        if (item) [bookmarks addObject:item];
    }
    
}
- (BOOL)itemIsBookmarked:(ItemBase *)item {
    
    return ([bookmarks containsObject:item]);
}

- (BOOL)bookmarkItem:(ItemBase *)item {
    
    if ([self itemIsBookmarked:item]) return NO;
    
    [bookmarks addObject:item];
    [tableView reloadData];
    
    [self saveUserDefaults];
    
    return YES;
}

- (BOOL)removeBookmarkForItem:(ItemBase *)item {
    
    if (![self itemIsBookmarked:item]) return NO;
    
    [bookmarks removeObject:item];
    [tableView reloadData];
    
    [self saveUserDefaults];
    
    return YES;
}

- (void)saveUserDefaults {
    
    NSMutableArray *uidArray = [NSMutableArray new];
    
    for (ItemBase *item in bookmarks) [uidArray addObject:item.uid];
    
    [[NSUserDefaults standardUserDefaults] setObject:uidArray forKey:kIFBookmarkKey];
}

- (NSUInteger)bookmarkCount { return bookmarks.count; }

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return bookmarks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifiers[] = { @"IFTableViewCell-1", @"IFTableViewCell-2", @"IFTableViewCell-3", @"IFTableViewCell-4" };
    
    IFTableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cellIdentifiers[indexPath.row % 4]];
    if (!cell) cell = [[IFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifiers[indexPath.row % 4]];
    ItemBase *itemBase = [bookmarks objectAtIndex:indexPath.row];
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
    
    ItemBase *item = [bookmarks objectAtIndex:indexPath.row];
    if (![lockViewController showItem:item]) {
        
        //[self.parentPopover dismissPopoverAnimated:YES];
        
        // Inform the root VC that an item's been selected from the list
        [self.rootViewController itemSelected:item];
    }
    else [self.parentViewController dismissModalViewControllerAnimated:NO];
}

#pragma mark - Refreshing

- (void)reloadBookmarks { [tableView reloadData]; }

@end