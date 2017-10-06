//
//  MVRenderer.m
//  MeshViewer
//
//  Created by Richard Henry on 23/07/2014.
//  Copyright (c) 2014 Dogstar Industries. All rights reserved.
//

#import "MVRenderer.h"

#import "IDLens.h"

#import "DSMaths.h"
#import "DSCamera.h"
#import "DSShader.h"
#import "DSTexture.h"
#import "DSTrackball.h"
#import "DSGridMesh.h"
#import "DSLineMesh.h"
#import "DSScreenMesh.h"

@implementation MVRenderer {

    DSPerspectiveCameraNode     *camera;
    DSRenderNode                *axesNode;

    NSMutableArray              *modelNodes;
    DSBinaryRenderNode          *modelAttachNode;
}

#pragma mark Lifecycle

- (void)awakeFromNib {

    // Set trackball initial position and limits.
    self.trackball.transform = [[DS3DTransform alloc] initWithPos:(GLKVector3) { 0, 0, -3 }];
    self.trackball.pinchLimits = (CGPoint) { -12, -1.8 };

    // Model selection
    modelNodes = [NSMutableArray array];
}

#pragma mark Setup

- (void)setup {

    // Set up the camera
    self.scene = camera = [DSPerspectiveCameraNode new];
    camera.near = .1; camera.far = 500;
    camera.fov = 65 * kDSDegreesToRadians;

    // Set up draw context
    self.context.shader = [[DSShader alloc] initWithShaderFile:@"Coloured"];
    
    // Set up world
    DSTransformNode *worldTransform = [[DSTransformNode alloc] initWithTransform:self.trackball.transform];

    // Axes
    DSLineMesh *axes = [[DSLineMesh alloc] initWithLineCount:9];
    axes.lineProcessors = @[ DSLineMeshGenerateAxes ];
    axesNode = [[DSRenderNode alloc] initWithScene:[[DSVertexBufferObject alloc] initWithVertexSource:axes]];

    // Shader and texture
    DSShaderBind *meshShader = [DSShaderBind bindToShader:[[DSShader alloc] initWithShaderFile:@"BlinnPerFragment"]];
    DSTextureBind *texture = [DSTextureBind bindToTexture:[[DSTexture alloc] initWithImageFileName:@"textureTest.png" textureUnit:0 options:nil] name:@"texture_0"];

    // Set up scene
    meshShader.scene = texture;
    modelAttachNode = texture;

    // Make models and set initial model
    [self makeScreenMeshWithShaderNamed:@"MVPlasmaShader"];
    [self makeGridMeshWithShaderNamed:@"MVSinShader"];
    [self makeGridMeshWithShaderNamed:@"BlinnPerFragment"];
    [self makeGridMeshWithShaderNamed:@"DiffusePerVertex"];
    [self makeSphereGridMesh];
    [self makeLensModels];

    modelAttachNode.scene = [modelNodes objectAtIndex:0];

    camera.scene = worldTransform;
    worldTransform.scene = [[DSBinaryRenderNode alloc] initWithScene:meshShader chain:axesNode];
}

- (void)makeScreenMeshWithShaderNamed:(NSString *)shaderName {

    DSScreenMesh *screenMesh = [[DSScreenMesh alloc] initWithQuadCount:1];
    DSVertexBufferObject *meshVBO = [[DSVertexBufferObject alloc] initWithVertexSource:screenMesh];
    DSProgrammableRenderNode *node = [DSProgrammableRenderNode alloc];
    DSShaderBind *shaderBind = [[DSShaderBind alloc] initWithScene:node chain:nil];

    shaderBind.shader = [[DSShader alloc] initWithShaderFile:shaderName];

    node.drawBlock = ^(DSDrawContext *context) {

        int timeLoc = [context.shader getUniformLocation:@"time"];

        if (timeLoc != -1) {

            glUniform1f(timeLoc, ([DSTimer nanoTime] % (12 * kDSTimeToSeconds)) * 0.000000001f);
        }

        [meshVBO drawInContext:context];
    };
    
    [modelNodes addObject:shaderBind];
}

