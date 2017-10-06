//
//  IDLensParameters.m
//  iDispense
//
//  Created by Richard Henry on 19/06/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDLensParameters.h"

@implementation IDLensParameters

- (instancetype)initWithShape:(unsigned)shape prescription:(IDLensPrescription)prescription {

    if ((self = [super init])) {

        // Initialisation code here
        self.shape = shape;
        self.prescription = prescription;
    }

    return self;
}

@end
