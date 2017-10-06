//
//  IDLensMesh.m
//  iDispense
//
//  Created by Richard Henry on 23/07/2014.
//  Copyright (c) 2014 Dogstar Industries. All rights reserved.
//

#import "IDLensMesh.h"
#import "IDOMAShapes.h"

#import "DSMaths.h"


// Vertex description
struct IDLensMeshVertex {

    GLKVector3      pos;                    // Position - 12 bytes, offset 0
    GLKVector3      nor;                    // Normal   - 12 bytes, offset 12
    GLKVector2      tc0;                    // Texture coordinates (set 0) - 8 bytes, offset 24
};

// Index description
typedef unsigned short IDLensMeshIndex;

// Constants
const float kIDCylinderDivisor = 0.05;
const float kIDLensShapeAngleBias = M_PI * -0.5;


// Utility functions
static void dumpVertexBuffer(struct IDLensMeshVertex *triangleBuffer, unsigned count);
static void dumpIndexBuffer(IDLensMeshIndex *indexBuffer, unsigned count);

// Processors
static void(^sphericalToRectangular)(struct IDLensMeshVertex *, unsigned) =  ^(struct IDLensMeshVertex *buffer, unsigned count) {

    for (struct IDLensMeshVertex *vertex = buffer; vertex < &buffer[count]; vertex++) {

        vertex->tc0 = GLKVector2Make(1 - vertex->tc0.s, vertex->tc0.t);
        vertex->pos = DSSphericalToRectangular(GLKVector3Make(vertex->pos.x, vertex->pos.y * (2 * M_PI), vertex->pos.z * M_PI));
        vertex->nor = GLKVector3Normalize(vertex->pos);
    }
};

static void(^cylindricalToRectangular)(struct IDLensMeshVertex *, unsigned) =  ^(struct IDLensMeshVertex *buffer, unsigned count) {

    for (struct IDLensMeshVertex *vertex = buffer; vertex < &buffer[count]; vertex++) {

        vertex->tc0 = GLKVector2Make(1 - vertex->tc0.s, vertex->tc0.t);
        vertex->pos = DSCylindricalToRectangular(GLKVector3Make(vertex->pos.x, vertex->pos.y * (2 * M_PI), -vertex->pos.z));
        vertex->nor = GLKVector3Normalize(GLKVector3Make(vertex->pos.x, vertex->pos.y, 0));
    }
};

#pragma mark - Lens front/back mesh

@implementation IDLensMesh

- (instancetype)init {

    return [self initWithWidth:64 height:16];
}

- (instancetype)initWithWidth:(const unsigned)width height:(const unsigned)height  {

    // Calculate modulo and vertex and index counts.
    modulo = width + 1;

    const unsigned vc = modulo * (height + 1);
    const unsigned ic = width * height * 6;

    return [super initWithVertexCount:vc indexCount:ic vertexSize:sizeof(struct IDLensMeshVertex) modulo:modulo];
}

#pragma mark Lens mesh makers

- (void)makeFrontMeshWithParameters:(IDLensParameters)parameters {

    // Triangle processors
    void (^makeLensShape)(struct IDLensMeshVertex *, unsigned, unsigned) = ^(struct IDLensMeshVertex *buffer, unsigned count, unsigned mod) {

        struct IDLensMeshVertex     *vertex = buffer;
        const float                 thetaIncrement = (M_PI * 2) / (mod - 1);
        const float                 radiusIncrement = 1.0 / (count / mod - 1);

        for (int i = 0; i < count; i++) {

            float theta = (i % mod) * thetaIncrement;
            float shapeRadius = radiusIncrement * (i / mod) * lensShapeRadius(parameters.shape, parameters.eyePosition, theta, kIDLensShapeAngleBias);
            float phi = asinf(shapeRadius / (parameters.grind.baseSphereRadius - parameters.grind.baseSagitta));
            float texMult = (parameters.eyePosition == leftEye) ? -.5 : .5;

            GLKVector3 s = DSSphericalToRectangular(GLKVector3Make(parameters.grind.baseSphereRadius, theta, phi));

            // Create the lens curve
            GLKVector2 shapeCoords = DSPolarToRectangular(GLKVector2Make(shapeRadius, theta));
            vertex->pos = GLKVector3Make(shapeCoords.x, shapeCoords.y, s.z);
            vertex->tc0 = GLKVector2Make(vertex->pos.x * texMult + 1., vertex->pos.y * .5 + .5);
            vertex->nor = vertex->nor = GLKVector3Normalize(vertex->pos);

            // Reduce to z
            vertex->pos.z -= parameters.grind.baseSphereRadius - parameters.grind.thickness * 0.5;
            vertex->pos.z += parameters.grind.baseSagitta;

            vertex++;
        }
    };

    // Triangle processing setup
    self.triangleProcessors = @[ makeLensShape ];

    // Index processing setup
    self.indexProcessors = @[ [self generateMeshIndices] ];
}

