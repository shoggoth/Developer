//
//  DSLineMesh.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSVertexBuffer.h"


struct DSLineMeshVertex {

    GLKVector3      pos;                    // Position - 12 bytes, offset 0
    DSByteColour    col;                    // Colour   - 4 bytes, offset 12
};

//
//  interface DSLineMesh
//
//  Standard line mesh with distinct vertices for each of the lines in the mesh.
//

@interface DSLineMesh : NSObject <DSVertexSource> {

    // Provided from initialisation parameters
    unsigned                vertexCount;                        // Number of vertices in this mesh
    unsigned                vertexSize;                         // Size of one vertex (bytes)
}

- (instancetype)initWithLineCount:(unsigned)lineCount;

// Mesh specification
@property(nonatomic) unsigned int mode;
@property(nonatomic, readonly) long vertexBufferSize;

// Line processor functions
@property(nonatomic, strong) NSArray *lineProcessors;

@end

// Vertex line processor functions
typedef void (^DSLineMeshProcessorFunc)(GLvoid *buffer, unsigned count);

extern DSLineMeshProcessorFunc DSLineMeshGenerateAxes;