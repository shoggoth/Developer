//
//  IFInfoViewController_iPhone.h
//  WOIAF
//
//  Created by Simon Hardie on 06/11/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IFRootViewController_iPhone;

@interface IFInfoViewController_iPhone : UIViewController <UIWebViewDelegate> {
    
    __weak IBOutlet UIButton        *backgroundButton;
    __weak IBOutlet UIWebView       *webView;
}

// Operations

- (void) initialHide;

- (IBAction)hide:(id)sender;
- (IBAction)show:(id)sender;

- (IBAction)tagButtonHit:(id)sender;

// Properties
@property (weak, nonatomic) IFRootViewController_iPhone *rootViewController;


@end