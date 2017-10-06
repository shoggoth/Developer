//
//  IDDispensingDetailViewController.h
//  iDispense
//
//  Created by Richard Henry on 10/11/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

@class Order;

@interface IDDispensingDetailViewController : UITableViewController

@property(nonatomic, strong) Order *detailOrder;

// Completion handlers
@property(nonatomic, copy) void (^doneBlock)(Order *order);
@property(nonatomic, copy) void (^cancelBlock)(Order *order);

@end
