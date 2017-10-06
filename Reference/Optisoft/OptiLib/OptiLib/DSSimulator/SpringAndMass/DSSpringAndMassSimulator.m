//
//  DSSpringAndMassSimulator.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSSpringAndMassSimulator.h"


@protocol DSSpringAndMassSimulatorNode <NSObject>

- (void)insertIntoSpringAndMassSimulation:(DSSpringAndMassSimulator *)sim;
- (void)removeFromSpringAndMassSimulation:(DSSpringAndMassSimulator *)sim;

@end


@implementation DSSpringAndMassSimulator

- (instancetype)initWithMaxMasses:(const unsigned)maxMasses maxSprings:(const unsigned)maxSprings maxPlanes:(const unsigned)maxPlanes {

    if ((self = [super initWithAddSelector:@selector(insertIntoSpringAndMassSimulation:) remSelector:@selector(removeFromSpringAndMassSimulation:)])) {
        
        NSLog(@"init SM %@", self);
        
        // Create a new simulation space
        space = dsmsSpaceNew(maxMasses, maxSprings, maxPlanes);
        assert(space);
    }
    
    return self;
}

- (void)dealloc {
    
    NSLog(@"dealloc SM %@", self);
    
    // Deallocate resources
    dsmsSpaceFree(space);
}

#pragma mark Simulation

- (void)step {
    
    dsmsSpaceStep(space);
}

#pragma mark Object description

- (NSString*)description {
    
    return [NSString stringWithFormat:@"<%@: 0x%x | space: %x>", [self class], (unsigned)self, (unsigned)space];
}

#pragma mark Properties

@synthesize space;

@end
