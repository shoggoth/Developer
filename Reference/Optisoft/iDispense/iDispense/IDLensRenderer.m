//
//  IDLensRenderer.m
//  iDispense
//
//  Created by Richard Henry on 30/05/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDLensRenderer.h"
#import "IDLensMesh.h"
#import "IDTrackball.h"

#import "DSCamera.h"
#import "DSShader.h"
#import "DSTexture.h"
#import "DSMaths.h"
#import "DSFilter.h"

@interface IDLensRenderer ()

@property (nonatomic, weak) IBOutlet UIView *rootView;
@property (nonatomic, weak) IBOutlet UIView *containingView;

@property (nonatomic, weak) IBOutlet UIView *view1;
@property (nonatomic, weak) IBOutlet UIView *view2;
@property (nonatomic, weak) IBOutlet UIView *view3;
@property (nonatomic, weak) IBOutlet UIView *view4;

@end

@implementation IDLensRenderer {

    // Lens parameters
    IDLensParameters    nodeParams[4];
    IDLensNode          *meshNode[4];

    // Camera parameters
    float               fov, near, far;
}

#pragma mark Lifecycle

- (void)awakeFromNib {

    [super awakeFromNib];
    
    // Set up camera parameters
    near = .1;
    far = 100000;
    fov = 65 * kDSDegreesToRadians;

    // Set trackball initial position and limits.
    self.trackball.leftTransform = [DS3DTransform new];
    self.trackball.rightTransform = [DS3DTransform new];
    self.trackball.transform = self.trackball.leftTransform;

    self.trackball.pinchLimits = (CGPoint) { -23, -2.3 };
}

#pragma mark Setup

- (void)setupWithLeftLensParams:(IDLensParameters)leftPrescription rightLensParams:(IDLensParameters)rightPrescription {

    const BOOL showMeridian = [[[NSUserDefaults standardUserDefaults] objectForKey:@"show_lens_meridian_preference"] boolValue];

    // Set up draw context
    self.context.shader = [[DSShader alloc] initWithShaderFile:@"LensShader"];
    [self.context bindTexture:[[DSTexture alloc] initWithImageFileName:showMeridian ? @"LensTexture_0.png" : @"LensTexture_2.png" textureUnit:0 options:nil] toName:@"texture_0"];
    [self.context bindTexture:[[DSTexture alloc] initWithImageFileName:@"LensTexture_1.png" textureUnit:1 options:@{ @"kDSTextureParamSetupBlock" : ^{
        {
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        }}}] toName:@"texture_1"];

    // Parameters
    nodeParams[0] = nodeParams[2] = rightPrescription;
    nodeParams[1] = nodeParams[3] = leftPrescription;
}

- (void)render {

    DSDrawContext *context = self.context;

    const GLKMatrix4    oldProjection = context.projectionMatrix;
    const GLKMatrix4    oldTransform = context.transformMatrix;
    const BOOL          isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    const float         viewAspect = (isPortrait) ? 1 : context.aspect;

    // View 1
    CGRect clipRect = [self glViewportClipRectForSubView:_view1 aspect:viewAspect];
    glViewport(clipRect.origin.x, clipRect.origin.y, clipRect.size.width, clipRect.size.height);
    context.projectionMatrix = GLKMatrix4MakePerspective(fov, [self cameraAspectForSubView:_view1], near, far);
    context.transformMatrix = self.trackball.leftTransform.transformMatrix;
    [meshNode[0] drawInContext:context];

    // View 2
    clipRect = [self glViewportClipRectForSubView:_view2 aspect:viewAspect];
    glViewport(clipRect.origin.x, clipRect.origin.y, clipRect.size.width, clipRect.size.height);
    context.projectionMatrix = GLKMatrix4MakePerspective(fov, [self cameraAspectForSubView:_view2], near, far);
    context.transformMatrix = self.trackball.rightTransform.transformMatrix;
    [meshNode[1] drawInContext:context];

    // View 3
    clipRect = [self glViewportClipRectForSubView:_view3 aspect:viewAspect];
    glViewport(clipRect.origin.x, clipRect.origin.y, clipRect.size.width, clipRect.size.height);
    context.projectionMatrix = GLKMatrix4MakePerspective(fov, [self cameraAspectForSubView:_view3], near, far);
    context.transformMatrix = self.trackball.leftTransform.transformMatrix;
    [meshNode[2] drawInContext:context];

    // View 4
    clipRect = [self glViewportClipRectForSubView:_view4 aspect:viewAspect];
    glViewport(clipRect.origin.x, clipRect.origin.y, clipRect.size.width, clipRect.size.height);
    context.projectionMatrix = GLKMatrix4MakePerspective(fov, [self cameraAspectForSubView:_view4], near, far);
    context.transformMatrix = self.trackball.rightTransform.transformMatrix;
    [meshNode[3] drawInContext:context];

    context.projectionMatrix = oldProjection;
    context.transformMatrix = oldTransform;
}

#pragma mark Properties

- (void)setTopMaterial:(IDLensMaterial)topMat {

    // Parameters
    nodeParams[0].material = nodeParams[1].material = topMat;

    // Mesh
    meshNode[0] = [[IDLensNode alloc] initWithParameters:nodeParams[0]];
    meshNode[1] = [[IDLensNode alloc] initWithParameters:nodeParams[1]];
}

- (void)setBottomMaterial:(IDLensMaterial)botMat {

    // Parameters
    nodeParams[2].material = nodeParams[3].material = botMat;

    // Mesh
    meshNode[2] = [[IDLensNode alloc] initWithParameters:nodeParams[2]];
    meshNode[3] = [[IDLensNode alloc] initWithParameters:nodeParams[3]];
}

#pragma mark Utility

- (CGRect)glViewportClipRectForSubView:(UIView *)subView aspect:(float)aspect {

    CGRect presentationFrame = [subView.layer.presentationLayer frame];

    // Add the height to the Y origin to convert to the GL coordinate system.
    presentationFrame.origin.y = (self.rootView.bounds.size.height - (presentationFrame.origin.y + presentationFrame.size.height)) - self.containingView.frame.origin.y;

    // Scale to match the resolution of the root view.
    const float scale = self.rootView.contentScaleFactor;
    presentationFrame = CGRectApplyAffineTransform(presentationFrame, CGAffineTransformMakeScale(scale, scale));

    // Apply aspect ratio.
    presentationFrame.origin.x /= aspect;
    presentationFrame.origin.y *= aspect;
    presentationFrame.size.width /= aspect;
    presentationFrame.size.height *= aspect;

    return presentationFrame;
}

- (float)cameraAspectForSubView:(UIView *)subView {

    CGRect subViewBounds = [subView.layer.presentationLayer bounds];

    return subViewBounds.size.width / subViewBounds.size.height;
}

@end
