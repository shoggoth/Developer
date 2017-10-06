//
//  DSSimulator.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//


//
//  DSSimulator class interface
//
//  TODO: document this
//

@interface DSSimulator : NSObject {

    SEL         addSelector;
    SEL         remSelector;
}

- (instancetype)initWithAddSelector:(SEL)as remSelector:(SEL)rs;

- (void)addSimulationNode:(NSObject *)node;
- (void)removeSimulationNode:(NSObject *)obj;

- (void)step;

@end
