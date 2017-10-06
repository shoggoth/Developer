//
//  DSOscillator.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSOscillator.h"
#import "DSInterpolator.h"
#import "DSTime.h"


#pragma mark Oscillator

@implementation DSOscillator {

    float                   value;
    DSOscillatorSimulator   *simulator;
}

- (instancetype)init {
    
    if ((self = [super init])) {
        
        _cycleTime = kDSTimeToSeconds;
        _amplitude = 1.0f;
    }
    
    return self;
}

- (void)dealloc {
    
    self.interpolator = nil;
}

- (void)insertIntoOscillatorSimulation:(DSOscillatorSimulator *)sim {
    
    simulator = sim;
}

- (void)removeFromOscillatorSimulation:(DSOscillatorSimulator *)sim {
    
    simulator = nil;
}

- (void)sync {
    
    DSTime          syncTime = simulator.simTime;
    float           ct = _amplitude / _cycleTime;
    
    value = (syncTime % _cycleTime) * ct;
    
    if (_interpolator) {
        
        _interpolator.oldValue = value;
        _interpolator.newValue = (syncTime % _cycleTime + simulator.stepTime) * ct;
    }

    NSLog(@"sync %lld", syncTime);
}

#pragma mark Properties

@dynamic value;

- (float)value { return (_interpolator) ? _interpolator.value : value; }

@end

#pragma mark - Simulator

@implementation DSOscillatorSimulator

- (instancetype)init {
    
    if ((self = [super initWithAddSelector:@selector(insertIntoOscillatorSimulation:) remSelector:@selector(removeFromOscillatorSimulation:)])) {
        
        _simTime = kDSTimeZero;
        _stepTime = 1;
    }
    
    return self;
}

#pragma mark Simulation

- (void)step {
    
    _simTime += _stepTime;
}

@end
