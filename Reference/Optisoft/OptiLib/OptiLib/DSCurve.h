//
//  DSCurve.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

@import GLKit;


//
//  protocol DSCurve
//
//  An oscillator which provides various common waveforms
//

@protocol DSCurve

- (GLKVector3)coordinatesAtAlpha:(float)alpha;

@end


//
//  interface DSCubicBezierCurve
//
//  An oscillator which provides various common waveforms
//

@interface DSCubicBezierCurve : NSObject <DSCurve>

@property(nonatomic) GLKVector2 anchor1;
@property(nonatomic) GLKVector2 anchor2;

@property(nonatomic) GLKVector2 control1;
@property(nonatomic) GLKVector2 control2;

@end

