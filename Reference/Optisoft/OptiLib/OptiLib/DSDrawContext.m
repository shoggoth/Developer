//
//  DSDrawContext.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSDrawContext.h"
#import "DSShader.h"
#import "DSTexture.h"
#import "DSFrustum.h"

//#define FRAME_DEBUG


@implementation DSDrawContext {

    // Convenience enum
    enum { kDSColourBuffer, kDSDepthBuffer };

    // GL properties
    EAGLContext             *glContext;
    NSArray                 *glExtensions;
    GLuint                  frameBufferObject;
    GLuint                  colourRenderBuffer, depthRenderBuffer;

    // Texturing properties
    NSMutableDictionary     *textureDictionary;

    // Shader uniforms
    enum : GLint { kDSUniformNotSet = -1, kDSUniformModelviewMatrix, kDSUniformProjectionMatrix, kDSUniformTextureMatrix, kDSUniformColourMatrix, kDSUniformNormalMatrix, kDSNumUniforms } uniforms[kDSNumUniforms];

    // Culling
    DSFrustum               frustum;

}

- (instancetype)init {

    if ((self = [super init])) {

        // Initialisation and binding of GL context
        if ((glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2]) && ([EAGLContext setCurrentContext:glContext])) {

            // Context is set up now. Record its capabilities
            NSString *extensionsString = [NSString stringWithCString:(char *)glGetString(GL_EXTENSIONS) encoding:NSASCIIStringEncoding];
            glExtensions = [extensionsString componentsSeparatedByString:@" "];

            // Set up this context's defaults
            self.depthTest = NO;
            self.frustumCulling = NO;
            self.autoSetNormalMatrix = NO;
            self.culling = kDSCullNoFaces;

            // Texturing properties initialisation
            textureDictionary = [NSMutableDictionary dictionary];
            glActiveTexture(GL_TEXTURE0);

            // Initial matrix values
            _transformMatrix = _projectionMatrix = _textureMatrix = _colourMatrix = GLKMatrix4Identity;
            _normalMatrix = GLKMatrix3Identity;

            // Register for rotation notifications so that the aspect can be calculated.
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
        }
    }

    return self;
}

- (void)dealloc {

    [self bind];

    // Delete shaders and textures
    self.shader = nil; textureDictionary = nil;

    // Delete render buffers and FBO
    if (frameBufferObject) {

        glDeleteRenderbuffers(1, &colourRenderBuffer);
        if (depthRenderBuffer) glDeleteRenderbuffers(1, &depthRenderBuffer);
        glDeleteFramebuffers(1, &frameBufferObject);
    }

    // Dispose of the GL context
    [EAGLContext setCurrentContext:nil]; glContext = nil;

    // Remove rotation observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Buffer attach

- (BOOL)attachToGLKView:(GLKView *)view {

#if defined (DEBUG)
    glPushGroupMarkerEXT(0, "DC Attach to GLKView");
#endif

    view.enableSetNeedsDisplay = NO;
    view.context = glContext;

    // Set viewport information
    _viewPortRect = (CGRect) { 0, 0, view.frame.size.width, view.frame.size.height };
    depthRenderBuffer = view.drawableDepthFormat != GLKViewDrawableDepthFormatNone;

#if defined (DEBUG)
    glPopGroupMarkerEXT();
    GLenum err = glGetError(); if (err) NSLog(@"GLerror %d (%x)", err, err);    // Check GL error once per frame
#endif

    return YES;
}

- (BOOL)attachToCAEAGLLayer:(CAEAGLLayer *)layer depthBuffer:(BOOL)depthBuffer {

#if defined (DEBUG)
    glPushGroupMarkerEXT(0, "DC Attach to layer");
#endif

    // Generate an FBO and colour renderbuffer
    if (!frameBufferObject) {

        glGenFramebuffers(1, &frameBufferObject);
        glGenRenderbuffers(1, &colourRenderBuffer);
    }
    
    // Bind FBO and colour buffer
    glBindFramebuffer(GL_FRAMEBUFFER, frameBufferObject);
    glBindRenderbuffer(GL_RENDERBUFFER, colourRenderBuffer);

    // Attach the layer as storage for the currently bound render buffer and attach the colour render buffer to the FBO
    [glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colourRenderBuffer);

    // Get the dimensions of the colour buffer.
    GLint w; glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &w);
    GLint h; glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &h);

    // If there was already a depth buffer then delete it
    if (depthRenderBuffer) { glDeleteRenderbuffers(1, &depthRenderBuffer); depthRenderBuffer = 0; }

    if (depthBuffer) {

        // Generate and bind the new depth render buffer
        glGenRenderbuffers(1, &depthRenderBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer);

        // Reserve some memory for depth buffer and attach it to the currently bound FBO
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24_OES, w, h);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderBuffer);

        // Rebind the colour render buffer
        glBindRenderbuffer(GL_RENDERBUFFER, colourRenderBuffer);
    }

    // Check framebuffer status
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {

        NSLog(@"FBO status check error: %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));

        return NO;
    }

    // Set sundry information
    _depthBuffer = depthBuffer;
    
    // Set viewport information
    _viewPortRect = (CGRect) { 0, 0, w, h };
    glViewport(0, 0, w, h);

    // Set initial aspect ratio now that the viewport is set.
    [self viewDidRotate:nil];

#if defined (DEBUG)
    glPopGroupMarkerEXT();
#endif

    return YES;
}

