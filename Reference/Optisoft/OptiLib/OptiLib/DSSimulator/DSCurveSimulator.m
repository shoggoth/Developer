//
//  DSCurveSimulator.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSCurveSimulator.h"


@protocol DSCurveSimulatorNode <NSObject>

- (void)insertIntoCurveSimulation:(DSCurveSimulator *)sim;
- (void)removeFromCurveSimulation:(DSCurveSimulator *)sim;

@end


@implementation DSCurveActor {

    float       old, new, t;
}

- (instancetype)init {

    if ((self = [super init])) {

        // Initialisation
        self.frequency = 1;
    }

    return self;
}

- (void)dealloc {

    // Call the completion block and tell it that the curve did not complete before it got deallocated.
    if (_completionBlock) _completionBlock(NO);
}

#pragma mark Simulation control

- (void)insertIntoCurveSimulation:(DSCurveSimulator *)sim {

    self.currentValue = 0;
    [sim.curves addObject:self];
}

- (void)removeFromCurveSimulation:(DSCurveSimulator *)sim {

    [sim.curves removeObject:self];
}

#pragma mark Simulation step

- (void)advanceSimulation {

    // If we have reached the end of the cycle,
    if (t >= 1) {

        // Reset the time counter and call the completion block
        self.currentValue = 0;
        self.active = (_completionBlock) ? _completionBlock(YES) : NO;
    }

    new = t + self.frequency;
}

#pragma mark Engine

- (void)sync {

    old = new;
}

- (void)interpolate:(float)alpha {

    t = old + (new - old) * alpha;
}

#pragma mark Properties

- (float)currentValue {

    return (_curveBlock) ? (_curveBlock(t)) : t;
}

- (void)setCurrentValue:(float)value {

    t = old = new = value;
}

@end


@implementation DSCurveSimulator

- (instancetype)init {

    if ((self = [super initWithAddSelector:@selector(insertIntoCurveSimulation:) remSelector:@selector(removeFromCurveSimulation:)])) {
        
        self.curves = [NSMutableArray array];
    }
    
    return self;
}

- (void)dealloc {
    
    self.curves = nil;
}

#pragma mark Simulation

- (void)step {

    if (self.curves.count) NSLog(@"Simulating %lu curves", (unsigned long)self.curves.count);

    for (DSCurveActor *curve in _curves) {

        [curve advanceSimulation];
    }
}

@end
