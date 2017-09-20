//
//  MDDetailViewController.h
//  MasterDetail
//
//  Created by Optisoft Ltd on 15/10/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
