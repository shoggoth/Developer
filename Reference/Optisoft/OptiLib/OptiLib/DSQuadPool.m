//
//  DSQuadPool.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSQuadPool.h"
#import "DSShader.h"


#pragma mark Triangle mesh

@implementation DSQuadPool {
    
    // Provided from initialisation parameters
    unsigned                triangleCount;                      // Number of triangles in this mesh
    
    // Internally calculated
    unsigned int            vertexSize;                         // Size of one vertex (bytes)
}

- (instancetype)init {
    
    if ((self = [super init])) {

        // Set default mode to dynamic
        _mode = GL_DYNAMIC_DRAW;
        
        // Store mesh parameters
        // baseScale = 1.0f;

        // transformArray = [NSMutableArray new];
    }
    
    return self;
}

- (void)dealloc {
    
    self.triangleProcessors = nil;
}

#pragma mark Initialisation

- (void)describeVerticesInContext:(DSDrawContext *)context {

    int            stride = vertexSize;

    // VAO vertex position (always at location 0)
    GLint attributeLocation = [context.shader getAttributeLocation:@"position"];
    glEnableVertexAttribArray(attributeLocation);
    glVertexAttribPointer(attributeLocation, 3, GL_FLOAT, GL_FALSE, stride, 0);

    // VAO vertex normal
    attributeLocation = [context.shader getAttributeLocation:@"normal"];
    if (attributeLocation > 0) {
        glEnableVertexAttribArray(attributeLocation);
        glVertexAttribPointer(attributeLocation, 3, GL_FLOAT, GL_FALSE, stride, glVBOBufferOffset(12));
    }

    // VAO vertex texture coordinates set 0
    attributeLocation = [context.shader getAttributeLocation:@"tc_0"];
    if (attributeLocation > 0) {
        glEnableVertexAttribArray(attributeLocation);
        glVertexAttribPointer(attributeLocation, 2, GL_FLOAT, GL_FALSE, stride, glVBOBufferOffset(24));
    }
}

#pragma mark Drawing

- (void)drawVerticesInContext:(DSDrawContext *)context {

    // Draw the triangles (not indexed)
    glDrawArrays(GL_TRIANGLES, 0, 3 * triangleCount);
}

#pragma mark Buffering

- (long)vertexBufferSize {

    return 3 * triangleCount * vertexSize;
}

- (void)fillVertexBuffer:(void *)vboBuffer {
}

@end


@implementation DSColouredQuadPool

@end
