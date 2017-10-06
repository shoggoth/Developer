//
//  DSCurve.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSCurve.h"


@implementation DSCubicBezierCurve

- (instancetype)init {
    
    if ((self = [super init])) {
        
        _anchor1 = (GLKVector2) { 0, 0 };
        _anchor2 = (GLKVector2) { 1, 1 };

        _control1 = (GLKVector2) { 0.5, 0.5 };
        _control2 = (GLKVector2) { 0.5, 0.5 };
}
    
    return self;
}

- (GLKVector3)coordinatesAtAlpha:(float)alpha {

    GLKVector2 p3 = GLKVector2MultiplyScalar(GLKVector2Subtract(GLKVector2Add(GLKVector2MultiplyScalar(GLKVector2Subtract(_control1, _control2), 3), _anchor2), _anchor1), powf(alpha, 3));
    GLKVector2 p2 = GLKVector2MultiplyScalar(GLKVector2Add(GLKVector2Subtract(_anchor1, GLKVector2MultiplyScalar(_control1, 2)), _control2), powf(alpha, 2) * 3);
    GLKVector2 p1 = GLKVector2MultiplyScalar(GLKVector2Subtract(_control1, _anchor1), alpha * 3);

    GLKVector2 point = GLKVector2Add(p3, GLKVector2Add(p2, GLKVector2Add(p1, _anchor1)));
    
    return (GLKVector3) { point.x, point.y, 0 };
}

@end
