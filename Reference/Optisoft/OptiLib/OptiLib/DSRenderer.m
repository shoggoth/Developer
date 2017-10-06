//
//  DSRenderer.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSRenderer.h"

#pragma mark Node renderer

@implementation DSNodeRenderer

@synthesize context = context;

- (void)dealloc {

    // Release the scenegraph
    self.scene = nil;

    // Get rid of our reference to the draw context
    self.context = nil;
}

#pragma mark Rendering

- (void)prerender {

    [context clearBuffers];
}

- (void)render {

    [self.scene drawInContext:context];
}

@end

#pragma mark - Ping-pong renderer

@implementation DSPingPongRenderer {

    CGSize                  textureSize;
    BOOL                    hasDepthBuffer;

    GLuint                  frameBuffers[2];
    GLuint                  depthBuffer;
    GLuint                  textures[2];
}

@synthesize context = context;

- (void)createBuffersOfSize:(CGSize)ts {

    // Initialisation
    textureSize = ts;
    hasDepthBuffer = context.depthTest;

    // Exisiting bound frame buffer GET!
    GLint oldFBO; glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFBO);

    // Create the ping pong buffers and textures
    glGenFramebuffers(2, frameBuffers);
    glGenTextures(2, textures);

    // We can re-use the depth buffer as we clear it each time and so we only need to have one of them.
    if (hasDepthBuffer) {

        glGenRenderbuffers(1, &depthBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthBuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, ts.width, ts.height);
    }

    // Attach the textures to each of the framebuffers
    for (int i = 0; i < 2; i++) {

        const GLint     levelOfDetail = 0;
        const GLint     border = 0;

        glBindFramebuffer(GL_FRAMEBUFFER, frameBuffers[i]);
        glBindTexture(GL_TEXTURE_2D, textures[i]);

        // Set texture parameters
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

        // Create the texture
        glTexImage2D(GL_TEXTURE_2D, levelOfDetail, GL_RGBA, ts.width, ts.height, border, GL_RGBA, GL_UNSIGNED_BYTE, NULL);

#if defined (DEBUG)
        // Label it for debugging
        char string[255];
        snprintf(string, 255, "Pingpong RTT %d", i);
        glLabelObjectEXT(GL_TEXTURE, textures[i], 0, string);
#endif

        // Attach to the FBO colour attachment 0 and shared depth
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, textures[i], 0);

        if (hasDepthBuffer) {

            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthBuffer);
        }

        // Check FBO status
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {

            NSLog(@"Warning: failed to make complete framebuffer object %x for pingpong %d", glCheckFramebufferStatus(GL_FRAMEBUFFER), i);
        }
    }

    // Rebind the old FBO and restore
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, oldFBO);
}

- (void)dealloc {

    // Delete the texture objects that we were using for the ping pong buffer
    glDeleteTextures(2, textures);
    glDeleteRenderbuffers(1, &depthBuffer);
    glDeleteFramebuffers(2, frameBuffers);

    // Get rid of our reference to the draw context
    self.context = nil;
}

#pragma mark Drawing

- (void)prerender {

    // Clearing the screen frame buffer
    [context clearBuffers];
}

- (void)render {

    static int ping = 0, pong = 1;

#if defined (DEBUG)
    glPushGroupMarkerEXT(0, "RTT");
#endif

    // Exisiting bound frame buffer GET!
    GLint oldFBO; glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFBO);
    GLint viewportRect[4]; glGetIntegerv(GL_VIEWPORT, viewportRect);

    // Bind the ping FBO
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffers[ping]);

    glViewport(0, 0, textureSize.width, textureSize.height);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // Draw the current scene into the ping texture
    [_scene drawInContext:context];

    // Turn off depth testing
    BOOL oldDepthTest = context.depthTest;
    context.depthTest = NO;

    // Then draw the deform over the top with the pong texture
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glBindTexture(GL_TEXTURE_2D, textures[pong]);
    [_deform drawInContext:context];
    glBindTexture(GL_TEXTURE_2D, 0);
    glDisable(GL_BLEND);

    // Rebind the old FBO and restore viewport
    glBindFramebuffer(GL_FRAMEBUFFER, oldFBO);
    glViewport(viewportRect[0], viewportRect[1], viewportRect[2], viewportRect[3]);

    // Draw to the screen
    glBindTexture(GL_TEXTURE_2D, textures[ping]);
    [_screen drawInContext:context];
    glBindTexture(GL_TEXTURE_2D, 0);

    // Restore depth test
    context.depthTest = oldDepthTest;
    
#if defined (DEBUG)
    glPopGroupMarkerEXT();
#endif

    pong = ping; ping++; ping = ping  % 2;
}

@end
