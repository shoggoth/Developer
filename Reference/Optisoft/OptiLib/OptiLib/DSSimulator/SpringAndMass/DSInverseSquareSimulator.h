//
//  DSInverseSquareSimulator.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSSimulator.h"

#import "dsisSpace.h"


//
//  interface DSInverseSquareSimulator
//
//  A simulator that implements physics using the chipmunk physics engine.
//  
//  The simulation is in 2 dimensions. Dynamics and collision are supported.
//  Actors wishing to use this simulation should respond to the selector pair:
//  insertIntoChipmunkSimulation: and removeFromChipmunkSimulation:
//

@interface DSInverseSquareSimulator : DSSimulator {
    
@public
    DSISSimSpace         *space;
}

@property(nonatomic, readonly) DSISSimSpace *space;

- (instancetype)initWithMaxMasses:(const unsigned)maxMasses;

@end

