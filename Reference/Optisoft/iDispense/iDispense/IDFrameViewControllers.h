//
//  IDFrameViewControllers.h
//  iDispense
//
//  Created by Richard Henry on 14/11/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDDispensingViewControllers.h"

@class Order;

//
//  IDFrameMasterViewController
//
//  A subclass of the dispensing master view controller that specialises functions
//  relating to the manipulation of frame data.
//

@interface IDFrameMasterViewController : IDDispensingMasterViewController

@property(nonatomic, strong) Order *selectedOrder;

@end

//
//  IDFrameDetailViewController
//
//  A subclass of the dispensing detail view controller that specialises functions
//  relating to the manipulation of frame data.
//

@interface IDFrameDetailViewController : IDDispensingDetailViewController

@end

//
//  IDFrameCell
//
//  Table view cell allowing details of each frame to be presented.
//

@interface IDFrameCell : UITableViewCell

// Labels
@property(nonatomic, weak) IBOutlet UILabel *orderNumberLabel;
@property(nonatomic, weak) IBOutlet UILabel *nameLabel;
@property(nonatomic, weak) IBOutlet UILabel *dateLabel;
@property(nonatomic, weak) IBOutlet UILabel *lensLabel;
@property(nonatomic, weak) IBOutlet UILabel *frameLabel;
@property(nonatomic, weak) IBOutlet UILabel *priceLabel;

@end
