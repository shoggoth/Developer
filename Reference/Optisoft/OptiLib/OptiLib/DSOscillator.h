//
//  DSOscillator.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSTime.h"
#import "DSSimulator.h"


//
//  interface DSOscillatorSimulator
//
//  An oscillator which provides various common waveforms
//

@interface DSOscillatorSimulator : DSSimulator

// Properties
@property(nonatomic) DSTime simTime;
@property(nonatomic) DSTime stepTime;

@end


//
//  interface DSOscillator
//
//  An oscillator which provides various common waveforms
//

@class DSInterpolator;

@interface DSOscillator : NSObject

// Properties
@property(nonatomic, readonly) float value;

@property(nonatomic) DSTime cycleTime;
@property(nonatomic) float amplitude;

@property(nonatomic, strong) DSInterpolator *interpolator;

@end
