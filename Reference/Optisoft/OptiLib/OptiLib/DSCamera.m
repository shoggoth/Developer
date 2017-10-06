//
//  DSCamera.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSCamera.h"
#import "DSDrawContext.h"
#import "DSMaths.h"


#pragma mark Camera node

@implementation DSCameraNode

- (instancetype)init {

    if ((self = [super init])) {

        // Default aspect
        self.aspect = 0;

        // Default near and far clips
        self.near = 0;
        self.far = 1;
    }

    return self;
}

- (void)dealloc {

    self.transform = nil;
}

#pragma mark Drawing

- (void)drawInContext:(DSDrawContext *)context {

    if (scene) {

        // Save current projection and transform matrices
        GLKMatrix4      oldProjection = context.projectionMatrix;
        GLKMatrix4      oldTransform = context.transformMatrix;

        // Set projection
        context.projectionMatrix = [self projectionInDrawContext:context];

        if (self.transform) {

            // Calculate camera world transform
            bool transformIsInvertable;
            GLKMatrix4 inverseTransform = GLKMatrix4Invert(self.transform.transformMatrix, &transformIsInvertable);

            if (transformIsInvertable) context.transformMatrix = GLKMatrix4Multiply(oldTransform, inverseTransform);

            // Recalculate culling frustum if culling is enabled
            if (context.frustumCulling) [context recalculateViewFrustum];
        }

        [scene drawInContext:context];

        // Restore projection and transform matrices
        context.projectionMatrix = oldProjection;
        context.transformMatrix = oldTransform;
    }

    if (chain) [chain drawInContext:context];
}

- (GLKMatrix4)projectionInDrawContext:(DSDrawContext *)context {

    float aspect = self.aspect;

    if (!aspect) aspect = context.aspect;

    return GLKMatrix4MakeOrtho(-aspect, aspect, -1, 1, self.near, self.far);  // lrbtnf
}

@end

#pragma mark - Perspective camera

@implementation DSPerspectiveCameraNode

- (instancetype)init {

    if ((self = [super init])) {

        // Default property values
        self.fov = 60 * kDSDegreesToRadians;
    }

    return self;
}

- (GLKMatrix4)projectionInDrawContext:(DSDrawContext *)context {

    float aspect = self.aspect;

    if (!aspect) aspect = context.aspect;

    return GLKMatrix4MakePerspective(self.fov, aspect, self.near, self.far);
}

@end

#pragma mark - Orthographic camera

@implementation DSOrthographicCameraNode

- (instancetype)init {

    if ((self = [super init])) {

        // Default property values
        self.dimensions = CGRectMake(-1, -1, 2, 2);
    }

    return self;
}

- (GLKMatrix4)projectionInDrawContext:(DSDrawContext *)context {

    float aspect = self.aspect;

    if (!aspect) aspect = context.aspect;

    float l = CGRectGetMinX(_dimensions);
    float r = CGRectGetMaxX(_dimensions);
    float t = CGRectGetMaxY(_dimensions);
    float b = CGRectGetMinY(_dimensions);

    return GLKMatrix4MakeOrtho(aspect * l, aspect * r, b, t, self.near, self.far);  // lrbtnf
}

@end