//
//  IFInfoViewController.h
//  WOIAF
//
//  Created by Richard Henry on 19/09/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//


@class IFRootViewController;

@interface IFInfoViewController : UIViewController <UIWebViewDelegate> {
    
    __weak IBOutlet UIButton        *backgroundButton;
    __weak IBOutlet UIWebView       *webView;
}

// Actions
- (IBAction)hide:(id)sender;
- (IBAction)show:(id)sender;

- (IBAction)tagButtonHit:(id)sender;

// Properties
@property (weak, nonatomic) IFRootViewController *rootViewController;

@end