#pragma mark Querying capabilities

- (BOOL)supportsExtension:(NSString *)extensionName {

    return [glExtensions containsObject:extensionName];
}

- (void)dumpExtensions {

#if defined (DEBUG)
    for (NSString *str in glExtensions) NSLog(@"GL ext : %@", str);
#endif
}

#pragma mark Drawing

- (void)bind {

    // Binds are expensive so we had best check for redundancy before binding
    if ([EAGLContext currentContext] != glContext) [EAGLContext setCurrentContext:glContext];
}

- (void)flush {

    if (depthRenderBuffer) {

        static const GLenum discards[] = { GL_DEPTH_ATTACHMENT };
        glDiscardFramebufferEXT(GL_FRAMEBUFFER, 1, discards);
    }

    glBindRenderbuffer(GL_RENDERBUFFER, colourRenderBuffer);
    [glContext presentRenderbuffer:GL_RENDERBUFFER];

//    static const GLenum discards[] = { GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT };
//    glDiscardFramebufferEXT(GL_FRAMEBUFFER, (depthRenderBuffer) ? 2 : 1, discards);

#if defined (DEBUG)
    GLenum err = glGetError(); if (err) NSLog(@"glGetError error: %x", err);    // Check GL error once per frame
#if defined (FRAME_DEBUG)
    glInsertEventMarkerEXT(0, "com.apple.GPUTools.event.debug-frame");
#endif
#endif
}

#pragma mark Clearing buffers

- (void)clearColourBuffer {

    glClear(GL_COLOR_BUFFER_BIT);
}

