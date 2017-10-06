//
//  FrameOrder.m
//  iDispense
//
//  Created by Richard Henry on 18/02/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//

#import "FrameOrder.h"
#import "Frame.h"
#import "Order.h"

@implementation FrameOrder

// Insert code here to add functionality to your managed object subclass

- (NSString *)uuid { return [NSString stringWithFormat:@"FO/%@", self.order.uuid]; }

@end
