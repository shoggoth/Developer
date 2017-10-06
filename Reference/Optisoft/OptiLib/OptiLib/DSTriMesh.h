//
//  DSTriMesh.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSVertexBuffer.h"

//
//  interface DSTriMesh
//
//  Standard triangle mesh with distinct vertices for each of the triangles in the mesh.
//

@interface DSTriMesh : NSObject <DSVertexSource> {

    // Provided from initialisation parameters
    unsigned                vertexCount;                        // Number of vertices in this mesh
    unsigned                vertexSize;                         // Size of one vertex (bytes)
    unsigned                modulo;                             // Mesh modulo for width and height calculations.
}

- (instancetype)initWithVertexCount:(unsigned)vc vertexSize:(unsigned)vs modulo:(unsigned)m;

// Mesh specification
@property(nonatomic) unsigned int mode;
@property(nonatomic, readonly) long vertexBufferSize;

// Triangle processor functions
@property(nonatomic, strong) NSArray *triangleProcessors;

@end


//
//  interface DSIndexedTriMesh
//
//  Standard triangle mesh with indexed vertices organised into triangles at render time.
//

@interface DSIndexedTriMesh : DSTriMesh {

    // Provided from initialisation parameters
    unsigned                indexCount;                         // Number of indices to describe the connected mesh
}

- (instancetype)initWithVertexCount:(unsigned)vc indexCount:(unsigned)ic vertexSize:(unsigned)vs modulo:(unsigned)m;

// Mesh specification
@property(nonatomic, readonly) long indexBufferSize;

// Triangle and index processor functions
@property(nonatomic, strong) NSArray *indexProcessors;

@end

// Standard vertex format matches the generic triangle mesh vertex format.

struct DSTriMeshNormTex1Vertex {
    
    GLKVector3      pos;                    // Position - 12 bytes, offset 0
    GLKVector3      nor;                    // Normal   - 12 bytes, offset 12
    GLKVector2      tc0;                    // Texture coordinates (set 0) - 8 bytes, offset 24
};

// Vertex or index processor functions
typedef void (^DSTriMeshProcessorFunc)(GLvoid *buffer, unsigned count, unsigned modulo);

// Example TriMesh functions
extern DSTriMeshProcessorFunc DSTriMeshGenerateTriangles;
extern DSTriMeshProcessorFunc DSTriMeshGenerateCentredUnitQuads;
extern DSTriMeshProcessorFunc DSTriMeshGenerateNormals;
extern DSTriMeshProcessorFunc DSTriMeshMakeQuadGenerator(const float w, const float h, const float tMin, const float tMax);

// Example IndexedTriMesh processor functions
extern DSTriMeshProcessorFunc DSIndexedTriMeshGenerateIndices;

// MetaFunctions
