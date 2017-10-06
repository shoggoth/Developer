//
//  EyePrescription.m
//  iDispense
//
//  Created by Richard Henry on 18/02/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//

#import "EyePrescription.h"
#import "Prescription.h"

@implementation EyePrescription

// Insert code here to add functionality to your managed object subclass

- (NSString *)uuid {

    if (self.left) return [NSString stringWithFormat:@"L/%@", self.left.uuid];
    else if (self.right) return [NSString stringWithFormat:@"R/%@", self.right.uuid];
    else return @"";
}

@end
