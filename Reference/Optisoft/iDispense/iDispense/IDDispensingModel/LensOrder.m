//
//  LensOrder.m
//  iDispense
//
//  Created by Richard Henry on 18/02/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//

#import "LensOrder.h"
#import "Lens.h"
#import "LensTreatment.h"
#import "Order.h"

@implementation LensOrder

// Insert code here to add functionality to your managed object subclass

- (NSString *)uuid { return [NSString stringWithFormat:@"LO/%@", self.order.uuid]; }

@end
