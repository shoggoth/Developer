//
//  DSInterpolator.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSActor.h"
#import "DSEngine.h"


//
//  function DSFloatInterpolate
//
//  Returns the interpolation between two values.
//

static inline float DSFloatInterpolate(const float f1, const float f2, const float alpha) {
    
    return f1 + (f2 - f1) * alpha;
}


//
//  interface DSInterpolator
//
//  Interpolates a floating point value between the previous and last values set.
//  
//  Objects need to have the 'interpolate' message at appropriate times. Usually this 
//  will be done by the game engine.
//


@interface DSInterpolator : NSObject {
	
@private
	float           value, oldValue, newValue;
}

@property(nonatomic) float value;

@property(nonatomic) float oldValue;
@property(nonatomic) float newValue;

@end

@interface DSInterpolatorActor : NSObject <DSActor, DSEngineNode>

@property(nonatomic) BOOL active;

@property(nonatomic) float value;
@property(nonatomic) float increment;

@property(nonatomic, copy) void (^interpolateBlock)(const float alpha);
@property(nonatomic, copy) void (^completionBlock)(BOOL finished);

@end