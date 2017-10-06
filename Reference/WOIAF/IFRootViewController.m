//
//  IFRootViewController.m
//  WOIAF
//
//  Created by Richard Henry on 04/09/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import "IFRootViewController.h"
#import "IFSpoilerViewController.h"
#import "IFSearchViewController.h"
#import "IFItemViewController.h"
#import "IFInfoViewController.h"
#import "IFLockViewController.h"
#import "IFCoreDataStore.h"

#import "ItemBase.h"

#import <QuartzCore/QuartzCore.h>

static const float  kIFSearchViewFrameSlopWidth = 57; // Search view controller width = 434, table view within that width = 320.

static NSString *kIFLaunchCountKey = @"launchCountKey";


@interface IFRootViewController ()

- (void)startImageSwitchingAnimations;
- (void)pauseImageSwitchingAnimations;

@end

@implementation IFRootViewController {
    
    BOOL                            iPhone;
    
    // Search subview
    IFSearchViewController          *searchViewController;
    
    // Item subview
    IFItemViewController            *itemViewController;
    CGPoint                         itemViewHiddenCentre;
    CGPoint                         itemViewHalfHiddenCentre;
    CGPoint                         itemViewShownCentre;
    enum { hidden, shown, half }    itemViewState;
    BOOL                            stateTransition;
    
    // Spoiler subview
    IFSpoilerViewController         *spoilerViewController;
    
    // Info subview
    IFInfoViewController            *infoViewController;
    
    // Lock subview
    IFLockViewController            *lockViewController;
    
    // State control
    BOOL                            itemSelectionShown;
    BOOL                            itemSelectionShowing;
    BOOL                            alphaButtonEnabled;
    
    // Animation
    NSTimer                         *switchTimer;
    BOOL                            switchLeftImage;
    
    // Search view parameters
    CGPoint                         searchViewCentrePoint;
    CGPoint                         searchViewLeftPoint;
    
    // Home screen items
    NSArray                         *leftHomeItemsArray;
    NSArray                         *rightHomeItemsArray;
    unsigned                        leftImageIndex, rightImageIndex;
    
    // Launch operations
    unsigned                        launchCount;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Are we on an iPhone?
    iPhone = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
    
    // Initialise subviews
    [self initSubviews];
    itemViewState = hidden;
    
    // Initialise home screen image switching
    leftHomeItemsArray = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LeftImages" ofType:@"plist"]];
    rightHomeItemsArray = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RightImages" ofType:@"plist"]];

    // Correct the initial modulo
    leftImageIndex = leftHomeItemsArray.count;
    rightImageIndex = rightHomeItemsArray.count;
    
    // Start image animation switching
    [self switchImageAnimation];
    [self startImageSwitchingAnimations];
    
    // Load and increment launch counter
    launchCount = [[NSUserDefaults standardUserDefaults] integerForKey:kIFLaunchCountKey];
    [[NSUserDefaults standardUserDefaults] setInteger:launchCount + 1 forKey:kIFLaunchCountKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (!launchCount) [lockViewController showItem:nil];
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    
    [self pauseImageSwitchingAnimations];
    
    // Release any retained subviews of the main view.
    spoilerViewController = nil;
    searchViewController  = nil;
    
    // Remove storage
    leftHomeItemsArray = rightHomeItemsArray = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (iPhone) ? (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown) : (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
#pragma mark - Home screen interface

- (void)darkenHomeScreen:(void (^)(BOOL finished))completionBlock andSearchLogo:(BOOL)searchLogoDarken {
    
    [self pauseImageSwitchingAnimations];
    
    if (searchLogoDarken) searchViewController.view.userInteractionEnabled = NO;
    
    // Root view animations
    [UIView animateWithDuration:.5
                          delay:0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{ alphaButton.alpha = 0.5; if (searchLogoDarken) { searchViewController.view.alpha = 0; }}
                     completion:^(BOOL finished){ alphaButtonEnabled = YES; completionBlock(finished); }];
}

- (void)lightenHomeScreen:(BOOL)searchLogoLighten {
    
    [UIView animateWithDuration:.5
                          delay:0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{ alphaButton.alpha = 0; if (searchLogoLighten) { searchViewController.view.alpha = 1; } }
                     completion:^(BOOL finished) {
                         
                         alphaButtonEnabled = NO;
                         if (searchLogoLighten) searchViewController.view.userInteractionEnabled = YES;
                         
                         [self startImageSwitchingAnimations];
                     }];
}

- (BOOL)showLockViewControllerForItem:(ItemBase *)item {
        
    return [lockViewController showItem:item];
}

#pragma mark - Actions

- (void)homeScreenButtonTouched:(UIButton *)sender {
    
    NSDictionary *homeScreenDict;
    
    if (!sender.tag) {
        
        // Left item was clicked
        homeScreenDict = [leftHomeItemsArray objectAtIndex:(leftImageIndex - 1) % leftHomeItemsArray.count];
    
    } else {
        
        // Right item was clicked
        homeScreenDict = [rightHomeItemsArray objectAtIndex:(rightImageIndex - 1) % rightHomeItemsArray.count];
    }
    
    id item = [[IFCoreDataStore defaultDataStore] fetchItemWithUID:[homeScreenDict objectForKey:@"itemUID"]];
    
    if (item) {
        
        // If the lock screen is not needed for this item...
        if (![lockViewController showItem:item]) {
            
            [self itemSelected:item];
            
            [itemViewController showWebView:NO];
            
            searchViewController.typeFilter = 0;
            [searchViewController reloadTableData];
            
            // Sub view animations
            [spoilerViewController hide:sender];
            [searchViewController show:sender];
            
            // Root view animations
            [self darkenHomeScreen:^(BOOL finished) {} andSearchLogo:NO];
        }
    }
}

- (void)filterButtonTouched:(UIButton *)sender {
    
    NSInteger newTypeFilter = sender.tag;
    
    if (newTypeFilter != searchViewController.typeFilter || self.refreshNeeded) {
        
        searchViewController.typeFilter = newTypeFilter;
        
        [searchViewController setFilterButtonAsSelected:sender.tag];
        
        [searchViewController saveFilterSearchTerm];

        [searchViewController reloadTableData];
        
        self.refreshNeeded = NO;
    }
    
    // Sub view animations
    [spoilerViewController hide:sender];
    [searchViewController show:sender];
    
    // Root view animations
    if (!alphaButtonEnabled) [self darkenHomeScreen:^(BOOL finished) {} andSearchLogo:NO];
}

- (void)homeButtonTouched:(UIButton *)sender {
    
    // Clear history
    [[IFCoreDataStore defaultDataStore] clearHistory];
    
    // Clear search terms
    [searchViewController clearFilterSearchTerms];
    
    // Animate subviews
    [itemViewController hideFooter:nil];
    [searchViewController hideFooter:nil];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         
                         itemViewController.view.center = itemViewHalfHiddenCentre;
                         searchViewController.view.center = searchViewCentrePoint;
                     }
                     completion:^(BOOL finished) {
                         
                         if (finished) {
                             
                             [UIView animateWithDuration:0.5
                                                   delay:0.1
                                                 options:UIViewAnimationCurveLinear
                                              animations:^{
                                                  
                                                  itemViewController.view.center = itemViewHiddenCentre;
                                                  
                                                  [spoilerViewController show:sender];
                                                  [searchViewController hide:sender];
                                              }
                                              completion:^(BOOL finished) {
                                                  
                                                  itemViewController.view.hidden = YES;
                                                  itemSelectionShown = NO;
                                              }];
                         }
                     }];
}

- (void)alphaButtonTouched:(UIButton *)sender {
    
    if (!alphaButtonEnabled) return;
    
    // Clear search terms
    [searchViewController clearFilterSearchTerms];
    
    // Sub view animations
    [spoilerViewController show:sender];
    [searchViewController hide:sender];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         
                         itemViewController.view.center = itemViewHiddenCentre;
                         searchViewController.view.center = searchViewCentrePoint;
                     }
                     completion:^(BOOL finished) {
                         
                         itemViewController.view.hidden = YES;
                     }];
}

