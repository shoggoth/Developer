//
//  CVRootViewController.m
//  CollectionView
//
//  Created by Richard Henry on 07/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#import "CVRootViewController.h"
#import "CVCollectionViewController.h"


@implementation CVRootViewController {

    __weak CVCollectionViewController       *collectionViewController;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Storyboarding

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"embedToCollectionViewController"])  {
        
        // This is the embed segue connects the embedded collection view controller to this view controller.
        collectionViewController = segue.destinationViewController;
    }
}

#pragma mark Actions

// Clear the collection completely.
- (IBAction)clearCollection:(UIBarButtonItem *)sender { [collectionViewController clearCells]; }

// Add another view to the collection.
- (IBAction)addToCollection:(UIBarButtonItem *)sender { [collectionViewController addNewCell]; }

@end
