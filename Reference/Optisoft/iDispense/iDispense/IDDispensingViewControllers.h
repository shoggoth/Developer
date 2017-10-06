//
//  IDDispensingViewControllers.h
//  iDispense
//
//  Created by Richard Henry on 08/12/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

@import CoreData;

@class IDRecordFetcher;
@class Order;

//
//  IDDispensingMasterViewController
//
//  A base class containing functionality of the master view controller provided
//  to the subclasses to support dispensing operations.
//

@interface IDDispensingMasterViewController : UITableViewController  <NSFetchedResultsControllerDelegate, UISearchBarDelegate>

// Table cells
@property(nonatomic, copy) NSString *cellIdentifier;

// Core data
@property(nonatomic, strong) IDRecordFetcher *dataFetcher;

// UI
@property(nonatomic, weak) IBOutlet UIBarButtonItem *addButton;

// Utility
-(void)scrollToBottom;

@end

//
//  IDDispensingDetailViewController
//
//  A base class containing functionality of the detail view controller provided
//  to the subclasses to support dispensing operations.
//

@interface IDDispensingDetailViewController : UITableViewController

@property(nonatomic, strong) Order *detailOrder;

// Completion handlers
@property(nonatomic, copy) void (^doneBlock)(Order *order);
@property(nonatomic, copy) void (^cancelBlock)(Order *order);

@end
