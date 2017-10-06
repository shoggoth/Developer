//
//  IFRootViewController_iPhone.h
//  WOIAF
//
//  Created by Simon Hardie on 05/11/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

@class ItemBase;

@interface IFRootViewController_iPhone : UIViewController <UINavigationControllerDelegate> {
    
    __weak IBOutlet UIButton        *alphaButton;
    
    __weak IBOutlet UIImageView     *imageView;
    __weak IBOutlet UIButton        *imageButton;
    __weak IBOutlet UIButton        *infoButton;
    
    __weak IBOutlet UIButton        *fakeSearchButton;
    
    __weak IBOutlet UIView *searchView;
    __weak IBOutlet UIView *spoilerView;
    __weak IBOutlet UIView *infoView;
    __weak IBOutlet UIView *lockedView;
}

// Actions
- (IBAction)homeScreenButtonTouched:(id)sender;
- (IBAction)filterButtonTouched:(id)sender;
- (IBAction)alphaButtonTouched:(id)sender;
- (IBAction)homeButtonTouched:(id)sender;

- (IBAction)infoButtonTouched:(UIButton *)sender;

// Operations
- (IBAction)itemSelected:(id)sender;

- (void)darkenHomeScreen:(void (^)(BOOL finished))completionBlock;
- (void)lightenHomeScreen;

- (BOOL)showLockViewControllerForItem:(id)item;
- (void)showInfoViewController:(id)sender;

@property (assign, nonatomic) BOOL refreshNeeded;

@property (strong, nonatomic) ItemBase* selectedItem;

@end