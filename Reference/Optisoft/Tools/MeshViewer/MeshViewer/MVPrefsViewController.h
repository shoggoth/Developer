//
//  MVPrefsViewController.h
//  MeshViewer
//
//  Created by Richard Henry on 25/07/2014.
//  Copyright (c) 2014 Dogstar Industries. All rights reserved.
//

@import UIKit;

#import "DSDrawContext.h"

@class MVPrefsViewController;

@protocol MVPrefsDelegate <NSObject>

- (void)setupPreferences:(MVPrefsViewController *)prefsViewController;

- (void)selectModel:(NSUInteger)modelIndex;

- (void)selectCullingType:(DSCullType)cullType;
- (void)selectDepthTest:(BOOL)depthTest;
- (void)selectDisplayAxes:(BOOL)axes;

@end

@interface MVPrefsViewController : UIViewController

@property(nonatomic, weak) IBOutlet UISegmentedControl *cullSegControl;
@property(nonatomic, weak) IBOutlet UISwitch *depthTestSwitch;
@property(nonatomic, weak) IBOutlet UISwitch *axesSwitch;
@property(nonatomic, weak) IBOutlet UIStepper *modelStepper;
@property(nonatomic, weak) IBOutlet UILabel *modelNumLabel;

// These are strong references because IBOutletCollection is an instance variable of NSArray, not just an arbitrary reference into the view hierarchy.
@property(nonatomic, strong) IBOutletCollection(UISlider) NSArray *paramSliders;
@property(nonatomic, strong) IBOutletCollection(UILabel)  NSArray *paramLabels;

@property(nonatomic, weak) id <MVPrefsDelegate> delegate;

@end
