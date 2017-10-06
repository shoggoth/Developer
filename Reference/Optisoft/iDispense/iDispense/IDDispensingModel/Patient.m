//
//  Patient.m
//  iDispense
//
//  Created by Richard Henry on 18/02/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//

#import "Patient.h"
#import "Order.h"
#import "Prescription.h"

@implementation Patient

// Insert code here to add functionality to your managed object subclass

- (NSString *)uuid { return [NSString stringWithFormat:@"%@/%@", self.surName, self.firstName]; }

@end
