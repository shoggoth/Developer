//
//  ALScene2ViewController.m
//  AutoLayout
//
//  Created by Optisoft Ltd on 11/10/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import "SBEScene2ViewController.h"


@interface SBEScene2ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *scene2label;

@end

@implementation SBEScene2ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
	
    self.scene2label.text = self.dataPassedIn;
}

@end