- (void)clearColourAndDepthBuffers {

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

- (void)clearBuffers {

    glClear((depthRenderBuffer && _depthTest) ? GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT : GL_COLOR_BUFFER_BIT);
}

#pragma mark Shader

- (void)setShader:(DSShader *)shader {

    if (!(_shader = shader)) {

        // Disable shader programmes
        glUseProgram(0);

    } else {

        // Bind shader programme
        [shader bind];

        // Get standard DrawContext uniforms
        uniforms[kDSUniformProjectionMatrix] = [shader getUniformLocation:@"projectionMatrix"];
        uniforms[kDSUniformModelviewMatrix]  = [shader getUniformLocation:@"modelViewMatrix"];
        uniforms[kDSUniformTextureMatrix]    = [shader getUniformLocation:@"textureMatrix"];
        uniforms[kDSUniformColourMatrix]     = [shader getUniformLocation:@"colourMatrix"];
        uniforms[kDSUniformNormalMatrix]     = [shader getUniformLocation:@"normalMatrix"];

        // Set uniforms to existing context values
        self.transformMatrix = _transformMatrix;
        self.projectionMatrix = _projectionMatrix;
        self.textureMatrix = _textureMatrix;
        self.colourMatrix = _colourMatrix;
        self.normalMatrix = _normalMatrix;

        // Set uniforms for currently bound textures
        for (id key in textureDictionary) {

            GLint uniform = [shader getUniformLocation:key];
            assert(uniform != kDSUniformNotSet);

            DSTexture *texture = [textureDictionary objectForKey:key];
            glUniform1i(uniform, texture.unit);
        }
    }
}

#pragma mark Texture

- (DSTexture *)textureWithName:(NSString *)textureName {

    return [textureDictionary objectForKey:textureName];
}

- (void)bindTexture:(DSTexture *)texture toName:(NSString *)textureName {

    if (texture) {

        // Activate the appropriate texture unit and bind the texture
        glActiveTexture(GL_TEXTURE0 + texture.unit);
        glBindTexture(texture.target, texture.object);
        glActiveTexture(GL_TEXTURE0);

        // Add to the texture dictionary
        [textureDictionary setObject:texture forKey:textureName];

        // Set up the shader so that it can access the texture
        glUniform1i([self.shader getUniformLocation:textureName], texture.unit);

    } else [self unbindTextureWithName:textureName];
}

- (void)unbindTextureWithName:(NSString *)textureName {

    DSTexture *texture = [textureDictionary objectForKey:textureName];

    if (texture) {

        // Activate the appropriate texture unit and bind the texture to 0
        glActiveTexture(GL_TEXTURE0 + texture.unit);
        glBindTexture(texture.target, 0);
        glActiveTexture(GL_TEXTURE0);

        // Set up the shader so that it can access the texture
        glUniform1i([self.shader getUniformLocation:textureName], 0);

        // Remove from dictionary, possibly causing the texture object to be deallocated which will cause a glDeleteTextures
        [textureDictionary removeObjectForKey:textureName];
    }
}

#pragma mark Frustum

- (void)recalculateViewFrustum {

    frustum = DSFrustumMake(_transformMatrix, _projectionMatrix);
}

- (BOOL)frustumContainsSphereAtPos:(GLKVector3)pos radius:(float)radius {

    return DSSphereInCullingFrustum(frustum, pos, radius);
}

#pragma mark Rotation

- (void)viewDidRotate:(NSNotification *)notification {

    float w = self.viewPortRect.size.width, h = self.viewPortRect.size.height;

    _aspect = (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) ? w / h : h / w;
}

#pragma mark Properties

- (void)setTransformMatrix:(GLKMatrix4)t {

    _transformMatrix = t;

    if (uniforms[kDSUniformModelviewMatrix] != kDSUniformNotSet)
        glUniformMatrix4fv(uniforms[kDSUniformModelviewMatrix], 1, GL_FALSE, _transformMatrix.m);

    if (_autoSetNormalMatrix) {
#if defined (DEBUG)
        bool matrixIsInvertable;

        self.normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(_transformMatrix), &matrixIsInvertable);
        if (!matrixIsInvertable) NSLog(@"Warning: non-invertable transform matrix supplied to draw context");
#else
        // Automatically set the normal matrix if it is wanted in the shader
        self.normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(_transformMatrix), NULL);
#endif
    }
}

- (void)setProjectionMatrix:(GLKMatrix4)p {

    _projectionMatrix = p;

    if (uniforms[kDSUniformProjectionMatrix] != kDSUniformNotSet)
        glUniformMatrix4fv(uniforms[kDSUniformProjectionMatrix], 1, GL_FALSE, _projectionMatrix.m);
}

- (void)setTextureMatrix:(GLKMatrix4)t {

    _textureMatrix = t;

    if (uniforms[kDSUniformTextureMatrix] != kDSUniformNotSet)
        glUniformMatrix4fv(uniforms[kDSUniformTextureMatrix], 1, GL_FALSE, _textureMatrix.m);
}

- (void)setColourMatrix:(GLKMatrix4)c {

    _colourMatrix = c;

    if (uniforms[kDSUniformColourMatrix] != kDSUniformNotSet)
        glUniformMatrix4fv(uniforms[kDSUniformColourMatrix], 1, GL_FALSE, _colourMatrix.m);
}

- (void)setNormalMatrix:(GLKMatrix3)n {

    _normalMatrix = n;

    if (uniforms[kDSUniformNormalMatrix] != kDSUniformNotSet)
        glUniformMatrix3fv(uniforms[kDSUniformNormalMatrix], 1, GL_FALSE, _normalMatrix.m);
}

- (void)setDepthTest:(BOOL)depthTest {

#if defined (DEBUG)
    if (depthTest && !depthRenderBuffer) NSLog(@"Warning: attempting to enable depth test without a depth buffer.");
#endif
    _depthTest = depthTest;

    if (depthTest) glEnable(GL_DEPTH_TEST); else glDisable(GL_DEPTH_TEST);
}


- (void)setCulling:(DSCullType)c {

    _culling = c;

    switch (_culling) {
            
        case kDSCullNoFaces:
            glDisable(GL_CULL_FACE);
            break;
            
        case kDSCullBackFaces:
            glEnable(GL_CULL_FACE);
            glCullFace(GL_BACK);
            break;
            
        case kDSCullFrontFaces:
            glEnable(GL_CULL_FACE);
            glCullFace(GL_FRONT);
            break;
            
        case kDSCullFrontAndBackFaces:
            glEnable(GL_CULL_FACE);
            glCullFace(GL_FRONT_AND_BACK);
            break;
    }
}

@end
