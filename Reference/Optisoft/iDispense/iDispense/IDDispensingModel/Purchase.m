//
//  Purchase.m
//  iDispense
//
//  Created by Richard Henry on 18/02/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//

#import "Purchase.h"

@implementation Purchase

// Insert code here to add functionality to your managed object subclass

- (void)awakeFromInsert {

    [super awakeFromInsert];

    // Make a uuid for the purchase
    self.uuid = [[NSUUID UUID] UUIDString];

    // Fill in default values
    if (!self.name) self.name = @"";
    if (!self.price) self.price = [NSDecimalNumber zero];
    if (!self.dateModified) self.dateModified = [NSDate date];
}

@end
