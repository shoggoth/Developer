//
//  DSInterpolator.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSInterpolator.h"

#import "DSSimulator/DSCurveSimulator.h"


@implementation DSInterpolator

- (void)interpolate:(float)alpha {
    
    value = DSFloatInterpolate(oldValue, newValue, alpha);
}

#pragma mark Object description

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<%@: 0x%x | value: %f (%f - %f)>", [self class], (unsigned)self, value, oldValue, newValue];
}

#pragma mark Properties

@synthesize oldValue;
@synthesize newValue;

- (float)value { return value; }

- (void)setValue:(float)v {
    
    oldValue = newValue;
    newValue = v;
}

@dynamic value;

@end


@implementation DSInterpolatorActor

- (void)dealloc {

    if (_completionBlock) _completionBlock(NO);
}

#pragma mark Lifecycle

- (void)tick {

    if (!self.active) {

        //NSLog(@"Finished %@\n\n", self);
        if (_completionBlock) _completionBlock(YES);
    }
}

- (void)sync {

    NSLog(@"Sync curve %@", self);
    _value += _increment;

    if (_value >= 1) self.active = NO;
}

- (void)interpolate:(float)alpha {

    //NSLog(@"Interping %@", self);

    if (_interpolateBlock) _interpolateBlock(DSFloatInterpolate(_value, _value + _increment, alpha));
}

@end
