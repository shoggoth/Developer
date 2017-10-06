//
//  DSVelocitySimulator.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSVelocitySimulator.h"


@protocol DSVelocitySimulatorNode <NSObject>

- (void)insertIntoVelocitySimulation:(DSVelocitySimulator *)sim;
- (void)removeFromVelocitySimulation:(DSVelocitySimulator *)sim;

@end


@implementation DSVelocitySimulator

- (instancetype)initWithMaxObjects:(const unsigned)maxObjects {

    if ((self = [super initWithAddSelector:@selector(insertIntoVelocitySimulation:) remSelector:@selector(removeFromVelocitySimulation:)])) {
        
        NSLog(@"init Vel %@", self);
        
        // Create a new simulation space
        space = dsVelSpaceNew(maxObjects);
        assert(space);
    }
    
    return self;
}

- (void)dealloc {
    
    NSLog(@"dealloc Vel %@", self);
    
    // Deallocate resources
    dsVelSpaceFree(space);
}

#pragma mark Simulation

- (void)step {
    
    dsVelSpaceStep(space);
}

#pragma mark Properties

@synthesize space;

@end
