//
//  IFItemViewController.h
//  WOIAF
//
//  Created by Richard Henry on 04/09/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//


@class IFRootViewController;
@class ItemBase;

@interface IFItemViewController : UIViewController <UIWebViewDelegate> {
    
    // Item display subviews
    __weak IBOutlet UIWebView       *webView;
    __weak IBOutlet UIView          *mapView;

    // Item control subview
    __weak IBOutlet UIView          *footerView;

    // Item control buttons
    __weak IBOutlet UIButton        *starButton;
    __weak IBOutlet UIButton        *forwardHistoryButton;
    __weak IBOutlet UIButton        *backHistoryButton;
    __weak IBOutlet UIButton        *favouritesButton;
}

@property (strong, nonatomic) ItemBase *currentItem;

@property (weak, nonatomic) IFRootViewController *rootViewController;
@property (strong, nonatomic) UIPopoverController *bookmarksPopover;

@property (strong, nonatomic) void(^completionBlock)(void);

// Actions
- (IBAction)hide:(id)sender;
- (IBAction)show:(id)sender;
- (IBAction)hideFooter:(id)sender;
- (IBAction)showFooter:(id)sender;

- (IBAction)menuBarButtonPressed:(id)sender;

- (void)showItem:(id)item;
- (void)showItem:(id)item withCompletionBlock:(void (^)())completionBlock;

- (void)showWebView:(BOOL)show;

@end
