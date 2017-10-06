//
//  DSTransform.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSTransform.h"


#pragma mark Transform

@implementation DSTransform

- (instancetype)init {
    
    if ((self = [super init])) {
        
        transformMatrix = GLKMatrix4Identity;
    }
    
    return self;
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<%@: 0x%x | tm: %x>", [self class], (unsigned)self, (unsigned)&transformMatrix];
}

@synthesize transformMatrix;

@end


#pragma mark - 2D Transformations

@implementation DS2DTransform

- (instancetype)init {
    
    if ((self = [super init])) {
        
        self.scl = (GLKVector2) { 1, 1 };
    }
    
    return self;
}

- (instancetype)initWithPos:(GLKVector2)p {
    
    if ((self = [super init])) {
        
        self.pos = p;
        self.scl = (GLKVector2) { 1, 1 };
    }
    
    return self;
}

- (instancetype)initWithPos:(GLKVector2)p rot:(float)r {
    
    if ((self = [super init])) {
        
        self.pos = p;
        self.rot = r;
        self.scl = (GLKVector2) { 1, 1 };
    }
    
    return self;
}

- (instancetype)initWithPos:(GLKVector2)p rot:(float)r scl:(GLKVector2)s {
    
    if ((self = [super init])) {
        
        self.pos = p;
        self.rot = r;
        self.scl = s;
    }
    
    return self;
}

- (NSString*)description {
    
    return [NSString stringWithFormat:@"<%@: 0x%x | rot: %f | x: %f y %f | sx: %f sy %f>", [self class], (unsigned)self, rot, pos.x, pos.y, scl.x, scl.y];
}

@dynamic transformMatrix;

- (GLKMatrix4)transformMatrix {

    transformMatrix = GLKMatrix4Translate(GLKMatrix4Identity, pos.x, pos.y, 0);
    transformMatrix = GLKMatrix4RotateZ(transformMatrix, rot);
    transformMatrix = GLKMatrix4Scale(transformMatrix, scl.x, scl.y, 1);

    return transformMatrix;
}

@synthesize pos;
@synthesize rot;
@synthesize scl;

@end

#pragma mark Interpolated

@implementation DS2DInterpolatedTransform

- (instancetype)init {
    
    if ((self = [super init])) {
        
        self.scl = (GLKVector2) { 1, 1 };
    }
    
    return self;
}

- (instancetype)initWithPos:(GLKVector2)p {
    
    if ((self = [super init])) {
        
        self.pos = p;
        self.scl = (GLKVector2) { 1, 1 };
    }
    
    return self;
}

- (instancetype)initWithPos:(GLKVector2)p rot:(float)r {
    
    if ((self = [super init])) {
        
        self.pos = p;
        self.rot = r;
        self.scl = (GLKVector2) { 1, 1 };
    }
    
    return self;
}

- (instancetype)initWithPos:(GLKVector2)p rot:(float)r scl:(GLKVector2)s {
    
    if ((self = [super init])) {
        
        self.pos = p;
        self.rot = r;
        self.scl = s;
    }
    
    return self;
}

- (void)interpolate:(float)alpha {
    
    // Interpolate position
    pos = GLKVector2Lerp(oldPos, newPos, alpha);

    // Interpolate rotation
    rot = oldRot + (newRot - oldRot) * alpha;

    // Interpolate scaling
    scl = GLKVector2Lerp(oldScl, newScl, alpha);
}

@dynamic pos;
@dynamic rot;
@dynamic scl;

- (GLKVector2)pos { return pos; }

- (void)setPos:(GLKVector2)p {
    
    oldPos = newPos;
    newPos = p;
}

- (float)rot { return rot; }

- (void)setRot:(float)r {
    
    oldRot = newRot;
    newRot = r;
}

- (GLKVector2)scl { return scl; }

- (void)setScl:(GLKVector2)s {
    
    oldScl = newScl;
    newScl = s;
}

@end

#pragma mark - 3D Transformations

@implementation DS3DTransform

