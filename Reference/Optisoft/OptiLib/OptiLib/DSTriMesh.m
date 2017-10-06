//
//  DSTriMesh.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSTriMesh.h"
#import "DSShader.h"


#pragma mark Triangle mesh

@implementation DSTriMesh

- (instancetype)initWithVertexCount:(unsigned)vc vertexSize:(unsigned)vs modulo:(unsigned)m {

    if ((self = [super init])) {

        // Set default mode to static
        self.mode = GL_STATIC_DRAW;

        // Store mesh parameters
        vertexCount = vc;
        vertexSize = vs;
        modulo = m;
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
    glDrawArrays(GL_TRIANGLES, 0, vertexCount);
}

#pragma mark Buffering

- (long)vertexBufferSize {
    
    return vertexCount * vertexSize;
}

- (void)fillVertexBuffer:(void *)vboBuffer {
    
    for (DSTriMeshProcessorFunc process in self.triangleProcessors) process(vboBuffer, vertexCount, modulo);
}

@end

#pragma mark - Indexed triangle mesh

@implementation DSIndexedTriMesh

- (instancetype)initWithVertexCount:(unsigned)vc indexCount:(unsigned)ic vertexSize:(unsigned)vs modulo:(unsigned)m {

    if ((self = [super init])) {

        // Set default mode to static
        self.mode = GL_STATIC_DRAW;

        // Store mesh parameters
        vertexCount = vc;
        vertexSize = vs;
        indexCount = ic;
        modulo = m;
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

    for (DSTriMeshProcessorFunc process in self.indexProcessors) process(iboBuffer, indexCount, modulo);
}

@end

#pragma mark - Utility

// These are general purpose triangle processors that are self-contained in that
// they do not need to capture state from the surrounding scope.

// These following functions are related to triangle vertices

// Generate a number of triangles at the origin with a unit side
DSTriMeshProcessorFunc DSTriMeshGenerateTriangles = ^(GLvoid *triangleBuffer, unsigned count, unsigned modulo) {

    struct DSTriMeshNormTex1Vertex *triangle = triangleBuffer;

    for (int i = 0; i < count / 3; i++) {

        // Vertex 0
        triangle[0].pos = (GLKVector3) { 0, 0, 0 };
        triangle[0].tc0 = (GLKVector2) { 0, 0 };

        // Vertex 1
        triangle[1].pos = (GLKVector3) { 1, 0, 0 };
        triangle[1].tc0 = (GLKVector2) { 1, 0 };

        // Vertex 2
        triangle[2].pos = (GLKVector3) { 0, 1, 0 };
        triangle[2].tc0 = (GLKVector2) { 0, 1 };

        triangle += 3;
    }
};


// Generate a number of unit quads (2 triangles) centred at the origin with a unit side
DSTriMeshProcessorFunc DSTriMeshGenerateCentredUnitQuads = ^(GLvoid *triangleBuffer, unsigned count, unsigned modulo) {

    struct DSTriMeshNormTex1Vertex *triangleVertex = triangleBuffer;

    for (int i = 0; i < count; i++) {

        int vertexNumber = i % 6;

        if (vertexNumber == 0 || vertexNumber == 3) {

            triangleVertex->pos = (GLKVector3) { -0.5, -0.5, 0 };
            triangleVertex->tc0 = (GLKVector2) { 0, 0 };

        } else if (vertexNumber == 1) {

            triangleVertex->pos = (GLKVector3) { 0.5, -0.5, 0 };
            triangleVertex->tc0 = (GLKVector2) { 1, 0 };

        } else if (vertexNumber == 2 || vertexNumber == 4) {

            triangleVertex->pos = (GLKVector3) { 0.5, 0.5, 0 };
            triangleVertex->tc0 = (GLKVector2) { 1, 1 };

        } else if (vertexNumber == 5) {

            triangleVertex->pos = (GLKVector3) { -0.5, 0.5, 0 };
            triangleVertex->tc0 = (GLKVector2) { 0, 1 };

        }

        triangleVertex++;
    }
};

DSTriMeshProcessorFunc DSTriMeshMakeQuadGenerator(const float w, const float h, const float tMin, const float tMax) {

    return ^(GLvoid *triangleBuffer, unsigned count, unsigned modulo) {

        struct DSTriMeshNormTex1Vertex *triangleVertex = triangleBuffer;

        for (int i = 0; i < count; i++) {

            int vertexNumber = i % 6;

            if (vertexNumber == 0 || vertexNumber == 3) {

                triangleVertex->pos = (GLKVector3) { -w, -h, 0 };
                triangleVertex->tc0 = (GLKVector2) { tMin, tMin };

            } else if (vertexNumber == 1) {

                triangleVertex->pos = (GLKVector3) { w, -h, 0 };
                triangleVertex->tc0 = (GLKVector2) { tMax, tMin };

            } else if (vertexNumber == 2 || vertexNumber == 4) {

                triangleVertex->pos = (GLKVector3) { w, h, 0 };
                triangleVertex->tc0 = (GLKVector2) { tMax, tMax };

            } else if (vertexNumber == 5) {
                
                triangleVertex->pos = (GLKVector3) { -w, h, 0 };
                triangleVertex->tc0 = (GLKVector2) { tMin, tMax };
                
            }
            
            triangleVertex++;
        }
    };
}

// Generate normals for triangles in the buffer
DSTriMeshProcessorFunc DSTriMeshGenerateNormals = ^(GLvoid *triangleBuffer, unsigned count, unsigned modulo) {

    struct DSTriMeshNormTex1Vertex *triangle = triangleBuffer;

    for (int i = 0; i < count / 3; i++) {

        // Calculate face normal from cross product of two vectors
        const GLKVector3 normal = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(triangle[1].pos, triangle[0].pos), GLKVector3Subtract(triangle[2].pos, triangle[0].pos)));

        // Vertex normal is the same for each face of the triangle
        triangle[0].nor = normal;
        triangle[1].nor = normal;
        triangle[2].nor = normal;

        triangle += 3;
    }
};

// These following functions are related to triangle indices

DSTriMeshProcessorFunc DSIndexedTriMeshGenerateIndices = ^(GLvoid *iboBuffer, unsigned count, unsigned modulo) {

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


