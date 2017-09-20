//
//  SLViewController.m
//  ShaderLab
//
//  Created by Richard Henry on 15/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#import "SLViewController.h"
#import "DSDrawContext.h"
#import "DSRenderer.h"
#import "DSTexture.h"
#import "DSTriMesh.h"
#import "DSEngine.h"
#import "DSShader.h"

#import "SLActor.h"


@implementation SLViewController {

    // Drawing
    //DSDrawContext               *context;
    //DSVertexBufferObject        *vbo;
    SLActor                     *actor;

    // Engine
    DSEngine                    *engine;

    // Shaders
    NSArray                     *shaderNames;
    unsigned                    shaderIndex;

    // Timing for shader
    float                       time;
    GLint                       timeUniform;

    // Vertex description
    struct DSTriMeshVertex {

        GLKVector3      pos;                    // Position - 12 bytes, offset 0
        GLKVector3      nor;                    // Normal   - 12 bytes, offset 12
        GLKVector2      tc0;                    // Texture coordinates (set 0) - 8 bytes, offset 24
    };
}

#pragma mark UIViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    // Initialise locals
    time = 0;
    shaderNames = @[ @"Frags", @"Texturing", @"Measure", @"SkyBlobs", @"Red" ];

    // Create and set up GL context
    DSDrawContext *context = [DSDrawContext new];

    if (context) {

        [context attachToGLKView:(GLKView *)self.view];
        [context bind];

        // Set up draw context
        [self setupDrawContext:context];

    } else NSLog(@"Failed to create ES context");

    self.preferredFramesPerSecond = 60;

    // temp
    actor = [SLActor new];
    actor.slName = @"bollox";

    actor.tickFunction = ^(DSActor *a) {

        NSLog(@"Init %@", ((SLActor *)a).slName);

        __block int updateCount = 5;

        a.tickFunction = ^(DSActor *a) {

            NSLog(@"Update %@ (%d)", ((SLActor *)a).slName, updateCount);

            updateCount--;

            if (!updateCount) a.tickFunction = ^(DSActor *a) {
                
                NSLog(@"Dealloc %@", ((SLActor *)a).slName);
                a.tickFunction = nil;
            };
        };

        NSLog(@"After Object = %@", ((SLActor *)a).slName);
    };
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];

    // If the view is loaded but it doesn't have a window associated with it, we can get rid of it
    if (self.isViewLoaded && !self.view.window) { [self tearDownGL]; self.view = nil; }
}

#pragma mark GL Setup

- (void)setupGLNew {

    glClearColor(0.2f, 0.6f, 0.9f, 1.0f);
}

- (void)setupDrawContext:(DSDrawContext *)context {

    // Setup rendere
    DSNodeRenderer *renderer = [DSNodeRenderer new];
    renderer.context = context;

    // Setup engine
    engine = [DSEngine new];
    engine.context = [DSEngineContext new];
    engine.renderer = renderer;

    // Load shader
    context.shader = [[DSShader alloc] initWithShaderFile:shaderNames[shaderIndex]];

    // Load mesh
    DSTriMesh *mesh = [[DSTriMesh alloc] initWithTriangleCount:2 vertexSize:sizeof(struct DSTriMeshVertex)];
    mesh.triangleProcessors = @[ [self makeUnitQuad] ];

    // Vertex buffer object
    renderer.scene = [[DSVertexBufferObject alloc] initWithVertexSource:mesh];
    [renderer.scene addToDrawContext:context];

    // Fixed shader uniforms
    GLint mvpUniform = [context.shader getUniformLocation:@"modelViewProjectionMatrix"];
    if (mvpUniform >= 0) {

        // Projection matrix
        GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, 1, 0, 1, 0, 1);

        // Modelview matrix
        GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;

        // MVP matrix
        GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
        glUniformMatrix4fv(mvpUniform, 1, 0, modelViewProjectionMatrix.m);

        GLint normalUniform = [context.shader getUniformLocation:@"normalMatrix"];
        if (normalUniform > 0) {

            GLKMatrix3 normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
            glUniformMatrix3fv(normalUniform, 1, 0, normalMatrix.m);
        }
    }

    timeUniform = [context.shader getUniformLocation:@"time"];

    [context bindTexture:[[DSTexture alloc] initWithImageFileName:@"textureTest.png" textureUnit:0] toName:@"texture_0"];
    [context bindTexture:[[DSTexture alloc] initWithImageFileName:@"alphaTest.png" textureUnit:1] toName:@"texture_1"];

    glClearColor(0.2f, 0.6f, 0.9f, 1.0f);

    if (NO) {
        // Node test
        DSProgrammableRenderNode *node = [DSProgrammableRenderNode new];

        node.scene = [DSRenderNode new];
        node.chain = [DSRenderNode new];

        node.drawBlock = ^(DSRenderNode *node, DSDrawContext *ctx) {

            NSLog(@"PRN context = %@ (%@)", ctx, context);
            NSLog(@"PRN self = %@", self);
            NSLog(@"PRN node = %@", node);

            [node.scene drawInContext:ctx];
            [node.chain drawInContext:ctx];

            return YES;
        };

        // Call draw
        [node drawInContext:context];
    }
}

- (void)tearDownGL {

    engine = nil;
}

#pragma mark GLKViewController

- (void)update {

    time += self.timeSinceLastUpdate;

    // Update shader uniforms
    if (timeUniform > 0) glUniform1f(timeUniform, time);

    [actor tick];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {

    // Clear the buffers
    //glClear(GL_COLOR_BUFFER_BIT);

    // Draw the mesh VBO
    //[vbo drawInContext:context];

    [engine tick];
}

- (IBAction)nextShader:(UIButton *)sender {

    time = 0;
    shaderIndex = ++shaderIndex % shaderNames.count;

    [self setupDrawContext:engine.renderer.context];
}

#pragma mark Triangle processors

- (DSTriMeshProcessorFunc)makeUnitQuad {

    // Mesh processors
    return ^(void *triangleBuffer, unsigned count) {

        struct DSTriMeshVertex *triangleVertex = triangleBuffer;

        for (int i = 0; i < count * 3; i++) {

            int vertexNumber = i % 6;

            if (vertexNumber == 0) {

                triangleVertex->pos = (GLKVector3) { 0, 0, 0 };
                triangleVertex->nor = (GLKVector3) { 0, 0, 1 };
                triangleVertex->tc0 = (GLKVector2) { 0, 0 };

            } else if (vertexNumber == 1 || vertexNumber == 3) {

                triangleVertex->pos = (GLKVector3) { 1, 0, 0 };
                triangleVertex->nor = (GLKVector3) { 0, 0, 1 };
                triangleVertex->tc0 = (GLKVector2) { 1, 0 };

            } else if (vertexNumber == 2 || vertexNumber == 5) {

                triangleVertex->pos = (GLKVector3) { 0, 1, 0 };
                triangleVertex->nor = (GLKVector3) { 0, 0, 1 };
                triangleVertex->tc0 = (GLKVector2) { 0, 1 };

            } else if (vertexNumber == 4) {
                
                triangleVertex->pos = (GLKVector3) { 1, 1, 0 };
                triangleVertex->nor = (GLKVector3) { 0, 0, 1 };
                triangleVertex->tc0 = (GLKVector2) { 1, 1 };
                
            }
            
            triangleVertex++;
        }
    };
}

@end
