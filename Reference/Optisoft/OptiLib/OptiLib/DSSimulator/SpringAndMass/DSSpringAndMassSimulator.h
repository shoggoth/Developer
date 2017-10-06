//
//  DSSpringAndMassSimulator.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSSimulator.h"

#import "dsmsSpace.h"


//
//  interface DSSpringAndMassSimulator
//
//  A simulator that implements physics using the chipmunk physics engine.
//  
//  The simulation is in 2 dimensions. Dynamics and collision are supported.
//  Actors wishing to use this simulation should respond to the selector pair:
//  insertIntoChipmunkSimulation: and removeFromChipmunkSimulation:
//

@interface DSSpringAndMassSimulator : DSSimulator {
    
@public
    DSSMSimSpace         *space;
}

@property(nonatomic, readonly) DSSMSimSpace *space;

- (instancetype)initWithMaxMasses:(const unsigned)maxMasses maxSprings:(const unsigned)maxSprings maxPlanes:(const unsigned)maxPlanes;

@end

