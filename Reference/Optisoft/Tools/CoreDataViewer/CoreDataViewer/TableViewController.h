//
//  TableViewController.h
//  CloudStorage
//
//  Created by Richard Henry on 25/08/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

@import UIKit;
@import CoreData;

@interface TableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property(nonatomic, strong, nullable) NSFetchedResultsController *frc;

- (void)performFetch;

@end
