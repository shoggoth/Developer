//
//  IDLensViewControllers.h
//  iDispense
//
//  Created by Richard Henry on 14/11/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDDispensingViewControllers.h"

@class Order;

//
//  IDLensMasterViewController
//
//  A subclass of the dispensing master view controller that specialises functions
//  relating to the manipulation of lens data.
//

@interface IDLensMasterViewController : IDDispensingMasterViewController

@property(nonatomic, strong) Order *selectedOrder;

@end

//
//  IDLensDetailViewController
//
//  A subclass of the dispensing detail view controller that specialises functions
//  relating to the manipulation of lens data.
//

@interface IDLensDetailViewController : IDDispensingDetailViewController

@end

//
//  IDLensCell
//
//  Table view cell allowing details of each lens to be presented.
//

@interface IDLensCell : UITableViewCell

// Labels
@property(nonatomic, weak) IBOutlet UILabel *orderNumberLabel;
@property(nonatomic, weak) IBOutlet UILabel *nameLabel;
@property(nonatomic, weak) IBOutlet UILabel *dateLabel;
@property(nonatomic, weak) IBOutlet UILabel *lensLabel;
@property(nonatomic, weak) IBOutlet UILabel *frameLabel;
@property(nonatomic, weak) IBOutlet UILabel *priceLabel;

@end
