//
//  DSBillboard.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSVertexBuffer.h"


struct DSBillboardVertex {

    GLKVector3      pos;                    // Position - 12 bytes, offset 0
    GLKVector3      tc0;                    // Texture coordinates (set 0) - 8 bytes, offset 12
};

//
//  interface DSBillboard
//
//  Standard triangle mesh with distinct vertices for each of the triangles in the mesh.
//

@interface DSBillboard : NSObject <DSVertexSource> {

    // Provided from initialisation parameters
    unsigned                vertexCount;                        // Number of vertices in this mesh
    unsigned                vertexSize;                         // Size of one vertex (bytes)
}

// Initialisers
- (instancetype)initWithTriangleCount:(unsigned)triangleCount vertexSize:(unsigned)vertexSize;  // Designated
- (instancetype)initWithQuadCount:(unsigned int)qc; // Convenience

// Mesh specification
@property(nonatomic) unsigned int mode;
@property(nonatomic, readonly) long vertexBufferSize;

// Triangle processor functions
@property(nonatomic, strong) NSArray *triangleProcessors;

@end


//
//  interface DSIndexedBillboard
//
//  Standard triangle mesh with indexed vertices organised into triangles at render time.
//

@interface DSIndexedBillboard : DSBillboard

- (instancetype)initWithVertexCount:(unsigned)vertexCount indexCount:(unsigned)indexCount vertexSize:(unsigned)vertexSize;

// Mesh specification
@property(nonatomic, readonly) long indexBufferSize;

// Triangle and index processor functions
@property(nonatomic, strong) NSArray *indexProcessors;

@end


// Vertex or index processor functions
typedef void (^DSBillboardProcessorFunc)(GLvoid *buffer, unsigned count);

extern DSBillboardProcessorFunc DSBillboardTest;
extern DSBillboardProcessorFunc DSBillboardGenerateTriangles;
extern DSBillboardProcessorFunc DSBillboardGenerateCentredUnitQuads;

extern DSBillboardProcessorFunc DSIndexedBillboardGenerateIndices;

// MetaFunctions
extern DSBillboardProcessorFunc DSQuadBillboardProcessorFuncMake(const float w, const float h, const float tMin, const float tMax);