//
//  IFLockViewController.h
//  WOIAF
//
//  Created by Richard Henry on 19/09/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//


@class IFRootViewController;
@class ItemBase;

@interface IFLockViewController : UIViewController {
    
    // Different kinds of lock views
    __weak IBOutlet UIView      *lockedContentView;
    __weak IBOutlet UIView      *initialContentView;
    __weak IBOutlet UIView      *spoileredContentView;
    
    // View specific outlets
    __weak IBOutlet UITextView  *lockedBookTextView;
    __weak IBOutlet UITextView  *spoilerBookTextView;
}

// Properties
@property (weak, nonatomic) IFRootViewController *rootViewController;

// Actions
- (IBAction)hide:(id)sender;
- (IBAction)show:(id)sender;

// Operations
- (BOOL)showItem:(ItemBase *)item;

@end
