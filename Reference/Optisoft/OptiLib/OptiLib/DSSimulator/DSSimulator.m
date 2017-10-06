//
//  DSSimulator.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSSimulator.h"


@interface DSSimulator (Private)

- (void)insertIntoNullSimulation:(DSSimulator *)sim;
- (void)removeFromNullSimulation:(DSSimulator *)sim;

@end


@implementation DSSimulator

- (instancetype)init {
    
    return [self initWithAddSelector:@selector(insertIntoNullSimulation:) remSelector:@selector(removeFromNullSimulation:)];
}

- (instancetype)initWithAddSelector:(SEL)as remSelector:(SEL)rs {
    
    if ((self = [super init])) {
        
        addSelector = as;
        remSelector = rs;
    }
    
    return self;
}

- (void)step {}

- (void)addSimulationNode:(NSObject *)obj {
    
    if ([obj respondsToSelector:addSelector]) {

        // Perform the selector and shut up the ARC warning
        void (*functionPtr)(id, SEL, DSSimulator *sim) = (void *)([obj methodForSelector:addSelector]);

        functionPtr(obj, addSelector, self);
    }
}

- (void)removeSimulationNode:(NSObject *)obj {
    
    if ([obj respondsToSelector:remSelector]) {

        // Perform the selector and shut up the ARC warning
        void (*functionPtr)(id, SEL, DSSimulator *sim) = (void *)([obj methodForSelector:remSelector]);

        functionPtr(obj, remSelector, self);
    }
}

@end