- (instancetype)init {
    
    if ((self = [super init])) {
        
        self.pos = (GLKVector3) { 0, 0, 0 };
        self.rot = GLKQuaternionIdentity;
        self.scl = (GLKVector3) { 1, 1, 1 };
    }
    
    return self;
}

- (instancetype)initWithPos:(GLKVector3)p {
    
    if ((self = [super init])) {
        
        self.pos = p;
        self.rot = GLKQuaternionIdentity;
        self.scl = (GLKVector3) { 1, 1, 1 };
    }
    
    return self;
}

- (instancetype)initWithPos:(GLKVector3)p rot:(GLKQuaternion)r {
    
    if ((self = [super init])) {
        
        self.pos = p;
        self.rot = r;
        self.scl = (GLKVector3) { 1, 1, 1 };
    }
    
    return self;
}

- (instancetype)initWithPos:(GLKVector3)p rot:(GLKQuaternion)r scl:(GLKVector3)s {
    
    if ((self = [super init])) {
        
        self.pos = p;
        self.rot = r;
        self.scl = s;
    }
    
    return self;
}

- (NSString*)description {
    
    return [NSString stringWithFormat:@"<%@: 0x%x | rot: %f,%f,%f,%f | x: %f y %f z: %f | sx: %f sy %f sz: %f>", [self class], (unsigned)self, rot.w, rot.x, rot.y, rot.z, pos.x, pos.y, pos.z, scl.x, scl.y, scl.z];
}

@dynamic transformMatrix;

- (GLKMatrix4)transformMatrix {

    GLKMatrix4 rotMatrix = GLKMatrix4MakeWithQuaternion(rot);

    transformMatrix = GLKMatrix4TranslateWithVector3(GLKMatrix4Identity, pos);
    transformMatrix = GLKMatrix4Multiply(transformMatrix, rotMatrix);
    transformMatrix = GLKMatrix4ScaleWithVector3(transformMatrix, scl);

    return transformMatrix;
}

@synthesize pos;
@synthesize rot;
@synthesize scl;

@end

#pragma mark Interpolated

@implementation DS3DInterpolatedTransform

- (instancetype)init {
    
    if ((self = [super init])) {
        
        self.pos = (GLKVector3) { 0, 0, 0 };
        self.rot = GLKQuaternionIdentity;
        self.scl = (GLKVector3) { 1, 1, 1 };
    }
    
    return self;
}

- (instancetype)initWithPos:(GLKVector3)p {
    
    if ((self = [super initWithPos:p])) {
        
        self.pos = p;
        self.rot = GLKQuaternionIdentity;
        self.scl = (GLKVector3) { 1, 1, 1 };
    }
    
    return self;
}

- (instancetype)initWithPos:(GLKVector3)p rot:(GLKQuaternion)r {
    
    if ((self = [super initWithPos:p rot:r])) {
        
        self.pos = p;
        self.rot = r;
        self.scl = (GLKVector3) { 1, 1, 1 };
    }
    
    return self;
}

- (instancetype)initWithPos:(GLKVector3)p rot:(GLKQuaternion)r scl:(GLKVector3)s {
    
    if ((self = [super initWithPos:p rot:r scl:s])) {
        
        self.pos = p;
        self.rot = r;
        self.scl = s;
    }
    
    return self;
}

- (void)interpolate:(float)alpha {
    
    // Interpolate position
    pos = GLKVector3Lerp(oldPos, newPos, alpha);

    // Interpolate rotation
    rot = GLKQuaternionSlerp(oldRot, newRot, alpha);

    // Interpolate scaling
    scl = GLKVector3Lerp(oldScl, newScl, alpha);
}

@dynamic pos;
@dynamic rot;
@dynamic scl;

- (GLKVector3)pos { return pos; }

- (void)setPos:(GLKVector3)p {
    
    oldPos = newPos;
    newPos = p;
}

- (GLKQuaternion)rot { return rot; }

- (void)setRot:(GLKQuaternion)r {
    
    oldRot = newRot;
    newRot = r;
}

- (GLKVector3)scl { return scl; }

- (void)setScl:(GLKVector3)s {
    
    oldScl = newScl;
    newScl = s;
}

@end