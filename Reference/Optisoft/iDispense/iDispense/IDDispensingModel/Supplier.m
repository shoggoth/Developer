//
//  Supplier.m
//  iDispense
//
//  Created by Richard Henry on 18/02/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//

#import "Supplier.h"
#import "Order.h"

@implementation Supplier

// Insert code here to add functionality to your managed object subclass

- (NSString *)uuid { return [NSString stringWithFormat:@"%@/%@", self.name, self.accountNumber]; }

@end
