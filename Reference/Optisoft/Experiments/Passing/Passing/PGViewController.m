//
//  PGViewController.m
//  Passing
//
//  Created by Richard Henry on 07/02/2014.
//  Copyright (c) 2014 Optisoft. All rights reserved.
//

#import "PGViewController.h"
#import "PGPushedDetailViewController.h"


@interface PGViewController ()

@property(nonatomic, weak) IBOutlet UITextField *entryField;

@end

@implementation PGViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    NSLog(@"VC %@ loaded", self);
}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    PGPushedDetailViewController    *detailViewController = segue.destinationViewController;
    NSString                        *entryFieldText = self.entryField.text;

    detailViewController.string = entryFieldText;
    detailViewController.completionBlock = ^(NSString *string) { self.entryField.text = string; };
}

#pragma UITextfieldDelegate conformance

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];

    return NO;
}

@end