- (void)makeBackMeshWithParameters:(IDLensParameters)parameters {

    const float midPoint = parameters.grind.thickness * 0.5;
    const GLKVector4 cylinderAxis = cylinderAxisPlaneForGrind(parameters);

    // Triangle processors
    void (^makeLensShape)(struct IDLensMeshVertex *, unsigned, unsigned) = ^(struct IDLensMeshVertex *buffer, unsigned count, unsigned mod) {

        struct IDLensMeshVertex     *vertex = buffer;
        const float                 thetaIncrement = (M_PI * 2) / (mod - 1);
        const float                 radiusIncrement = 1.0 / (count / mod - 1);

        for (int i = 0; i < count; i++) {

            float theta = (i % mod) * thetaIncrement;
            float shapeRadius = radiusIncrement * (i / mod) * lensShapeRadius(parameters.shape, parameters.eyePosition, theta, kIDLensShapeAngleBias);
            float phi = asinf(shapeRadius / (parameters.grind.backSphereRadius - parameters.grind.backSagitta));

            GLKVector3 s = DSSphericalToRectangular(GLKVector3Make(parameters.grind.backSphereRadius, theta, phi));

            // Create the lens curve
            GLKVector2 shapeCoords = DSPolarToRectangular(GLKVector2Make(shapeRadius, theta));
            vertex->pos = GLKVector3Make(shapeCoords.x, shapeCoords.y, s.z);
            vertex->tc0 = GLKVector2Make(0, 0);
            vertex->nor = GLKVector3Negate(GLKVector3Normalize(vertex->pos));

            // Reduce to z
            vertex->pos.z -= parameters.grind.backSphereRadius;
            vertex->pos.z -= midPoint;

            // Work out the cylinder amount
            vertex->pos.z -= (1 - cosf(DSPointPlaneDistance(vertex->pos, cylinderAxis))) * parameters.grind.cylPower * kIDCylinderDivisor;

            vertex++;
        }
    };

    // Triangle processing setup
    self.triangleProcessors = @[ makeLensShape ];

    // Index processing setup
    self.indexProcessors = @[ [self generateMeshBackIndices] ];
}

- (void)makeSideMeshWithParameters:(IDLensParameters)parameters {

    const float midPoint = parameters.grind.thickness * 0.5;
    const GLKVector4 cylinderAxis = cylinderAxisPlaneForGrind(parameters);

    // Triangle processors
    void (^makeLensShape)(struct IDLensMeshVertex *, unsigned, unsigned) = ^(struct IDLensMeshVertex *buffer, unsigned count, unsigned mod) {

        struct IDLensMeshVertex     *vertex = buffer;
        const float                 thetaIncrement = (M_PI * 2) / (mod - 1);
        const float                 hIncrement = 1.0 / (count / mod - 1);

        for (int i = 0; i < count; i++) {

            const float theta = (i % mod) * thetaIncrement;
            const float shapeRadius = lensShapeRadius(parameters.shape, parameters.eyePosition, theta, kIDLensShapeAngleBias);
            const float basePhi = asinf(shapeRadius / (parameters.grind.baseSphereRadius - parameters.grind.baseSagitta));
            const float backPhi = asinf(shapeRadius / (parameters.grind.backSphereRadius - parameters.grind.backSagitta));
            const float alpha = hIncrement * (i / mod);

            // Create the lens curve
            GLKVector2 shapeCoords = DSPolarToRectangular(GLKVector2Make(shapeRadius, theta));

            // Work out the base h (z coordinate)
            GLKVector3 v = DSSphericalToRectangular(GLKVector3Make(parameters.grind.baseSphereRadius, theta, basePhi));
            float baseH = v.z;
            baseH -= parameters.grind.baseSphereRadius - parameters.grind.thickness * 0.5;
            baseH += parameters.grind.baseSagitta;

            // Work out the back h (z coordinate)
            v = DSSphericalToRectangular(GLKVector3Make(parameters.grind.backSphereRadius, theta, backPhi));
            float backH = v.z;
            backH -= parameters.grind.backSphereRadius;
            backH -= midPoint;
            backH -= (1 - cosf(DSPointPlaneDistance(GLKVector3Make(shapeCoords.x, shapeCoords.y, backH), cylinderAxis))) * parameters.grind.cylPower * kIDCylinderDivisor;

            // Interpolate betwwen the base and back coordinates
            float h = baseH + (backH - baseH) * alpha;

            // Calculate position, normal and texture coordinates
            vertex->pos = GLKVector3Make(shapeCoords.x, shapeCoords.y, h);
            vertex->tc0 = GLKVector2Make(0, 0);
            vertex->nor = GLKVector3Normalize(GLKVector3Make(vertex->pos.x, vertex->pos.y, 0));

            vertex++;
        }
    };

    // Triangle processing setup
    self.triangleProcessors = @[ makeLensShape ];

    // Index processing setup
    self.indexProcessors = @[ [self generateMeshIndices] ];
}

