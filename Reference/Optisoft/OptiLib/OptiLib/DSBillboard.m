//
//  DSBillboard.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSBillboard.h"
#import "DSShader.h"


#pragma mark Triangle mesh

@implementation DSBillboard

- (instancetype)initWithTriangleCount:(unsigned int)tc vertexSize:(unsigned int)vs {

    if ((self = [super init])) {

        // Set default mode to static
        self.mode = GL_STATIC_DRAW;

        // Store mesh parameters
        vertexCount = tc * 3;
        vertexSize = vs;
    }

    return self;
}

- (instancetype)initWithQuadCount:(unsigned int)qc {

    return ((self = [self initWithTriangleCount:qc * 2 vertexSize:sizeof(struct DSBillboardVertex)]));
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

    // VAO vertex texture coordinates set 0
    attributeLocation = [context.shader getAttributeLocation:@"tc_0"];
    if (attributeLocation > 0) {
        glEnableVertexAttribArray(attributeLocation);
        glVertexAttribPointer(attributeLocation, 2, GL_FLOAT, GL_FALSE, stride, glVBOBufferOffset(12));
    }
}

#pragma mark Drawing

- (void)drawVerticesInContext:(DSDrawContext *)context {
    
    // Draw the triangles (not indexed)
    glDrawArrays(GL_TRIANGLES, 0, vertexCount);
}

#pragma mark Buffering

- (long)vertexBufferSize {
    
    return vertexCount * vertexSize;
}

- (void)fillVertexBuffer:(void *)vboBuffer {
    
    for (DSBillboardProcessorFunc process in self.triangleProcessors) process(vboBuffer, vertexCount);
}

@end

#pragma mark - Indexed triangle mesh

@implementation DSIndexedBillboard {

    // Provided from initialisation parameters
    unsigned                indexCount;                         // Number of indices to describe the connected mesh
}

- (instancetype)initWithVertexCount:(unsigned)vc indexCount:(unsigned)ic vertexSize:(unsigned)vs {

    if ((self = [super init])) {

        // Set default mode to static
        self.mode = GL_STATIC_DRAW;

        // Store mesh parameters
        vertexCount = vc;
        indexCount = ic;
        vertexSize = vs;
    }

    return self;
}

- (instancetype)initWithTriangleCount:(unsigned int)tc vertexSize:(unsigned int)vs {

    if ((self = [super initWithTriangleCount:tc vertexSize:vs])) {

        // Store mesh parameters
        indexCount = tc * 3;
    }

    return self;
}

- (void)dealloc {

    self.triangleProcessors = nil;
    self.indexProcessors = nil;
}

#pragma mark Drawing

- (void)drawVerticesInContext:(DSDrawContext *)context {

    // Draw the triangles (indexed)
    glDrawElements(GL_TRIANGLES, indexCount, GL_UNSIGNED_SHORT, NULL);
}

#pragma mark Buffering

- (long)indexBufferSize {

    return indexCount * sizeof(unsigned short);
}

- (void)fillIndexBuffer:(void *)iboBuffer {

    for (DSBillboardProcessorFunc process in self.indexProcessors) process(iboBuffer, indexCount);
}

@end

#pragma mark - Utility

// These are general purpose triangle processors that are self-contained in that
// they do not need to capture state from the surrounding scope.


// These following functions are related to triangle vertices

// Generate a number of unit quads (2 triangles) centred at the origin with a unit side
DSBillboardProcessorFunc DSBillboardGenerateCentredUnitQuads = ^(GLvoid *triangleBuffer, unsigned count) {

    struct DSBillboardVertex *vertex = triangleBuffer;

    for (int i = 0; i < count; i++) {

        int vertexNumber = i % 6;

        if (vertexNumber == 0 || vertexNumber == 3) {

            vertex->pos = (GLKVector3) { -0.5, -0.5, 0 };
            vertex->tc0 = (GLKVector3) { 0, 0 };

        } else if (vertexNumber == 1) {

            vertex->pos = (GLKVector3) { 0.5, -0.5, 0 };
            vertex->tc0 = (GLKVector3) { 1, 0 };

        } else if (vertexNumber == 2 || vertexNumber == 4) {

            vertex->pos = (GLKVector3) { 0.5, 0.5, 0 };
            vertex->tc0 = (GLKVector3) { 1, 1 };

        } else if (vertexNumber == 5) {

            vertex->pos = (GLKVector3) { -0.5, 0.5, 0 };
            vertex->tc0 = (GLKVector3) { 0, 1 };
        }

        vertex++;
    }
};

DSBillboardProcessorFunc DSQuadBillboardProcessorFuncMake(const float w, const float h, const float tMin, const float tMax) {

    return ^(GLvoid *triangleBuffer, unsigned count) {

        struct DSBillboardVertex *vertex = triangleBuffer;

        for (int i = 0; i < count; i++) {

            int vertexNumber = i % 6;

            if (vertexNumber == 0 || vertexNumber == 3) {

                vertex->pos = (GLKVector3) { -w, -h, 0 };
                vertex->tc0 = (GLKVector3) { tMin, tMin };

            } else if (vertexNumber == 1) {

                vertex->pos = (GLKVector3) { w, -h, 0 };
                vertex->tc0 = (GLKVector3) { tMax, tMin };

            } else if (vertexNumber == 2 || vertexNumber == 4) {

                vertex->pos = (GLKVector3) { w, h, 0 };
                vertex->tc0 = (GLKVector3) { tMax, tMax };

            } else if (vertexNumber == 5) {
                
                vertex->pos = (GLKVector3) { -w, h, 0 };
                vertex->tc0 = (GLKVector3) { tMin, tMax };
            }

            vertex++;
        }
    };
}

// These following functions are related to triangle indices

DSBillboardProcessorFunc DSIndexedBillboardGenerateIndices = ^(GLvoid *iboBuffer, unsigned count) {

    GLushort            *indices = iboBuffer;

    // Fill index buffer
    for (unsigned i = 0, index = 0; i < count; i++) {

        GLushort start = i * 4;

        // Triangle 0
        indices[index++] = start;
        indices[index++] = start + 2;
        indices[index++] = start + 3;

        // Triangle 1
        indices[index++] = start;
        indices[index++] = start + 1;
        indices[index++] = start + 2;
    }
};


