//
//  SCViewController.m
//  SadunConstraint
//
//  Created by Richard Henry on 06/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#import "SCViewController.h"
#import "NSObject+NameTag.h"


@interface SCViewController ()

@end

@implementation SCViewController {
    
    __weak IBOutlet UILabel *valueLabel;
}

- (void)loadView {
    
    // Create a view
    self.view = [UIView new];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Load the autolayout subview from its nib file
    //UIView *subView = [[[NSBundle mainBundle] loadNibNamed:@"AutoSizeView" owner:self options:nil] lastObject];
    UIView *subView = [[[UINib nibWithNibName:@"AutoSizeView" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil] lastObject];
    
    // Add the subview to our view
    [self.view addSubview:subView];
    
    // Prepare it for Auto Layout
    // Even though the view was laid out using Auto Sizing, you're adding
    // it *to* Auto Layout. This property only affects the subview's relations
    // to its parents and not the subviews.
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Add constraints
    NSLayoutConstraint *constraint;
    
    // Centre it along its parent X and Y axes
    constraint = [NSLayoutConstraint constraintWithItem:subView
                                              attribute:NSLayoutAttributeCenterX
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.view
                                              attribute:NSLayoutAttributeCenterX
                                             multiplier:1
                                               constant:0];
    
    [self.view addConstraint:constraint];

    constraint = [NSLayoutConstraint constraintWithItem:subView
                                              attribute:NSLayoutAttributeCenterY
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.view
                                              attribute:NSLayoutAttributeCenterY
                                             multiplier:1
                                               constant:0];
    
    [self.view addConstraint:constraint];
    
    // Set its aspect ratio to 1:1
    constraint = [NSLayoutConstraint constraintWithItem:subView
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:subView
                                              attribute:NSLayoutAttributeHeight
                                             multiplier:1
                                               constant:0];
    
    [self.view addConstraint:constraint];
    
    // Constrain it with respect to the superview's size
    constraint = [NSLayoutConstraint constraintWithItem:subView
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationLessThanOrEqual
                                                 toItem:self.view
                                              attribute:NSLayoutAttributeWidth
                                             multiplier:1
                                               constant:-40];
    
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:subView
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationLessThanOrEqual
                                                 toItem:self.view
                                              attribute:NSLayoutAttributeHeight
                                             multiplier:1
                                               constant:-40];
    
    [self.view addConstraint:constraint];
    
    // Add a weak "match size" constraint
    constraint = [NSLayoutConstraint constraintWithItem:subView
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.view
                                              attribute:NSLayoutAttributeWidth
                                             multiplier:1
                                               constant:-40];
    
    constraint.priority = 1;
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:subView
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationLessThanOrEqual
                                                 toItem:self.view
                                              attribute:NSLayoutAttributeHeight
                                             multiplier:1
                                               constant:-40];
    
    constraint.priority = 1;
    [self.view addConstraint:constraint];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    [UIView animateWithDuration:duration animations:^{
    
        [self updateViewConstraints];
        [self.view layoutIfNeeded];
    }];
}

- (void)updateViewConstraints {
    
    [super updateViewConstraints];
    
    BOOL layoutIsPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
    
    NSLog(@"Updating view constraints p %d", layoutIsPortrait);
}

#pragma mark Actions

- (IBAction)switchLabelText:(UIBarButtonItem *)sender {
    
    static int numberOfTimes = 2;
    
    NSMutableString * string = [NSMutableString string];
    
    for (int i = 0; i < numberOfTimes; i++) [string appendString:@"Value"];
    
    valueLabel.text = string;
    
    numberOfTimes = (++numberOfTimes % 7);
}

@end
