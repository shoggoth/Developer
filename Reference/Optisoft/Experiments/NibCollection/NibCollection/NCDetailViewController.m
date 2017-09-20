//
//  NCDetailViewController.m
//  NibCollection
//
//  Created by Richard Henry on 26/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#import "NCDetailViewController.h"


@implementation NCDetailViewController {

    __weak IBOutlet UIStepper   *stepper;
    __weak IBOutlet UILabel     *label;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {

        // Custom initialization
    }

    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Actions

- (IBAction)stepperValueChanged:(UIStepper *)sender {

    label.text = [NSString stringWithFormat:@"%.0f", sender.value];
}

- (IBAction)cancel:(id)sender {

    if (self.myBlock) self.myBlock(stepper.value);
}

- (IBAction)done:(id)sender {

    if (self.myBlock) self.myBlock(stepper.value);
}

@end
