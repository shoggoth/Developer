//
//  DSFrameBuffer.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSRenderNode.h"


@class DSTexture;

//
//  interface DSFrameBuffer
//
//  Scenegraph node representing OpenGL FBO operations
//

@interface DSFrameBuffer : DSBinaryRenderNode {

    GLuint                      fbo;
}

- (void)attachTexture:(DSTexture *)texture;
- (BOOL)check;

@end


//
//  interface DSRTTFrameBuffer
//
//  Scenegraph node representing OpenGL FBO operations
//

@interface DSRTTFrameBuffer : DSFrameBuffer

- (instancetype)initWithTextureSize:(CGSize)textureSize;

@end