- (void)itemSelected:(ItemBase *)item {
    
    if (itemSelectionShowing) return;
     
    
    // Show the selected data item
    [itemViewController showItem:item withCompletionBlock:^{
        
        // Animate in the item controller if it's not already shown
        if (!itemSelectionShown) {
            
            alphaButtonEnabled = NO;
            itemSelectionShowing = YES;
            
            [UIView animateWithDuration:0.5
                                  delay:0
                                options:UIViewAnimationCurveLinear
                             animations:^{
                                 
                                 itemViewController.view.hidden = NO;
                                 itemViewController.view.center = itemViewHalfHiddenCentre;
                                 
                                 [itemViewController showWebView:NO];
                             }
                             completion:^(BOOL finished) {
                                 
                                 [itemViewController showFooter:nil];
                                 [searchViewController showFooter:nil];
                                 
                                 if (finished) [UIView animateWithDuration:0.5
                                                                     delay:0.1
                                                                   options:UIViewAnimationCurveLinear
                                                                animations:^{
                                                                    
                                                                    itemViewController.view.center = itemViewShownCentre;
                                                                    searchViewController.view.center = searchViewLeftPoint;
                                                                }
                                                                completion:^(BOOL finished) {
                                                                    
                                                                    itemSelectionShowing = NO;
                                                                    itemSelectionShown = YES;
                                                                    
                                                                    [itemViewController showWebView:YES];
                                                                }];
                             }];
        }}];
}

