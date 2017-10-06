//
//  DSInverseSquareSimulator.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSInverseSquareSimulator.h"


@protocol DSInverseSquareSimulatorNode <NSObject>

- (void)insertIntoInverseSquareSimulation:(DSInverseSquareSimulator *)sim;
- (void)removeFromInverseSquareSimulation:(DSInverseSquareSimulator *)sim;

@end


@implementation DSInverseSquareSimulator

- (instancetype)initWithMaxMasses:(const unsigned)maxMasses {

    if ((self = [super initWithAddSelector:@selector(insertIntoInverseSquareSimulation:) remSelector:@selector(removeFromInverseSquareSimulation:)])) {
        
        NSLog(@"init IS %@", self);
        
        // Create a new simulation space
        space = dsisSpaceNew(maxMasses);
        assert(space);
    }
    
    return self;
}

- (void)dealloc {
    
    NSLog(@"dealloc IS %@", self);
    
    // Deallocate resources
    dsisSpaceFree(space);
}

#pragma mark Simulation

- (void)step {
    
    dsisSpaceStep(space);
}

#pragma mark Object description

- (NSString*)description {
    
    return [NSString stringWithFormat:@"<%@: 0x%x | space: %x>", [self class], (unsigned)self, (unsigned)space];
}

#pragma mark Properties

@synthesize space;

@end
