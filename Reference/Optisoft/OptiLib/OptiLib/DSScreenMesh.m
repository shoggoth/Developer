//
//  DSScreenMesh.m
//  OptiLib
//
//  Created by Richard Henry on 17/12/2015.
//  Copyright © 2015 Optisoft. All rights reserved.
//

#import "DSScreenMesh.h"
#import "DSShader.h"


@implementation DSScreenMesh {

    DSTriMeshProcessorFunc  vertexGen;
}

- (instancetype)initWithQuadCount:(unsigned)qc {

    if ((self = [super initWithVertexCount:qc * 6 vertexSize:sizeof(GLKVector2) modulo:6])) {

        // 2D vertex generator
        vertexGen = ^(GLvoid *triangleBuffer, unsigned count, unsigned modulo) {

            GLKVector2 *triangleVertex = triangleBuffer;

            for (int i = 0; i < count; i++) {

                int vertexNumber = i % 6;

                if (vertexNumber == 0 || vertexNumber == 3) {

                    *triangleVertex = (GLKVector2) { -0.5, -0.5 };

                } else if (vertexNumber == 1) {

                    *triangleVertex = (GLKVector2) { 0.5, -0.5 };

                } else if (vertexNumber == 2 || vertexNumber == 4) {

                    *triangleVertex = (GLKVector2) { 0.5, 0.5 };

                } else if (vertexNumber == 5) {
                    
                    *triangleVertex = (GLKVector2) { -0.5, 0.5 };
                }
                
                triangleVertex++;
            }
        };
    }

    return self;
}

- (void)dealloc {

    self.triangleProcessors = nil;
}

#pragma mark Initialisation

- (void)describeVerticesInContext:(DSDrawContext *)context {

    // VAO vertex position (always at location 0)
    GLint attributeLocation = [context.shader getAttributeLocation:@"position"];
    glEnableVertexAttribArray(attributeLocation);
    glVertexAttribPointer(attributeLocation, 2, GL_FLOAT, GL_FALSE, vertexSize, 0);
}

#pragma mark Overrides

- (void)fillVertexBuffer:(void *)vboBuffer {

    vertexGen(vboBuffer, vertexCount, modulo);

    [super fillVertexBuffer:vboBuffer];
}

@end
