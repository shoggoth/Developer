//
//  DSVelocitySimulator.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSSimulator.h"

#import "dsVelSpace.h"


//
//  interface DSVelocitySimulator
//
//  A simulator that implements physics using the chipmunk physics engine.
//  
//  The simulation is in 2 dimensions. Dynamics and collision are supported.
//  Actors wishing to use this simulation should respond to the selector pair:
//  insertIntoChipmunkSimulation: and removeFromChipmunkSimulation:
//

@interface DSVelocitySimulator : DSSimulator {
    
@public
    DSVelSimSpace       *space;
}

@property(nonatomic, readonly) DSVelSimSpace *space;

- (instancetype)initWithMaxObjects:(const unsigned)maxObjects;

@end

