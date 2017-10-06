//
//  IFRootViewController_iPhone.m
//  WOIAF
//
//  Created by Simon Hardie on 05/11/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import "IFRootViewController_iPhone.h"
#import "IFSpoilerViewController_iPhone.h"
#import "IFSearchViewController_iPhone.h"
#import "IFItemViewController_iPhone.h"
#import "IFInfoViewController_iPhone.h"
#import "IFLockViewController_iPhone.h"
#import "IFCoreDataStore.h"

#import "ItemBase.h"

#import <QuartzCore/QuartzCore.h>


//static const float  kIFSearchViewFrameSlopWidth = 57; // Search view controller width = 434, table view within that width = 320.

static const float kIFFilterAreaHeightOffset = 70.0f;

static NSString *kIFLaunchCountKey = @"launchCountKey";

@interface IFRootViewController_iPhone ()

- (void)startImageSwitchingAnimations;
- (void)pauseImageSwitchingAnimations;

@end

@implementation IFRootViewController_iPhone {
    
    // Search subview
    IFSearchViewController_iPhone          *searchViewController;
    
    // Item subview
    IFItemViewController_iPhone            *itemViewController;
    
    //BOOL                            stateTransition;
    
    // Spoiler subview
    IFSpoilerViewController_iPhone         *spoilerViewController;
    
    // Info subview
    IFInfoViewController_iPhone            *infoViewController;
    
    // Lock subview
    IFLockViewController_iPhone            *lockViewController;
    
    // State control
    BOOL                            itemSelectionShown;
    BOOL                            itemSelectionShowing;
    BOOL                            alphaButtonEnabled;
    
    // Animation
    NSTimer                         *switchTimer;
    
    // Search view parameters
    CGPoint                         searchViewCentrePoint;
    
    // Home screen items
    NSArray                         *homeImagesArray;
    unsigned                        homeImagesIndex;
    
    // Launch operations
    unsigned                        launchCount;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationController.delegate = self;
    
    // Initialise subviews
    [self initSubviews];
    
    // Initialise home screen image switching
    homeImagesArray = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"iphoneHomeImages" ofType:@"plist"]];
    
    // Correct the initial modulo
    homeImagesIndex = homeImagesArray.count;
    
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
    homeImagesArray = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)darkenHomeScreen:(void (^)(BOOL finished))completionBlock {
    
    //[self pauseImageSwitchingAnimations];
    
    // Root view animations
    [UIView animateWithDuration:.5
                          delay:0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{ alphaButton.alpha = 0.5; }
                     completion:^(BOOL finished){ alphaButtonEnabled = YES; completionBlock(finished); }];
}

- (void)lightenHomeScreen {
    
    [infoViewController hide:nil];
    
    [UIView animateWithDuration:.5
                          delay:0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{ alphaButton.alpha = 0; }
                     completion:^(BOOL finished) {
                         
                         alphaButtonEnabled = NO;
                         //[self startImageSwitchingAnimations];
                     }];
}

- (BOOL)showLockViewControllerForItem:(ItemBase *)item {
    
    return [lockViewController showItem:item];
}

- (IBAction)infoButtonTouched:(UIButton *)sender {
    //infoView.hidden = NO;
    [infoViewController show:nil];
}

#pragma mark - Image switching

- (void)startImageSwitchingAnimations {
    
    // Image buttons re-enable
    imageButton.enabled = YES;
    
    // Start image switch timer
    switchTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(switchImageAnimation) userInfo:nil repeats:YES];
}

- (void)switchImageAnimation {
    
    // Work out which image and view we're going too switch
    NSDictionary *homeScreenDict = [homeImagesArray objectAtIndex:homeImagesIndex++ % homeImagesArray.count];
    
    UIImage  *secondImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_iphone.png", [homeScreenDict objectForKey:@"imageName"]]];
    
    // Set the text image button
    ItemBase    *item = [[IFCoreDataStore defaultDataStore] fetchItemWithUID:[homeScreenDict objectForKey:@"itemUID"]];
    unsigned    book = [item.book intValue];
    NSString    *textString;
    BOOL        clickable = NO;
    
    if (!item || book > [IFCoreDataStore defaultDataStore].lastBookAllowed) textString = [NSString stringWithFormat:@"%@_iphone_locked.png", [homeScreenDict objectForKey:@"imageName"]];
    else if (book > [IFCoreDataStore defaultDataStore].lastBookRead) textString = [NSString stringWithFormat:@"%@_iphone_spoiler.png", [homeScreenDict objectForKey:@"imageName"]];
    else { clickable = YES; textString = [NSString stringWithFormat:@"%@_iphone_unlocked.png", [homeScreenDict objectForKey:@"imageName"]]; }
    
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
    imageButton.enabled = NO;
    
    // Pause image switching timer
    [switchTimer invalidate];
}

#pragma mark - Home screen


#pragma mark - Actions

