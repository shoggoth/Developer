//
//  PGModalDetailViewController.m
//  Passing
//
//  Created by Richard Henry on 07/02/2014.
//  Copyright (c) 2014 Optisoft. All rights reserved.
//

#import "PGModalDetailViewController.h"


@interface PGModalDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end

@implementation PGModalDetailViewController

#pragma mark Actions

- (IBAction)dismiss:(id)sender {

    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark Dis/Appear

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    self.detailLabel.text = [NSString stringWithFormat:@"Dumbonic says %@", self.string];
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

    if (self.completionBlock) self.completionBlock(self.detailLabel.text);
}

@end