#pragma mark - Interface

- (void)showInfoViewController:(UIButton *)sender {
    
    [infoViewController show:nil];
}

#pragma mark - Subview handling

- (void)initSubviews {
    
    // Search view controller
    if (!searchViewController) {
        
        searchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"search"];
        searchViewController.rootViewController = self;
        
        // Add the view as a subview if we haven't already
        if (searchViewController.view.superview != self.view) [self.view addSubview:searchViewController.view];
        
        searchViewCentrePoint = searchViewLeftPoint = searchViewController.view.center;
        searchViewLeftPoint.x = searchViewController.view.frame.size.width * 0.5 - kIFSearchViewFrameSlopWidth;
    }
    
    // Spoiler view controller
    if (!spoilerViewController) {
        
        spoilerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"spoiler"];
        spoilerViewController.rootViewController = self;
        
        // Add the view as a subview if we haven't already
        if (spoilerViewController.view.superview != self.view) [self.view addSubview:spoilerViewController.view];
    }
    
    // Item view controller
    if (!itemViewController) {
        
        itemViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"item"];
        itemViewController.rootViewController = self;
        
        // Set up frame animations for the item view
        const CGRect rootViewFrame = self.view.frame;
        const CGRect itemViewFrame = itemViewController.view.frame;
        const CGRect searchViewFrame = searchViewController.view.frame;
        
        itemViewHiddenCentre = itemViewHalfHiddenCentre = itemViewShownCentre = itemViewController.view.center;
        
        //itemViewHalfHiddenCentre.x = (searchViewFrame.origin.x + searchViewFrame.size.width - kIFSearchViewFrameSlopWidth);
        itemViewHalfHiddenCentre.x = (searchViewFrame.size.width * 0.5 + rootViewFrame.size.width * 0.5 + itemViewFrame.size.width * 0.5) - kIFSearchViewFrameSlopWidth;
        itemViewShownCentre.x = (searchViewFrame.size.width - (kIFSearchViewFrameSlopWidth * 2)) + itemViewFrame.size.width * 0.5;
        
        itemViewController.view.center = itemViewHiddenCentre;
        
        // Add the view as a subview if we haven't already
        if (itemViewController.view.superview != self.view) [self.view addSubview:itemViewController.view];
    }
    
    // Info view controller
    if (!infoViewController) {
        
        infoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"info"];
        infoViewController.rootViewController = self;
        
        // Add the view as a subview if we haven't already
        if (infoViewController.view.superview != self.view) [self.view addSubview:infoViewController.view];
    }
    
    // Lock view controller
    if (!lockViewController) {
        
        lockViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"lock"];
        lockViewController.rootViewController = self;
        
        // Add the view as a subview if we haven't already
        if (lockViewController.view.superview != self.view) [self.view addSubview:lockViewController.view];
    }
}

