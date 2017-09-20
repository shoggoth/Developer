//
//  ALViewController.m
//  AutoLayout
//
//  Created by Optisoft Ltd on 11/10/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import "SBEViewController.h"
#import "SBEScene2ViewController.h"
#import "SBECustomSegue.h"


@interface SBEViewController ()
- (IBAction)adjust:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *scene1Label;

@end

@implementation SBEViewController {
    
    int         counter;
}

#pragma mark Overrides

- (void)viewDidLoad {
    
    [super viewDidLoad];
	
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)adjust {
}
- (IBAction)adjustLabels:(id)sender {
}
- (IBAction)adjustLabels:(id)sender {
}
#pragma mark Storyboard
- (IBAction)adjustLabels:(id)sender {
}

- (void)prepareForSegue:(SBECustomSegue *)segue sender:(id)sender {
    
    segue.unwind = NO;
    
    SBEScene2ViewController *destinationViewController = segue.destinationViewController;
    
    destinationViewController.dataPassedIn = [NSString stringWithFormat:@"Scene One data (%d)", counter++];
}

- (IBAction)returnFromSegue:(UIStoryboardSegue *)segue {
    
    // RJH NB For this to be connectable in IB, the passed parameter must be of a segue or subclass.
    
    NSLog(@"Segue return with source %@ destination %@", segue.sourceViewController, segue.destinationViewController);
    
    self.scene1Label.text = [NSString stringWithFormat:@"Scene Two returned (%d)", counter++];
}

- (IBAction)adjust:(id)sender {
}
@end
