//
//  PGPushedDetailViewController.m
//  Passing
//
//  Created by Richard Henry on 07/02/2014.
//  Copyright (c) 2014 Optisoft. All rights reserved.
//

#import "PGPushedDetailViewController.h"
#import "PGModalDetailViewController.h"


@interface PGPushedDetailViewController ()

@property(nonatomic, weak) IBOutlet UILabel *detailLabel;

@end

@implementation PGPushedDetailViewController

#pragma mark Actions

- (IBAction)addThingsPressed:(id)sender {

    self.detailLabel.text = [NSString stringWithFormat:@"Fuck you, %@, you mong!", self.detailLabel.text];
}

- (IBAction)resetThingsPressed:(id)sender {

    self.detailLabel.text = @"Nobs";
}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    PGModalDetailViewController *detailViewController = segue.destinationViewController;
    NSString                    *entryFieldText = self.detailLabel.text;

    detailViewController.string = entryFieldText;
    detailViewController.completionBlock = ^(NSString *string) { self.string = string; };
}

#pragma mark Dis/Appear

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    self.detailLabel.text = self.string;
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

    if (self.completionBlock) self.completionBlock(self.detailLabel.text);
}

@end
