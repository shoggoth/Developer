//
//  DSLineMesh.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSLineMesh.h"
#import "DSShader.h"


#pragma mark Line mesh

@implementation DSLineMesh

- (instancetype)initWithLineCount:(unsigned int)lc {
    
    if ((self = [super init])) {

        // Set default mode to static
        self.mode = GL_STATIC_DRAW;
        
        // Store mesh parameters
        vertexCount = lc * 2;
        vertexSize = sizeof(struct DSLineMeshVertex);
    }
    
    return self;
}

- (void)dealloc {
    
    self.lineProcessors = nil;
}

#pragma mark Initialisation

- (void)describeVerticesInContext:(DSDrawContext *)context {

    int            stride = vertexSize;

    // VAO vertex position (always at location 0)
    GLint attributeLocation = [context.shader getAttributeLocation:@"position"];
    glEnableVertexAttribArray(attributeLocation);
    glVertexAttribPointer(attributeLocation, 3, GL_FLOAT, GL_FALSE, stride, 0);

    // VAO vertex normal
    attributeLocation = [context.shader getAttributeLocation:@"colour"];
    if (attributeLocation > 0) {
        glEnableVertexAttribArray(attributeLocation);
        glVertexAttribPointer(attributeLocation, 4, GL_UNSIGNED_BYTE, GL_TRUE, stride, glVBOBufferOffset(12));
    }
}

#pragma mark Drawing

- (void)drawVerticesInContext:(DSDrawContext *)context {
    
    // Draw the lines (not indexed)
    glDrawArrays(GL_LINES, 0, vertexCount);
}

#pragma mark Buffering

- (long)vertexBufferSize {
    
    return vertexCount * vertexSize;
}

- (void)fillVertexBuffer:(void *)vboBuffer {
    
    for (DSLineMeshProcessorFunc process in self.lineProcessors) process(vboBuffer, vertexCount);
}

@end

#pragma mark - Utility

// Generate a number of lines at the origin with a unit side
DSLineMeshProcessorFunc DSLineMeshGenerateAxes = ^(GLvoid *lineBuffer, unsigned count) {

    struct DSLineMeshVertex *line = lineBuffer;

    const float axisLength = 1, headSize = .023;

    const GLKVector3 origin = (GLKVector3) { 0, 0, 0 };

    const DSByteColour red = (DSByteColour) { 255, 0, 0, 255 };
    const DSByteColour grn = (DSByteColour) { 0, 255, 0, 255 };
    const DSByteColour blu = (DSByteColour) { 0, 0, 255, 255 };

    // X
    GLKVector3 end = (GLKVector3) { axisLength, 0, 0 };
    line[0].pos = origin; line[0].col = red;
    line[1].pos = end; line[1].col = red;

    line[2].pos = end; line[2].col = red;
    line[3].pos = (GLKVector3) { axisLength - headSize, +headSize, 0 }; line[3].col = red;
    line[4].pos = end; line[4].col = red;
    line[5].pos = (GLKVector3) { axisLength - headSize, -headSize, 0 }; line[5].col = red;

    // Y
    end = (GLKVector3) { 0, axisLength, 0 };
    line[6].pos = origin; line[6].col = grn;
    line[7].pos = end; line[7].col = grn;

    line[8].pos = end; line[8].col = grn;
    line[9].pos = (GLKVector3) { +headSize, axisLength - headSize, 0 }; line[9].col = grn;
    line[10].pos = end; line[10].col = grn;
    line[11].pos = (GLKVector3) { -headSize, axisLength - headSize, 0 }; line[11].col = grn;

    // Z
    end = (GLKVector3) { 0, 0, axisLength };
    line[12].pos = origin; line[12].col = blu;
    line[13].pos = end; line[13].col = blu;

    line[14].pos = end; line[14].col = blu;
    line[15].pos = (GLKVector3) { 0, +headSize, axisLength - headSize }; line[15].col = blu;
    line[16].pos = end; line[16].col = blu;
    line[17].pos = (GLKVector3) { 0, -headSize, axisLength - headSize }; line[17].col = blu;
};
