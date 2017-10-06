//
//  IFMasterController.h
//  WOIAF
//
//  Created by Simon Hardie on 05/11/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IFMasterController <NSObject>

// Actions
- (IBAction)homeScreenButtonTouched:(id)sender;
- (IBAction)filterButtonTouched:(id)sender;
- (IBAction)alphaButtonTouched:(id)sender;
- (IBAction)infoButtonTouched:(id)sender;
- (IBAction)homeButtonTouched:(id)sender;

// Operations
- (IBAction)itemSelected:(id)sender;

// Home screen operations
- (void)darkenHomeScreen:(void (^)(BOOL finished))completionBlock andSearchLogo:(BOOL)searchLogoDarken;
- (void)lightenHomeScreen:(BOOL)searchLogoLighten;

- (BOOL)showLockViewControllerForItem:(id)item;

@property (assign, nonatomic) BOOL refreshNeeded;

@end
