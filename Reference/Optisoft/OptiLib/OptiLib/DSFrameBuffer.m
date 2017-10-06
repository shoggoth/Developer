//
//  DSFrameBuffer.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSFrameBuffer.h"
#import "DSDrawContext.h"
#import "DSTexture.h"


#pragma mark Frame buffer object

@implementation DSFrameBuffer {

    DSTexture           *rtt;
}

- (instancetype)init {

    if ((self = [super init])) {

        // Initialisation code here
        glGenFramebuffersOES(1, &fbo);
    }

    return self;
}

- (void)dealloc {

    rtt = nil;
    if (fbo) glDeleteFramebuffers(1, &fbo);
}

#pragma mark Drawing

- (void)drawInContext:(DSDrawContext *)context {

    if (self.scene) {

        // Exisiting bound frame buffer GET!
        GLint oldFBO; glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFBO);

        // Bind the FBO for drawing
        glBindFramebuffer(GL_FRAMEBUFFER, fbo);

        // Temp
        glClearColor(1, 0, 0, 1);
        glClear(GL_COLOR_BUFFER_BIT);
        [self.scene drawInContext:context];

        // Rebind the old FBO
        glBindFramebuffer(GL_FRAMEBUFFER, oldFBO);
    }

    [self.chain drawInContext:context];
}

#pragma mark Attachments

- (void)attachTexture:(DSTexture *)texture {

    // Exisiting bound frame buffer GET!
    GLint oldFBO; glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFBO);

    // Bind it on to the framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, fbo);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture.object, 0);

    if ([self check]) rtt = texture;

    // Rebind the old FBO and restore
    glBindFramebuffer(GL_FRAMEBUFFER, oldFBO);
}

#pragma mark Integrity check

- (BOOL)check {

    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {

#if defined(DEBUG)
        NSLog(@"Warning: failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
#endif
        return NO;
    }

    return YES;
}

- (void)setScene:(NSObject<DSDrawable> *)s {

    // Exisiting bound frame buffer GET!
    GLint oldFBO; glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFBO);

    // Bind this frame buffer for the check
    glBindFramebuffer(GL_FRAMEBUFFER, fbo);

    // Bypass the FBO if it hasn't been set up properly. If this is a debug build, a warning will be emitted by the check method.
    if (!s || [self check]) [super setScene:s]; else [super setChain:s];

    // Rebind the old FBO and restore
    glBindFramebuffer(GL_FRAMEBUFFER, oldFBO);
}

@end


@implementation DSRTTFrameBuffer {

    DSTexture               *texture;
}

- (instancetype)initWithTextureSize:(CGSize)ts {

    if ((self = [super init])) {

        // Initialisation of the texture we're going to render to
        texture = [[DSTexture alloc] initWithWidth:ts.width height:ts.height textureUnit:0 options:nil];

        // Exisiting bound frame buffer GET!
        GLint oldFBO; glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFBO);

        // Bind it on to the framebuffer
        glBindFramebuffer(GL_FRAMEBUFFER, fbo);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture.object, 0);

        // Rebind the old FBO and restore
        glBindFramebuffer(GL_FRAMEBUFFER, oldFBO);
    }
    
    return self;
}

- (void)dealloc {

    texture = nil;
    if (fbo) glDeleteFramebuffers(1, &fbo);
}
@end
