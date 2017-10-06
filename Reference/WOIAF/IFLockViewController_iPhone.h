//
//  IFLockViewController_iPhone.h
//  WOIAF
//
//  Created by Simon Hardie on 06/11/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IFRootViewController_iPhone;
@class ItemBase;

@interface IFLockViewController_iPhone : UIViewController {
    
    __weak IBOutlet UIView      *lockedContentView;
    __weak IBOutlet UIView      *initialContentView;
    __weak IBOutlet UIView      *spoileredContentView;
    
    // View specific outlets
    __weak IBOutlet UITextView  *lockedBookTextView;
    __weak IBOutlet UITextView  *spoilerBookTextView;
}

// Properties
@property (weak, nonatomic) IFRootViewController_iPhone *rootViewController;

// Actions
- (IBAction)hide:(id)sender;
- (IBAction)show:(id)sender;

// Operations
- (BOOL)showItem:(ItemBase *)item;

@end
