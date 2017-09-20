//
//  LLViewController.m
//  Layers
//
//  Created by Richard Henry on 20/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#import "LLViewController.h"


@implementation LLViewController {

    __weak IBOutlet UIView                          *subView;
    __weak IBOutlet UIButton                        *bigButton;
    __weak IBOutlet UIButton                        *smallButton;

    IBOutletCollection(NSLayoutConstraint) NSArray  *constraints;

    float                                           amount;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    amount = 200;

    CALayer *layer;

    layer = [CALayer layer];
    layer.backgroundColor = [UIColor greenColor].CGColor;
    layer.frame = (CGRect) { 0, 0, 200, 200 };
    [subView.layer addSublayer:layer];

    layer = [CALayer layer];
    layer.backgroundColor = [UIColor redColor].CGColor;
    layer.frame = (CGRect) { 0, 0, 100, 100 };
    [subView.layer addSublayer:layer];

    layer = [CALayer layer];
    layer.backgroundColor = [UIColor blueColor].CGColor;
    layer.frame = (CGRect) { 0, 0, 50, 50 };
    [subView.layer addSublayer:layer];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Actions

- (IBAction)embiggen:(id)sender {

    [UIView animateWithDuration:2
                     animations:^ {

                         for (NSLayoutConstraint *constraint in constraints) constraint.constant -= amount;
                         [subView layoutIfNeeded];

                         bigButton.enabled = NO;
                     }
                     completion:^(BOOL finished) {

                         smallButton.enabled = YES;
                     }];
}

- (IBAction)unEmbiggen:(id)sender {

    [UIView animateWithDuration:2
                     animations:^ {

                         for (NSLayoutConstraint *constraint in constraints) constraint.constant += amount;
                         [subView layoutIfNeeded];

                         smallButton.enabled = NO;
                     }
                     completion:^(BOOL finished) {

                         bigButton.enabled = YES;
                     }];
}

#pragma mark Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [touches anyObject];

    NSLog(@"Object = %@", touch.view);
}

@end
