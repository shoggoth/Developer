//
//  DSQuadPool.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSVertexBuffer.h"


//
//  struct DSSpriteVertex
//
//  TODO: document this
//

typedef struct {

    GLfloat                 x, y;                   // Position - interpolated
    GLfloat                 s, t;                   // Multitexture coordinates - set 1

} DSSpriteVertex;

typedef struct {

    GLfloat                 x, y;                   // Position - interpolated
    GLfloat                 s, t;                   // Multitexture coordinates - set 1
    unsigned char           r, g, b, a;             // Colour

} DSColouredSpriteVertex;

//
//  interface DSQuadPool
//
//  Standard triangle mesh with distinct vertices for each of the triangles in the mesh.
//

@interface DSQuadPool : NSObject <DSVertexSource>

// Mesh specification
@property(nonatomic) unsigned int mode;
@property(nonatomic, readonly) long vertexBufferSize;

// Triangle processor functions
@property(nonatomic, strong) NSArray *triangleProcessors;

@end


//
//  interface DSColouredQuadPool
//
//  Standard triangle mesh with distinct vertices for each of the triangles in the mesh.
//

@interface DSColouredQuadPool : DSQuadPool

// Triangle processor functions
@property(nonatomic, strong) NSArray *indexProcessors;

@end
