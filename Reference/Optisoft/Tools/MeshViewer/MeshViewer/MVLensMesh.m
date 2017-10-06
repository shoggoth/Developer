//
//  MVLensMesh.m
//  MeshViewer
//
//  Created by Richard Henry on 23/07/2014.
//  Copyright (c) 2014 Dogstar Industries. All rights reserved.
//

#import "MVLensMesh.h"
#import "DSMaths.h"


// Vertex description
struct MVLensMeshVertex {

    GLKVector3      pos;                    // Position - 12 bytes, offset 0
    GLKVector3      nor;                    // Normal   - 12 bytes, offset 12
    GLKVector2      tc0;                    // Texture coordinates (set 0) - 8 bytes, offset 24
};

// Index description
typedef unsigned short MVLensMeshIndex;
// Utility functions
static void dumpVertexBuffer(struct MVLensMeshVertex *triangleBuffer, unsigned count);
static void dumpIndexBuffer(MVLensMeshIndex *indexBuffer, unsigned count);

// Constants
static float kMVTextureScale = 1;

// Processors
static void(^sphericalToRectangular)(struct MVLensMeshVertex *, unsigned) =  ^(struct MVLensMeshVertex *buffer, unsigned count) {

    for (struct MVLensMeshVertex *vertex = buffer; vertex < &buffer[count]; vertex++) {

        vertex->tc0 = GLKVector2Make(1 - vertex->pos.y, vertex->pos.z);
        vertex->pos = DSSphericalToRectangular(GLKVector3Make(vertex->pos.x, vertex->pos.y * (2 * M_PI), vertex->pos.z * M_PI));
        vertex->nor = GLKVector3Normalize(vertex->pos);
    }
};

static void(^cylindricalToRectangular)(struct MVLensMeshVertex *, unsigned) =  ^(struct MVLensMeshVertex *buffer, unsigned count) {

    for (struct MVLensMeshVertex *vertex = buffer; vertex < &buffer[count]; vertex++) {

        vertex->tc0 = GLKVector2Make(vertex->pos.y / (2 * M_PI), vertex->pos.z / M_PI);
        vertex->pos = DSCylindricalToRectangular(GLKVector3Make(vertex->pos.x, vertex->pos.y * (2 * M_PI), -vertex->pos.z));
        vertex->nor = GLKVector3Normalize(GLKVector3Make(vertex->pos.x, vertex->pos.y, 0));
    }
};

#pragma mark - Lens front/back mesh

@implementation MVLensMesh

- (instancetype)init {

    const unsigned x = 64, y = 64;

    const unsigned modulo = x + 1;
    const unsigned vc = modulo * (y + 1);
    const unsigned ic = x * y * 6;

    if ((self = [super initWithVertexCount:vc indexCount:ic vertexSize:sizeof(struct MVLensMeshVertex)])) {

        // Triangle processing setup
        self.triangleProcessors = @[ [self generateMeshWithDimensions:(CGRect) { 0, 0, 1, 0.7 } radius:0.9 modulo:modulo], sphericalToRectangular ];

        // Index processing setup
        self.indexProcessors = @[ [self generateMeshIndicesForModulo:modulo] ];
    }

    return self;
}

#pragma mark Vertex generation

- (void(^)(struct MVLensMeshVertex *, unsigned))generateMeshWithDimensions:(CGRect)dims radius:(float)radius modulo:(unsigned)modulo {

    return ^(struct MVLensMeshVertex *triangleBuffer, unsigned count) {

        struct MVLensMeshVertex     *triangleVertex = triangleBuffer;
        CGPoint                     cellSize = (CGPoint) { dims.size.width / (modulo - 1), dims.size.height / (count / (modulo + 1)) };
        CGPoint                     texSize = (CGPoint) { 1.0 / (modulo - 1), 1.0 / (count / (modulo + 1)) };

        for (int i = 0; i < count; i++) {

            const int                   x = i % modulo, y = i / modulo;

            // Define in the y-z plane
            triangleVertex->pos = (GLKVector3) { radius, dims.origin.x + cellSize.x * x, dims.origin.y + cellSize.y * y };
            triangleVertex->nor = (GLKVector3) { 1, 0, 0 };
            triangleVertex->tc0 = (GLKVector2) { texSize.x * x * kMVTextureScale, texSize.y * y * kMVTextureScale };

            triangleVertex++;
        }

        if (NO) dumpVertexBuffer(triangleBuffer, count);
    };
}

#pragma mark Index generation

- (void(^)(MVLensMeshIndex *, unsigned))generateMeshIndicesForModulo:(unsigned)modulo {

    return ^(MVLensMeshIndex *indexBuffer, unsigned count) {

        MVLensMeshIndex *indexPtr = indexBuffer;

        // For each of the divisions…
        for (int i = 0; i < count / 6; i++) {

            const int quadBase = i + (i / (modulo - 1));

            // Triangle lower
            *indexPtr++ = quadBase;
            *indexPtr++ = quadBase + 1 + modulo;
            *indexPtr++ = quadBase + 1;

            // Triangle upper
            *indexPtr++ = quadBase;
            *indexPtr++ = quadBase + modulo;
            *indexPtr++ = quadBase + 1 + modulo;
        }

        if (NO) dumpIndexBuffer(indexBuffer, count);
    };
}

@end


#pragma mark - Utilities

static void dumpVertexBuffer(struct MVLensMeshVertex *triangleBuffer, unsigned count) {
    
    NSLog(@"%d vertices", count);
    
    for (struct MVLensMeshVertex *v = triangleBuffer; v < &triangleBuffer[count]; v++) {
        
        NSLog(@"vpos x %f y %f z %f", v->pos.x, v->pos.y, v->pos.z);
    }
}

static void dumpIndexBuffer(MVLensMeshIndex *indexBuffer, unsigned count) {
    
    NSLog(@"%d indices", count);
    
    for (MVLensMeshIndex *i = indexBuffer; i < &indexBuffer[count]; i += 3) {
        
        NSLog(@"index %d %d %d", i[0], i[1], i[2]);
    }
}

