//
//  IDOrderCell.h
//  iDispense
//
//  Created by Richard Henry on 17/11/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

@class Order;

@interface IDOrderCell : UITableViewCell

// Labels
@property(nonatomic, weak) IBOutlet UILabel *orderNumberLabel;
@property(nonatomic, weak) IBOutlet UILabel *nameLabel;
@property(nonatomic, weak) IBOutlet UILabel *dateLabel;
@property(nonatomic, weak) IBOutlet UILabel *lensLabel;
@property(nonatomic, weak) IBOutlet UILabel *frameLabel;
@property(nonatomic, weak) IBOutlet UILabel *priceLabel;

@end
