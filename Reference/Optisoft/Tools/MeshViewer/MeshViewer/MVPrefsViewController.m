//
//  MVPrefsViewController.m
//  MeshViewer
//
//  Created by Richard Henry on 25/07/2014.
//  Copyright (c) 2014 Dogstar Industries. All rights reserved.
//

#import "MVPrefsViewController.h"

@implementation MVPrefsViewController

#pragma mark Lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];

    // Let the delegate set initial switch states.
    [self.delegate setupPreferences:self];
}

#pragma mark Action

- (IBAction)modelStepped:(UIStepper *)stepper {

    NSUInteger value = stepper.value;

    self.modelNumLabel.text = [NSString stringWithFormat:@"Model %lu", (unsigned long)value];

    [self.delegate selectModel:value];
}

- (IBAction)cullingTypeSelected:(UISegmentedControl *)seg {

    [self.delegate selectCullingType:(DSCullType)seg.selectedSegmentIndex];
}

- (IBAction)depthTestSelected:(UISwitch *)swi {

    [self.delegate selectDepthTest:swi.on];
}

- (IBAction)axesSelected:(UISwitch *)swi {

    [self.delegate selectDisplayAxes:swi.on];
}

@end
