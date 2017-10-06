//
//  DSVertexBuffer.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSVertexBuffer.h"
#import "DSDrawContext.h"


#pragma mark Vertex buffer

@implementation DSVertexBufferObject {
    
    NSObject <DSVertexSource>   *vertexSource;                  // Vertex source. We'll get our vertices and indices from here
    
    GLuint                      vao;                            // Vertex array GL object
    GLuint                      vbo;                            // Vertex buffer GL object
    GLuint                      ibo;                            // Index buffer GL object

    DSShader                    *lastUsedShader;                // The shader that was last used. This is stored in case we need to rebind.
}

- (instancetype)initWithVertexSource:(NSObject <DSVertexSource> *)vs {
    
    if ((self = [super init])) {
        
        // Save the vertex source for later use
        if ((vertexSource = vs)) {

            // Generate geometry buffer objects (VBO and (optionally) IBO)
            glGenBuffers(1, &vbo);
            if ([vertexSource respondsToSelector:@selector(fillIndexBuffer:)] && vertexSource.indexBufferSize) glGenBuffers(1, &ibo); else ibo = 0;

            // Set up the VAO
            glGenVertexArraysOES(1, &vao);
            glBindVertexArrayOES(vao);

            // Fill the buffers with data
            if (vertexSource.vertexBufferSize) [self fillBuffers];

            // Unbind objects
            glBindVertexArrayOES(0);
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
            glBindBuffer(GL_ARRAY_BUFFER, 0);
        }
    }
    
    return self;
}

- (void)dealloc {
    
    vertexSource = nil;

    if (vao) glDeleteVertexArraysOES(1, &vao);

    if (vbo) glDeleteBuffers(1, &vbo);
    if (ibo) glDeleteBuffers(1, &ibo);
}

#pragma mark Drawing

- (void)drawInContext:(DSDrawContext *)context {

    if (vertexSource && vertexSource.vertexBufferSize) {

        // Bind the VBO and IBO
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        if (ibo) glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);

        // For dynamic vertex buffers, refill the buffers
        if (GL_STATIC_DRAW != vertexSource.mode) [self fillBuffers];

        // Bind the vertex array object
        glBindVertexArrayOES(vao);
        
        // If the shader has changed since the last draw, we've got to bind the attributes to the new shader.
        if (lastUsedShader != context.shader) {

            [vertexSource describeVerticesInContext:context];
            lastUsedShader = context.shader;
        }

        // Ask the vertex source to draw itself
        [vertexSource drawVerticesInContext:context];

        // Unbind the VBO and IBO
        glBindVertexArrayOES(0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        if (ibo) glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    }
}

#pragma mark Buffering

- (void)fillBuffers {

    GLenum mode = vertexSource.mode;
    
    // Bind the new VBO and allocate enough space for its storage
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, vertexSource.vertexBufferSize, NULL, mode);
    
    // Map the vertex buffer
    GLvoid *vboBuffer = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    assert(vboBuffer);
    
    // Fill the vertex buffer with interleaved data
    [vertexSource fillVertexBuffer:vboBuffer];
    
    // Unmap and unbind the vertex buffer
    glUnmapBufferOES(GL_ARRAY_BUFFER);
    
    if (ibo) {
        
        GLsizeiptr iboSize = vertexSource.indexBufferSize;
        
        // Bind the new IBO and allocate enough space for its storage
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, iboSize, NULL, mode);
        
        // Map the index buffer
        GLushort *iboBuffer = glMapBufferOES(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
        assert(iboBuffer);
        
        // Fill index buffer
        [vertexSource fillIndexBuffer:iboBuffer];
        
        // Unmap and unbind the index buffer but leave them bound for further possible drawing operations
        glUnmapBufferOES(GL_ELEMENT_ARRAY_BUFFER);
    }
}

@end

#pragma mark - Utility

GLvoid *glVBOBufferOffset(unsigned int offset) { return ((GLvoid *)((char *)NULL + (offset))); }
