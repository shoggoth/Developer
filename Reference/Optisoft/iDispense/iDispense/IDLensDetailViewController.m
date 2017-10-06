//
//  IDLensDetailViewController.m
//  iDispense
//
//  Created by Richard Henry on 24/06/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDLensDetailViewController.h"
#import "IDGestureTransformer.h"
#import "IDLensRenderer.h"

#import "DSEngine.h"
#import "IDLensMesh.h"


@implementation IDLensDetailViewController {

    // Update mechanics
    CADisplayLink                           *displayLink;
    DSEngine                                *engine;

    // Rendering
    __weak IBOutlet IDLensRenderer          *renderer;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {

    if (self = [super initWithCoder:decoder]) {

        // Set up the engine
        engine = [DSEngine new];
        engine.context = [DSEngineContext new];
        engine.simulatorTickRate = 20 * kDSTimeToMilliseconds;
    }

    return self;
}

#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [self startRendering];
}

- (void)viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:animated];

    [self stopRendering];
}

#pragma mark Rendering

- (void)startRendering {

    if (!displayLink) {

        NSInteger frameInterval = 1;

        // Create display link
        displayLink = [CADisplayLink displayLinkWithTarget:self.view selector:@selector(render:)];
        [displayLink setFrameInterval:frameInterval];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)stopRendering {

    if (displayLink) {

        [displayLink invalidate];

        displayLink = nil;
    }
}

#pragma mark DSViewDelegate conformance

- (void)view:(DSView *)view willPrepareDrawContext:(DSDrawContext *)drawContext {

    // Make sure that a depth buffer is allocated.
    view.depthBuffer = YES;

    // Set up renderer
    renderer.context = drawContext;
    engine.renderer = renderer;

    [renderer setup];
    [engine.context addEngineNode:renderer];

    [renderer.lens makeLensPairWithParameters:self.lensParameters];
}

- (BOOL)view:(DSView *)view didPrepareDrawContext:(DSDrawContext *)drawContext {

    // Set up the draw context
    drawContext.depthTest = YES;
    drawContext.autoSetNormalMatrix = YES;
    drawContext.culling = kDSCullBackFaces;

    // Returning NO here stops new buffers being assigned to the EAGLLayer by the draw context
    return NO;
}

- (void)view:(DSView *)view willRenderToContext:(DSDrawContext *)drawContext {

    [drawContext bind];
    // Give the engine a tick
    [engine tick];

    // The engine has now finished drawing so let's flush out the draw context.
    [drawContext flush];
}

@end
