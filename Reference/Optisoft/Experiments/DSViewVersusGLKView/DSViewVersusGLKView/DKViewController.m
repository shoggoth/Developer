//
//  DKViewController.m
//  DSViewVersusGLKView
//
//  Created by Richard Henry on 22/05/2014.
//  Copyright (c) 2014 Optisoft. All rights reserved.
//

#import "DKViewController.h"

#import "DSEngine.h"
#import "DSTriMesh.h"

@interface DKViewController ()

@end

@implementation DKViewController {

    DSEngine                *engine;

    CADisplayLink           *displayLink;
    BOOL                    isGLKView;
}

#pragma mark View lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];

    isGLKView = [self.view isKindOfClass:[GLKView class]];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    if (isGLKView) {

        // Set up the parameters of this view controller
        DSDrawContext *drawContext = [DSDrawContext new];
        [drawContext attachToGLKView:(GLKView *)self.view];
    }

    [self startRendering];

}

- (void)viewDidDisappear:(BOOL)animated {

    [self stopRendering];

    [super viewDidDisappear:animated];
}

#pragma mark Rendering

- (void)render:(CADisplayLink *)link {

    if (isGLKView) [(GLKView *)self.view display];
    else [(DSView *)self.view render:link];
}

- (void)startRendering {

    if (!displayLink) {

        NSInteger frameInterval = 1;

        // Create display link
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
        [displayLink setFrameInterval:frameInterval];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];

        // Render first frame
        [self render:displayLink];
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

    //view.depthBuffer = NO;
}

- (BOOL)view:(DSView *)view didPrepareDrawContext:(DSDrawContext *)drawContext {

    // Returning NO here stops new buffers being assigned to the EAGLLayer
    return NO;
}

- (void)view:(DSView *)view willRenderToContext:(DSDrawContext *)drawContext {

    glClearColor(1, 0, (rand() % 1000) * 0.001, 1); [drawContext clearBuffers];
    [engine tick];

    [drawContext flush];
}

#pragma mark GLKViewDelegate conformance

- (void)update {

    NSLog(@"update = %@", self.view);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {

    glClearColor(0, 1, (rand() % 1000) * 0.001, 1); glClear(GL_COLOR_BUFFER_BIT);
    [engine tick];
}

@end
