//
//  DSGridMesh.m
//  OptiLib
//
//  Created by Richard Henry on 16/12/2015.
//  Copyright © 2015 Optisoft. All rights reserved.
//

#import "DSGridMesh.h"

@implementation DSGridMesh {

    DSTriMeshProcessorFunc  vertexGen;
    DSTriMeshProcessorFunc  indexGen;
}

- (instancetype)initWithGridDensity:(unsigned)gridDensity vertexSize:(unsigned)vs {

    if ((self = [super initWithVertexCount:gridDensity * gridDensity
                                indexCount:(gridDensity - 1) * (gridDensity - 1) * 6
                                vertexSize:vs
                                    modulo:gridDensity])) {

        // Vertex generation
        vertexGen = ^(GLvoid *triangleBuffer, unsigned count, unsigned mod) {

            struct DSTriMeshNormTex1Vertex      *triangleVertex = triangleBuffer;
            CGPoint                             cellSize = (CGPoint) { 1.0 / (mod - 1), 1.0 / (count / (mod + 1)) };

            for (int i = 0; i < count; i++) {

                const int                   x = i % mod, y = i / mod;

                // Define in the y-z plane
                triangleVertex->pos = (GLKVector3) { cellSize.x * x, cellSize.y * y, 0 };
                triangleVertex->nor = (GLKVector3) { 0, 0, 1 };
                triangleVertex->tc0 = (GLKVector2) { cellSize.x * x, cellSize.y * y };

                triangleVertex++;
            }
        };

        // Index generation
        indexGen = ^(GLvoid *iboBuffer, unsigned count, unsigned mod) {

            GLushort *indexPtr = iboBuffer;

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
        };
    }
    
    return self;
}

#pragma mark Overrides

- (void)fillVertexBuffer:(void *)vboBuffer {

    vertexGen(vboBuffer, vertexCount, modulo);

    [super fillVertexBuffer:vboBuffer];
}

- (void)fillIndexBuffer:(void *)iboBuffer {

    indexGen(iboBuffer, indexCount, modulo);

    [super fillIndexBuffer:iboBuffer];
}

@end