- (void)makeGridMeshWithShaderNamed:(NSString *)shaderName {

    DSVertexBufferObject *gridVBO = [[DSVertexBufferObject alloc] initWithVertexSource:[[DSGridMesh alloc] initWithGridDensity:32 vertexSize:sizeof(struct DSTriMeshNormTex1Vertex)]];
    DSProgrammableRenderNode *node = [DSProgrammableRenderNode alloc];
    DSShaderBind *shaderBind = [[DSShaderBind alloc] initWithScene:node chain:nil];

    shaderBind.shader = [[DSShader alloc] initWithShaderFile:shaderName];

    node.drawBlock = ^(DSDrawContext *context) {

        int timeLoc = [context.shader getUniformLocation:@"time"];

        if (timeLoc != -1) {

            glUniform1f(timeLoc, ([DSTimer nanoTime] % kDSTimeToSeconds) * 0.000000001f);
        }

        [gridVBO drawInContext:context];
    };

    [modelNodes addObject:shaderBind];
}

- (void)makeSphereGridMesh {

    GLKMatrix4 trans = GLKMatrix4MakeRotation(M_PI * 0.5, 0, 1, 0);
    trans = GLKMatrix4Translate(trans, 0, 0, 0.8);
    trans = GLKMatrix4Scale(trans, M_PI, M_PI * 2, 1);

    DSTriMeshProcessorFunc transformVertices = ^(GLvoid *triangleBuffer, unsigned count, unsigned mod) {

        struct DSTriMeshNormTex1Vertex      *triangleVertex = triangleBuffer;

        for (int i = 0; i < count; i++) {

            triangleVertex->pos = GLKMatrix4MultiplyAndProjectVector3(trans, triangleVertex->pos);

            triangleVertex++;
        }
    };

    DSTriMeshProcessorFunc transformSToRVertices = ^(GLvoid *triangleBuffer, unsigned count, unsigned mod) {

        struct DSTriMeshNormTex1Vertex      *triangleVertex = triangleBuffer;

        for (int i = 0; i < count; i++) {

            triangleVertex->pos = DSSphericalToRectangular(triangleVertex->pos);
            triangleVertex->nor = GLKVector3Normalize(triangleVertex->pos);

            triangleVertex++;
        }
    };

    unsigned gridDensity = 32;
    DSGridMesh *mesh = [[DSGridMesh alloc] initWithGridDensity:gridDensity vertexSize:sizeof(struct DSTriMeshNormTex1Vertex)];
    mesh.triangleProcessors = @[ transformVertices, transformSToRVertices ];
    DSVertexBufferObject *vbo = [[DSVertexBufferObject alloc] initWithVertexSource:mesh];
    
    [modelNodes addObject:vbo];
}

- (void)makeLensModels {

    IDLensParameters (^makeLensShape)(unsigned shape) = ^IDLensParameters(unsigned shape) {

        return (IDLensParameters) {

            .shape = shape,
            .blankDiameter = 6.5,
            .minimumThickness = 0.2,
            .eyePosition = rightEye,
            .prescription = (IDLensPrescription) {

                .sph  = 0,
                .cyl  = 0,
                .axis = 180 * kDSDegreesToRadians,
                .add  = 0
            },
            .material = (IDLensMaterial) {
                
                .refractiveIndex = 1.42
            }
        };
    };

    // Add the 8 standard lens shapes.
    for (int i = 0; i < 8; i++) { [modelNodes addObject:[[IDLensNode alloc] initWithParameters:makeLensShape(i)]]; }
}

#pragma mark DSEngineNode conformance

- (void)didAddToEngineContext:(DSEngineContext *)context {

    [context addEngineNode:self.trackball.transform];
}

- (void)didRemoveFromEngineContext:(DSEngineContext *)context {

    [context removeEngineNode:self.trackball.transform];
}

#pragma mark MVPrefsDelegate conformance

- (void)setupPreferences:(MVPrefsViewController *)prefsViewController {

    prefsViewController.cullSegControl.selectedSegmentIndex = self.context.culling;
    prefsViewController.depthTestSwitch.on = self.context.depthTest;
    prefsViewController.axesSwitch.on = axesNode.on;
    prefsViewController.modelStepper.maximumValue = modelNodes.count - 1;

    for (int i = 0; i < prefsViewController.paramLabels.count; i++) {

        UILabel *label = prefsViewController.paramLabels[i];
        UISlider *slider = prefsViewController.paramSliders[i];

        label.text = [NSString stringWithFormat:@"Param %d %.1f", i, slider.value];
    }
}

#pragma mark Preference actions

- (void)selectModel:(NSUInteger)modelIndex {

    modelAttachNode.scene = [modelNodes objectAtIndex:modelIndex];
}

- (void)selectCullingType:(DSCullType)cullType {

    self.context.culling = cullType;
}

- (void)selectDepthTest:(BOOL)depthTest {

    self.context.depthTest = depthTest;
}

- (void)selectDisplayAxes:(BOOL)axes {

    axesNode.on = axes;
}

@end