- (void)homeScreenButtonTouched:(id)sender {
    
    NSDictionary *homeScreenDict;
    
    homeScreenDict = [homeImagesArray objectAtIndex:(homeImagesIndex - 1) % homeImagesArray.count];
    
    id item = [[IFCoreDataStore defaultDataStore] fetchItemWithUID:[homeScreenDict objectForKey:@"itemUID"]];
    
    if (item) {
        
        // If the lock screen is not needed for this item...
        if (![lockViewController showItem:item]) {
            [self itemSelected:item];
        }else{
            lockedView.hidden = NO;
        }
    }
}

- (void)filterButtonTouched:(UIButton*)sender {
    
    NSInteger newTypeFilter = sender.tag;
    
    // NSLog(@"new filter %d  old: %d rn: %d", newTypeFilter, searchViewController.typeFilter, self.refreshNeeded);
    
    if (newTypeFilter != searchViewController.typeFilter || self.refreshNeeded) {
        
        searchViewController.typeFilter = newTypeFilter;
        
        [searchViewController setFilterButtonAsSelected:sender.tag];
        
        [searchViewController reloadTableData];
        
        self.refreshNeeded = NO;
        
        //[searchViewController setSearchTerm:@"Foobar"];
    }
    
    // Sub view animations
    [spoilerViewController offscreen:sender];
    [searchViewController show:sender];
    
    // Root view animations
    if (!alphaButtonEnabled) [self darkenHomeScreen:^(BOOL finished) {fakeSearchButton.hidden = YES;}];
}

- (void)homeButtonTouched:(id)sender {
    
    // Clear history
    [[IFCoreDataStore defaultDataStore] clearHistory];
    
    // Animate subviews
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         
                         //searchViewController.view.center = searchViewCentrePoint;
                         [spoilerViewController hidden:sender];
                         [searchViewController hide:sender];
                         alphaButton.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         
                         alphaButtonEnabled = NO;
                         fakeSearchButton.hidden = NO;
                         
                         /*if (finished) {
                             
                             [UIView animateWithDuration:0.5
                                                   delay:0.1
                                                 options:UIViewAnimationCurveLinear
                                              animations:^{
                                                  
                                                  [spoilerViewController show:sender];
                                                  [searchViewController hide:sender];
                                              }
                                              completion:^(BOOL finished) {
                                                  
                                              }];
                         }*/
                     }];
}

- (void)alphaButtonTouched:(id)sender {
    
    if (!alphaButtonEnabled) return;
    
    // Sub view animations
    [spoilerViewController hidden:sender];
    [searchViewController hide:sender];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         
                         //searchViewController.view.center = searchViewCentrePoint;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)itemSelected:(ItemBase *)item {
    
    NSLog(@"Item selected: %@", item.name);
    
    self.selectedItem = item;
    if (itemViewController) {
        [itemViewController showItem:item];
    }else{
        [self performSegueWithIdentifier:@"viewItem" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"viewItem"]) {
        //IFItemViewController_iPhone *ivController = segue.destinationViewController;
        itemViewController = segue.destinationViewController;
        itemViewController.rootViewController = self;
        itemViewController.currentItem = self.selectedItem;
    }
}

#pragma mark - Subview handling

- (void)initSubviews {
    
    // Search view controller
    if (!searchViewController) {
        
        searchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"search"];
        searchViewController.rootViewController = self;
        
        // Add the view as a subview if we haven't already
        if (searchViewController.view.superview != self.view) [searchView addSubview:searchViewController.view];
        
        searchViewController.view.center = searchView.center;
        
        //[searchViewController hide:nil];
        
        [searchViewController initialHide];
    }
    
    // Spoiler view controller
    if (!spoilerViewController) {
        
        spoilerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"spoiler"];
        spoilerViewController.rootViewController = self;
        
        // Add the view as a subview if we haven't already
        if (spoilerViewController.view.superview != self.view) [spoilerView addSubview:spoilerViewController.view];
        
        spoilerViewController.view.center = spoilerView.center;
        
        //[spoilerViewController hidden:nil];
        
        [spoilerViewController initialHide];
    }
    
    // Info view controller
    if (!infoViewController) {
        
        infoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"info"];
        infoViewController.rootViewController = self;
        
        // Add the view as a subview if we haven't already
        if (infoViewController.view.superview != self.view) [infoView addSubview:infoViewController.view];
        
        infoViewController.view.center = infoView.center;
        
        [infoViewController initialHide];
    }
    
    
    // Lock view controller
    if (!lockViewController) {
        
        lockViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"lock"];
        lockViewController.rootViewController = self;
        
        // Add the view as a subview if we haven't already
        if (lockViewController.view.superview != self.view) [self.view addSubview:lockViewController.view];
        
        lockViewController.view.center = lockedView.center;
    }
     
}

- (void)showInfoViewController:(id)sender {
    //infoView.hidden = NO;
    [infoViewController show:nil];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (viewController == self) {
        // poping back from itemView so..
        itemViewController = nil;
    }
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

@end
