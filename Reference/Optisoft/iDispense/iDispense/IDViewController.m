//
//  IDViewController.m
//  iDispense
//
//  Created by Optisoft Ltd on 01/10/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import "IDCollectionViewController.h"
#import "IDLayoutTransitionController.h"


@interface IDViewController : UIViewController <IDLayoutTransitionControllerDelegate>

@end

#pragma mark - Root view controller

@implementation IDViewController {
    
    IDCollectionViewController       *collectionViewController;
    IDLayoutTransitionController     *transitionController;
}

#pragma mark Overrides

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Storyboarding

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"embedCollectionVC"])  {

        // This is the embed segue connects the embedded collection view controller to this (the root) view controller.
        collectionViewController = segue.destinationViewController;
        collectionViewController.title = @"Sonichu";

        transitionController = [[IDLayoutTransitionController alloc] initWithCollectionView:collectionViewController.collectionView];
        transitionController.delegate = self;
    }
}

#pragma mark Actions

- (IBAction)add:(id)sender { [collectionViewController addNewCell]; }

- (IBAction)clear:(id)sender { [collectionViewController clearCells]; }

#pragma mark Transition support

-(void)interactionBeganAtPoint:(CGPoint)p
{
    // Very basic communication between the transition controller and the top view controller
    // It would be easy to add more control, support pop, push or no-op
    IDCollectionViewController *presentingVC = (IDCollectionViewController *)[self.navigationController topViewController];
    presentingVC = collectionViewController;
    IDCollectionViewController *presentedVC = (IDCollectionViewController *)[presentingVC nextViewControllerAtPoint:p];
    if (presentedVC!=nil)
    {
        [self.navigationController pushViewController:presentedVC animated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
