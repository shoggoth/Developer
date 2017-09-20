//
//  PGPushedDetailViewController.h
//  Passing
//
//  Created by Richard Henry on 07/02/2014.
//  Copyright (c) 2014 Optisoft. All rights reserved.
//


@interface PGPushedDetailViewController : UIViewController

@property(nonatomic, copy) NSString *string;
@property(nonatomic, copy) void (^completionBlock)(NSString *string);

@end
