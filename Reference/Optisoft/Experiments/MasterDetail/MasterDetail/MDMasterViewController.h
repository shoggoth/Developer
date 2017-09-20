//
//  MDMasterViewController.h
//  MasterDetail
//
//  Created by Optisoft Ltd on 15/10/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDDetailViewController;

#import <CoreData/CoreData.h>

@interface MDMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) MDDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
