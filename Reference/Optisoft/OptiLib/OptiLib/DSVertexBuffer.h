//
//  DSVertexBuffer.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSDrawContext.h"


//
//  protocol DSVertexSource
//
//  TODO: document this
//

@protocol DSVertexSource <NSObject>

@optional
// Index buffer handling and sizing info (optional)
@property(nonatomic, readonly) long indexBufferSize;
- (void)fillIndexBuffer:(void *)iboBuffer;

@required
// Vertex buffer handling and sizing info (required)
@property(nonatomic, readonly) long vertexBufferSize;
- (void)fillVertexBuffer:(void *)vboBuffer;

// Describing of attributes as demanded by the VAO should be done in here
- (void)describeVerticesInContext:(DSDrawContext *)context;

// Drawing vertices with shader support
- (void)drawVerticesInContext:(DSDrawContext *)context;

// Draw mode (static or dynamic)
@property(nonatomic) unsigned int mode;

@end


//
//  interface DSVertexBufferObject
//
//  TODO: document this
//

@interface DSVertexBufferObject : NSObject <DSDrawable>

- (instancetype)initWithVertexSource:(NSObject <DSVertexSource> *)vertexSource;

- (void)drawInContext:(DSDrawContext *)context;

@end

// Utility functions for vertex source subclasses
extern GLvoid *glVBOBufferOffset(unsigned int offset);

// Utility types for vertex source subclasses
typedef struct { unsigned char r, g, b, a; } DSByteColour;