#pragma mark - Image switching

- (void)startImageSwitchingAnimations {
    
    // Image buttons re-enable
    leftImageButton.enabled = YES;
    rightImageButton.enabled = YES;
    
    // Start image switch timer
    switchTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(switchImageAnimation) userInfo:nil repeats:YES];
}

- (void)switchImageAnimation {
    
    switchLeftImage ^= YES;
    UIImageView *imageView = (switchLeftImage) ? leftImageView : rightImageView;
    UIButton *imageButton = (switchLeftImage) ? leftImageButton : rightImageButton;
    
    // Work out which image and view we're going too switch
    NSDictionary *homeScreenDict;
    if (switchLeftImage)
        homeScreenDict = [leftHomeItemsArray objectAtIndex:leftImageIndex++ % leftHomeItemsArray.count];
    else
        homeScreenDict = [rightHomeItemsArray objectAtIndex:rightImageIndex++ % rightHomeItemsArray.count];
    
    UIImage  *secondImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_homescreen.png", [homeScreenDict objectForKey:@"imageName"]]];
    
    // Set the text image button
    ItemBase    *item = [[IFCoreDataStore defaultDataStore] fetchItemWithUID:[homeScreenDict objectForKey:@"itemUID"]];
    unsigned    book = [item.book intValue];
    BOOL        clickable = NO;
    NSString    *textString;
    
//    if (!item || book > [IFCoreDataStore defaultDataStore].lastBookAllowed) textString = @"locked_text.png";
//    else if (book > [IFCoreDataStore defaultDataStore].lastBookRead) textString = @"spoiler_text.png";
//    else { clickable = YES; textString = [NSString stringWithFormat:@"%@_text.png", [homeScreenDict objectForKey:@"imageName"]]; }
    
    if (!item || book > [IFCoreDataStore defaultDataStore].lastBookAllowed) textString = [NSString stringWithFormat:@"%@_locked.png", [homeScreenDict objectForKey:@"imageName"]];
    else if (book > [IFCoreDataStore defaultDataStore].lastBookRead) textString = [NSString stringWithFormat:@"%@_spoil.png", [homeScreenDict objectForKey:@"imageName"]];
    else { clickable = YES; textString = [NSString stringWithFormat:@"%@_text.png", [homeScreenDict objectForKey:@"imageName"]]; }
    
    UIImage  *textImage = [UIImage imageNamed:textString];
    
    [imageButton setImage:textImage forState:UIControlStateNormal];
    imageButton.userInteractionEnabled = YES;
    
    // Set up the image animation
    [CATransaction begin];
    CABasicAnimation *imageCrossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
    imageCrossFade.duration = 3.0;
    imageCrossFade.toValue = (__bridge id)(secondImage.CGImage);
    imageCrossFade.fillMode = kCAFillModeForwards;
    imageCrossFade.removedOnCompletion = NO;
    
    // Switch the image permanently once the animation is finished…
    [CATransaction setCompletionBlock:^{ imageView.image = secondImage; }];
    
    // Perform the animation
    [imageView.layer addAnimation:imageCrossFade forKey:@"animateContents"];
    [CATransaction commit];
}

- (void)pauseImageSwitchingAnimations {
    
    // Image buttons disable
    leftImageButton.enabled = NO;
    rightImageButton.enabled = NO;
    
    // Pause image switching timer
    [switchTimer invalidate];
}

@end
