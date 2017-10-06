//
//  IFRootViewController.h
//  WOIAF
//
//  Created by Richard Henry on 04/09/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//


@interface IFRootViewController : UIViewController {
    
    __weak IBOutlet UIButton        *alphaButton;
    
    __weak IBOutlet UIImageView     *leftImageView;
    __weak IBOutlet UIButton        *leftImageButton;
    __weak IBOutlet UIImageView     *rightImageView;
    __weak IBOutlet UIButton        *rightImageButton;
}

// Actions
- (IBAction)homeScreenButtonTouched:(id)sender;
- (IBAction)filterButtonTouched:(id)sender;
- (IBAction)alphaButtonTouched:(id)sender;
- (IBAction)homeButtonTouched:(id)sender;

// Operations
- (IBAction)itemSelected:(id)sender;

// Home screen operations
- (void)darkenHomeScreen:(void (^)(BOOL finished))completionBlock andSearchLogo:(BOOL)searchLogoDarken;
- (void)lightenHomeScreen:(BOOL)searchLogoLighten;

- (BOOL)showLockViewControllerForItem:(id)item;
- (void)showInfoViewController:(id)sender;

@property (assign, nonatomic) BOOL refreshNeeded;

@end
