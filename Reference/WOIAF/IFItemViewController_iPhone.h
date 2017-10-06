//
//  IFItemViewController_iPhone.h
//  WOIAF
//
//  Created by Simon Hardie on 06/11/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IFRootViewController_iPhone;
@class ItemBase;

@interface IFItemViewController_iPhone : UIViewController <UIWebViewDelegate> {
    
    // Item display subviews
    __weak IBOutlet UIWebView       *webView;
    __weak IBOutlet UIView          *mapView;
    __weak IBOutlet UIView          *bookmarkView;
    __weak IBOutlet UIView          *lockedView;
    
    // Item control subview
    __weak IBOutlet UIView          *footerView;
    
    // Item control buttons
    __weak IBOutlet UIButton        *searchButton;
    __weak IBOutlet UIButton        *starButton;
    __weak IBOutlet UIButton        *forwardHistoryButton;
    __weak IBOutlet UIButton        *backHistoryButton;
    __weak IBOutlet UIButton        *favouritesButton;
}

@property (strong, nonatomic) ItemBase *currentItem;

@property (weak, nonatomic) IFRootViewController_iPhone *rootViewController;
//@property (strong, nonatomic) UIPopoverController *bookmarksPopover;

@property (strong, nonatomic) void(^completionBlock)(void);

// Actions
//- (IBAction)hide:(id)sender;
//- (IBAction)show:(id)sender;
//- (IBAction)hideFooter:(id)sender;
//- (IBAction)showFooter:(id)sender;

//- (IBAction)menuBarButtonPressed:(id)sender;

- (void)showItem:(id)item;
- (void)showItem:(id)item withCompletionBlock:(void (^)())completionBlock;

- (void)showWebView:(BOOL)show;
- (void)hideBoomarkView;

- (IBAction) returnToMainMenu:(id)sender;
- (IBAction) starButtonTouched:(id)sender;
- (IBAction) favouritesButtonTouched:(id)sender;
- (IBAction) backHistoryButtonTouched:(id)sender;
- (IBAction) forwardHistoryButtonTouched:(id)sender;

@end