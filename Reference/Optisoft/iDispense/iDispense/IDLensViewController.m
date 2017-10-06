//
//  IDLensViewController.m
//  iDispense
//
//  Created by Richard Henry on 11/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#import "IDLensViewController.h"
#import "IDDioptreValues.h"
#import "IDLensMesh.h"

#import "DSEngine.h"
#import "DSShader.h"
#import "DSTexture.h"
#import "DSTriMesh.h"
#import "DSMaths.h"
#import "DSVertexBuffer.h"
#import "DSFrameBuffer.h"
#import "DSCamera.h"


// Vertex description
struct DSTriMeshVertex {

    GLKVector3      pos;                    // Position - 12 bytes, offset 0
    GLKVector3      nor;                    // Normal   - 12 bytes, offset 12
    GLKVector2      tc0;                    // Texture coordinates (set 0) - 8 bytes, offset 24
};

// Index description
typedef unsigned short DSTriMeshIndex;


// Local
static const float kToolViewHideOffset = -430;

@interface IDLensViewController ()

@end

@implementation IDLensViewController {

    DSEngine            *engine;

    DS3DTransform       *worldTransform;
    GLKQuaternion       rotation;
    GLKVector3          translation;

    // Gesture recognisers
    __weak IBOutlet UISwipeGestureRecognizer    *swipeRightGestureRecogniser;
    __weak IBOutlet UISwipeGestureRecognizer    *swipeLeftGestureRecogniser;
    __weak IBOutlet UIPanGestureRecognizer      *panGestureRecogniser;
    __weak IBOutlet UIPinchGestureRecognizer    *pinchGestureRecogniser;
    __weak IBOutlet UIRotationGestureRecognizer *rotateGestureRecogniser;

    // Tool view
    __weak IBOutlet UIView                      *toolView;
    __weak IBOutlet IDDioptreValues             *dioptreValuePicker;
    __weak IBOutlet NSLayoutConstraint          *bottomGuideConstraint;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {

    if (self = [super initWithCoder:decoder]) {

        // Set to safe values
        worldTransform = [DS3DInterpolatedTransform new];
        rotation = GLKQuaternionIdentity;
        translation = (GLKVector3) { 0, 0, -30 };

        // Set up the engine
        engine = [DSEngine new];
        engine.context = [DSEngineContext new];
        engine.simulatorTickRate = 20 * kDSTimeToMilliseconds;
    }

    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    // Set up the parameters of this view controller
    [self setupViewController];

    [self setupRenderer];

    // Set up updates
    [engine.context addEngineNode:self];
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

    [dioptreValuePicker removeObserver:self forKeyPath:@"leftEyeDioptreValue"];

    [engine.context removeEngineNode:self];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

#pragma mark Rendering

float foo, bar = 0.05;

- (void)update {

    if (foo > 1 || foo < 0) bar = -bar; foo += bar;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {

    [engine tick];
}

#pragma mark Engine

- (void)sync {

    //rotation = GLKQuaternionMultiply(rotation, GLKQuaternionMakeWithAngleAndVector3Axis(0.023, kDSZAxis));

    worldTransform.rot = rotation;
    worldTransform.pos = translation;
}

#pragma mark Actions

- (IBAction)dismissOverlay:(UIButton *)button {

    static BOOL toolsShown = NO;

    if (toolsShown) {

        [UIView animateWithDuration:.42
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{

                             bottomGuideConstraint.constant = kToolViewHideOffset;
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) { toolsShown = NO; }];

    } else {

        [UIView animateWithDuration:.42
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{

                             bottomGuideConstraint.constant = 0;
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) { toolsShown = YES; }];
    }
}

#pragma mark Gesture Actions

- (IBAction)swipeGesture:(UISwipeGestureRecognizer *)swipe {

    if (swipe.direction == UISwipeGestureRecognizerDirectionRight)

        translation.x = 100;

    else if (swipe.direction == UISwipeGestureRecognizerDirectionLeft)

        translation.x = 0;
}

- (IBAction)panGesture:(UIPanGestureRecognizer *)pan {

    static CGPoint  lastPosition;
    static CGPoint  trackBallPosition;

    CGPoint position = [pan translationInView:pan.view.superview];

    if (pan.state == UIGestureRecognizerStateBegan) lastPosition = position;

    else {

        CGPoint delta = CGPointMake(position.x - lastPosition.x, position.y - lastPosition.y);

        trackBallPosition.x += (delta.x / self.view.frame.size.width) * M_PI;
        trackBallPosition.y += (delta.y / self.view.frame.size.height) * M_PI;

        rotation = GLKQuaternionMultiply(GLKQuaternionIdentity, GLKQuaternionMakeWithAngleAndVector3Axis(trackBallPosition.y, kDSXAxis));
        rotation = GLKQuaternionMultiply(rotation, GLKQuaternionMakeWithAngleAndVector3Axis(trackBallPosition.x, kDSYAxis));

        lastPosition = position;
    }
}

- (IBAction)pinchGesture:(UIPinchGestureRecognizer *)pinch {

    // Get the pinch gesture scaling factor in the gesture recogniser's view's superview
    static CGFloat lastScale = 1;

    if (pinch.state == UIGestureRecognizerStateEnded) lastScale = 1;

    else {

        NSLog(@"Pinch = %@", pinch);

        translation.z /= 1.0f - (lastScale - pinch.scale);

        lastScale = pinch.scale;
    }
}

- (IBAction)rotateGesture:(UIRotationGestureRecognizer *)rotate {

    // Get the rotate gesture scaling factor in the gesture recogniser's view's superview
    static CGFloat lastRotation = 0;

    if (rotate.state == UIGestureRecognizerStateEnded) lastRotation = 0;

    else {

        NSLog(@"Rotate = %@", rotate);
    }
}

#pragma mark UIGestureRecognizerDelegate conformance

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

    // Pan gestures and swipe gestures should be recognised at the same time.
    if (gestureRecognizer == pinchGestureRecogniser && (otherGestureRecognizer == swipeLeftGestureRecogniser || otherGestureRecognizer == swipeRightGestureRecogniser)) return YES;
    if (gestureRecognizer == rotateGestureRecogniser && (otherGestureRecognizer == swipeLeftGestureRecogniser || otherGestureRecognizer == swipeRightGestureRecogniser)) return YES;

    // Pan gestures and pinch gestures should be recognised at the same time.
    if (gestureRecognizer == panGestureRecogniser && (otherGestureRecognizer == pinchGestureRecogniser || otherGestureRecognizer == rotateGestureRecogniser)) return YES;

    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

    // Pan gestures require swipe gestures to fail.
    if (gestureRecognizer == pinchGestureRecogniser && (otherGestureRecognizer == swipeLeftGestureRecogniser || otherGestureRecognizer == swipeRightGestureRecogniser)) return YES;

    return NO;
}


#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    NSNumber *number = [change objectForKey:NSKeyValueChangeNewKey];
}

#pragma mark Setup

- (void)setupViewController {

    [dioptreValuePicker addObserver:self forKeyPath:@"leftEyeDioptreValue" options:NSKeyValueObservingOptionNew context:NULL];

    // Set up the interface's initial state
    bottomGuideConstraint.constant = kToolViewHideOffset;
}


- (void)setupRenderer {

    // Set up the drawing context
    DSDrawContext *drawContext = [[DSDrawContext alloc] initWithView:(GLKView *)self.view];
    drawContext.depthTest = YES;
    drawContext.autoSetNormalMatrix = YES;
    drawContext.culling = kDSCullBackFaces;

    // Set up the renderer
#if TRUE
    DSPingPongRenderer *renderer = [DSPingPongRenderer new];
    renderer.context = drawContext;

    [renderer createBuffersOfSize:(CGSize) { 256, 256 }];

    // Make the deformation graph
    DSShaderBind *deformShader = [DSShaderBind bindToShader:[[DSShader alloc] initWithShaderFile:@"Deform"]];

    DSTriMesh *deformMesh = [[DSTriMesh alloc] initWithTriangleCount:2 vertexSize:sizeof(struct DSTriMeshVertex)];
    deformMesh.triangleProcessors = @[DSQuadTriMeshProcessorFuncMake(1.01, 1.01, 0, 1), DSTriMeshGenerateNormals];

    renderer.deform = deformShader;
    deformShader.scene = [[DSVertexBufferObject alloc] initWithVertexSource:deformMesh];

    // Make the renderer screen graph
    DSShaderBind *screenShader = [DSShaderBind bindToShader:[[DSShader alloc] initWithShaderFile:@"Screen"]];

    DSTriMesh *screenMesh = [[DSTriMesh alloc] initWithTriangleCount:2 vertexSize:sizeof(struct DSTriMeshVertex)];
    screenMesh.triangleProcessors = @[DSQuadTriMeshProcessorFuncMake(1.0, 1.0, 0, 1), DSTriMeshGenerateNormals];

    renderer.screen = screenShader;
    screenShader.scene = [[DSVertexBufferObject alloc] initWithVertexSource:screenMesh];

#else
    DSNodeRenderer *renderer = [DSNodeRenderer new];
    renderer.context = drawContext;
#endif

    engine.renderer = renderer;

    // Set up the scene graph
    DSShader *shader = [[DSShader alloc] initWithShaderFile:@"BlinnPerFragment"];

    DSTexture *texture0 = [[DSTexture alloc] initWithWidth:16 height:16 textureUnit:0 options:@{ @"kDSTextureFillSetupBlock" : ^(GLsizei w, GLsizei h, GLvoid *pixelBuffer) {

        unsigned int *pixels = pixelBuffer;

        for (int y = 0; y < h; y++) {

            unsigned char random = rand();
            unsigned char mask = 0b1 << (w / 2 - 1);

            for (int x = 0; x < w; x++) {

                if (random & mask)
                    *pixels = 0xffffffff; // AABBGGRR
                else
                    *pixels = 0xff000000; // AABBGGRR

                mask = (x < w / 2) ? mask >> 1 : mask << 1;
                if (!mask) mask = 0b1;
                pixels++;
            }
        }

    }, @"kDSTextureParamSetupBlock" : ^{

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);
    }}];

    // Camera
    DSCamera *camera = [DSCamera new];
    camera.perspective = YES;
    [camera perspectiveFOVY:90 aspect:self.view.frame.size.width / self.view.frame.size.height];
    [camera clipNear:0.1 far:1000];

    // World Transform
    DSTransformNode *worldTransformNode = [DSTransformNode new];
    worldTransformNode.transform = worldTransform;
    [engine.context addEngineNode:worldTransformNode.transform];

    // Binds
    DSTextureBind *tBind = [DSTextureBind bindToTexture:texture0 name:@"texture_0"]; // TODO add texture binds to multiple textures with a dictionary.
    DSShaderBind *sBind = [DSShaderBind bindToShader:shader];

    // Objects
    IDLens *lens = [IDLens new];

    // Scene
    renderer.scene = sBind;
    sBind.scene = tBind;
    tBind.scene = worldTransformNode;
    worldTransformNode.scene = camera;
    camera.scene = lens;
}

@end
