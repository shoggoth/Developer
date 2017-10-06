//
//  DO.m
//  iDispense
//
//  Created by Richard Henry on 18/02/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//

#import "DO.h"
#import "Order.h"
#import "Practice.h"

@implementation DO

// Insert code here to add functionality to your managed object subclass

- (NSString *)uuid { return [NSString stringWithFormat:@"DO/%@/%@", self.surName, self.firstName]; }

@end
