//
//  DSCurveSimulator.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSSimulator.h"
#import "DSActor.h"
#import "DSCurve.h"


//
//  interface DSCurveActor
//
//  A simulator that implements physics using the chipmunk physics engine.
//
//  The simulation is in 2 dimensions. Dynamics and collision are supported.
//  Actors wishing to use this simulation should respond to the selector pair:
//  insertIntoChipmunkSimulation: and removeFromChipmunkSimulation:
//

@interface DSCurveActor : NSObject <DSActor>

@property(nonatomic) BOOL active;

@property(nonatomic) float currentValue;
@property(nonatomic) float frequency;

@property(nonatomic, copy) float (^curveBlock)(const float alpha);
@property(nonatomic, copy) BOOL  (^completionBlock)(BOOL finished);

- (void)advanceSimulation;

@end


//
//  interface DSCurveSimulator
//
//  A simulator that implements physics using the chipmunk physics engine.
//
//  The simulation is in 2 dimensions. Dynamics and collision are supported.
//  Actors wishing to use this simulation should respond to the selector pair:
//  insertIntoChipmunkSimulation: and removeFromChipmunkSimulation:
//

@interface DSCurveSimulator : DSSimulator

@property(nonatomic, strong) NSMutableArray *curves;

@end

