//
//  DSFilter.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSFilter.h"


#pragma mark Low-pass filter

@implementation DSLowPassFilter {

    float       lowPassedValue;
}


@synthesize filterFactor;

- (float)filterValue:(float)value {
    
    lowPassedValue = value * filterFactor + lowPassedValue * (1.0f - filterFactor);
    
    return lowPassedValue;
}

@end

#pragma mark - High pass filter

@implementation DSHighPassFilter

- (float)filterValue:(float)value {
    
    return value - [super filterValue:value];  // High passed value == 1 - lowPassed
}

@dynamic filterFactor;

- (void)setFilterFactor:(float)ff { filterFactor = 1.0f - ff; }

@end
