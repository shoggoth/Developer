//
//  DSTransform.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

@import GLKit;


//
//  interface DSTransform
//
//  Describes a general 3D affine transformation
//

@interface DSTransform : NSObject {
    
    GLKMatrix4          transformMatrix;
}

@property(nonatomic, readonly) GLKMatrix4 transformMatrix;

@end


//
//  interface DS2DTransform
//
//  2 Dimensional transform
//

@interface DS2DTransform : DSTransform {
    
    GLKVector2          pos;                    // Position
    float               rot;                    // Rotation
    GLKVector2          scl;                    // Scaling
}

- (DS2DTransform *)initWithPos:(GLKVector2)pos;
- (DS2DTransform *)initWithPos:(GLKVector2)pos rot:(float)rot;
- (DS2DTransform *)initWithPos:(GLKVector2)pos rot:(float)rot scl:(GLKVector2)scl;

@property(nonatomic) GLKVector2 pos;
@property(nonatomic) float rot;
@property(nonatomic) GLKVector2 scl;

@end


//
//  interface DS2DInterpolatedTransform
//
//  2 Dimensional interpolated transform
//

@interface DS2DInterpolatedTransform : DS2DTransform {
    
    GLKVector2          newPos;
    float               newRot;
    GLKVector2          newScl;
    
@private
    GLKVector2          oldPos;
    float               oldRot;
    GLKVector2          oldScl;
}

- (void)interpolate:(float)alpha;

@property(nonatomic) GLKVector2 pos;
@property(nonatomic) float rot;
@property(nonatomic) GLKVector2 scl;

@end


//
//  interface DS3DTransform
//
//  3 Dimensional transform using quaternions
//

@interface DS3DTransform : DSTransform {
    
    GLKVector3          pos;
    GLKQuaternion       rot;
    GLKVector3          scl;
}

- (DS3DTransform *)initWithPos:(GLKVector3)pos;
- (DS3DTransform *)initWithPos:(GLKVector3)pos rot:(GLKQuaternion)rot;
- (DS3DTransform *)initWithPos:(GLKVector3)pos rot:(GLKQuaternion)rot scl:(GLKVector3)scl;

@property(nonatomic) GLKVector3 pos;
@property(nonatomic) GLKQuaternion rot;
@property(nonatomic) GLKVector3 scl;

@end


//
//  interface DS3DInterpolatedTransform
//
//  3 Dimensional interpolated transform
//

@interface DS3DInterpolatedTransform : DS3DTransform {
    
    GLKVector3          newPos;
    GLKQuaternion       newRot;
    GLKVector3          newScl;
    
@private
    GLKVector3          oldPos;
    GLKQuaternion       oldRot;
    GLKVector3          oldScl;
}

- (void)interpolate:(float)alpha;

@property(nonatomic) GLKVector3 pos;
@property(nonatomic) GLKQuaternion rot;
@property(nonatomic) GLKVector3 scl;

@end


//
//  protocol DSTransformStore
//
//  Classes adopting this protocol must provide a mechanism
//  for adding to and removing transforms from an internal store.
//

@protocol DSTransformStore <NSObject>

- (void)addTransform:(DSTransform *)transform;
- (void)remTransform:(DSTransform *)transform;

@end


//
//  Interpolation utility functions
//
//  These are provided so that longer period interpolations can be performed and
//  so that non-interpolated transorms can have interpolation applied.
//

static inline void DSInterpolate2DTransform(DS2DTransform *destTrans, DS2DTransform *oldTrans, DS2DTransform *newTrans, float alpha) {

    // Interpolate position
    destTrans.pos = GLKVector2Lerp(oldTrans.pos, newTrans.pos, alpha);

    // Interpolate rotation
    destTrans.rot = oldTrans.rot + (newTrans.rot - oldTrans.rot) * alpha;

    // Interpolate scaling
    destTrans.scl = GLKVector2Lerp(oldTrans.scl, newTrans.scl, alpha);
}

static inline void DSInterpolate3DTransform(DS3DTransform *destTrans, DS3DTransform *old, DS3DTransform *newTrans, float alpha) {

    // Interpolate position
    destTrans.pos = GLKVector3Lerp(old.pos, newTrans.pos, alpha);

    // Interpolate rotation
    destTrans.rot = GLKQuaternionSlerp(old.rot, newTrans.rot, alpha);

    // Interpolate scaling
    destTrans.scl = GLKVector3Lerp(old.scl, newTrans.scl, alpha);
}