#pragma mark Vertex generation

- (void(^)(struct IDLensMeshVertex *, unsigned, unsigned))generateIndexMeshWithDimensions:(CGRect)dims textureScale:(CGPoint)textureScale radius:(float)radius {

    return ^(struct IDLensMeshVertex *triangleBuffer, unsigned count, unsigned mod) {

        struct IDLensMeshVertex     *triangleVertex = triangleBuffer;
        CGPoint                     cellSize = (CGPoint) { dims.size.width / (mod - 1), dims.size.height / (count / (mod + 1)) };
        CGPoint                     texSize = (CGPoint) { 1.0 / (mod - 1), 1.0 / (count / (mod + 1)) };

        for (int i = 0; i < count; i++) {

            const int                   x = i % mod, y = i / mod;

            // Define in the y-z plane
            triangleVertex->pos = (GLKVector3) { radius, dims.origin.x + cellSize.x * x, dims.origin.y + cellSize.y * y };
            triangleVertex->nor = (GLKVector3) { 1, 0, 0 };
            triangleVertex->tc0 = (GLKVector2) { texSize.x * x * textureScale.x, texSize.y * y * textureScale.y };

            triangleVertex++;
        }

        if (/* DISABLES CODE */ (NO)) dumpVertexBuffer(triangleBuffer, count);
    };
}

#pragma mark Index generation

- (void(^)(IDLensMeshIndex *, unsigned, unsigned))generateMeshIndices {

    return ^(IDLensMeshIndex *indexBuffer, unsigned count, unsigned mod) {

        IDLensMeshIndex *indexPtr = indexBuffer;

        // For each of the divisions…
        for (int i = 0; i < count / 6; i++) {

            const int quadBase = i + (i / (mod - 1));

            // Triangle lower
            *indexPtr++ = quadBase;
            *indexPtr++ = quadBase + 1 + mod;
            *indexPtr++ = quadBase + 1;

            // Triangle upper
            *indexPtr++ = quadBase;
            *indexPtr++ = quadBase + mod;
            *indexPtr++ = quadBase + 1 + mod;
        }

        if (/* DISABLES CODE */ (NO)) dumpIndexBuffer(indexBuffer, count);
    };
}

- (void(^)(IDLensMeshIndex *, unsigned, unsigned))generateMeshBackIndices {

    return ^(IDLensMeshIndex *indexBuffer, unsigned count, unsigned mod) {

        IDLensMeshIndex *indexPtr = indexBuffer;

        // For each of the divisions…
        for (int i = 0; i < count / 6; i++) {

            const int quadBase = i + (i / (mod - 1));

            // Triangle lower
            *indexPtr++ = quadBase;
            *indexPtr++ = quadBase + 1;
            *indexPtr++ = quadBase + 1 + mod;

            // Triangle upper
            *indexPtr++ = quadBase;
            *indexPtr++ = quadBase + 1 + mod;
            *indexPtr++ = quadBase + mod;
        }

        if (/* DISABLES CODE */ (NO)) dumpIndexBuffer(indexBuffer, count);
    };
}

@end

#pragma mark - Utilities

static void dumpVertexBuffer(struct IDLensMeshVertex *triangleBuffer, unsigned count) {

    NSLog(@"%d vertices", count);

    for (struct IDLensMeshVertex *v = triangleBuffer; v < &triangleBuffer[count]; v++) {

        NSLog(@"vpos x %f y %f z %f", v->pos.x, v->pos.y, v->pos.z);
    }
}

static void dumpIndexBuffer(IDLensMeshIndex *indexBuffer, unsigned count) {

    NSLog(@"%d indices", count);
    
    for (IDLensMeshIndex *i = indexBuffer; i < &indexBuffer[count]; i += 3) {
        
        NSLog(@"index %d %d %d", i[0], i[1], i[2]);
    }
}

#pragma mark TEMP

@implementation IDDemoLensMesh

- (instancetype)init {

    if ((self = [super init])) {

        // Initialisation code here
        void (^makeBaseMesh)(struct IDLensMeshVertex *, unsigned, unsigned) = [self generateIndexMeshWithDimensions:(CGRect) { 0, 0, 1, 1 } textureScale:(CGPoint) { 1, 1 }  radius:0.9];

        // Triangle processing setup
        self.triangleProcessors = @[ makeBaseMesh, sphericalToRectangular];

        // Index processing setup
        self.indexProcessors = @[ [self generateMeshIndices] ];
    }

    return self;
}


@end
