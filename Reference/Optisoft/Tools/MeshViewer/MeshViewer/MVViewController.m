//
//  MVViewController.m
//  MeshViewer
//
//  Created by Richard Henry on 23/07/2014.
//  Copyright (c) 2014 Dogstar Industries. All rights reserved.
//

#import "MVViewController.h"
#import "MVRenderer.h"
#import "MVLensMesh.h"

#import "DSEngine.h"
#import "DSView.h"
#import "DSOscillator.h"
#import "DSInterpolator.h"

@interface MVViewController () <DSEngineDelegate>

@end

@implementation MVViewController  {

    // Update mechanics
    CADisplayLink                       *displayLink;
    DSEngine                            *engine;

    // Rendering
    __weak IBOutlet MVRenderer          *renderer;

    // Popover
    UIPopoverController                 *prefsPopover;

    // Temp
    DSOscillator                        *osc;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {

    if (self = [super initWithCoder:decoder]) {

        // Set up the engine
        engine = [DSEngine new];
        engine.context = [DSEngineContext new];
        //engine.delegate = self;
        //engine.simulatorTickRate = 23 * kDSTimeToMilliseconds;

        // Set up simulation
        DSOscillatorSimulator *oscSim = [DSOscillatorSimulator new];
        [engine.context addEngineNode:oscSim];
        osc = [DSOscillator new];
        osc.interpolator = [DSInterpolator new];
        [engine.context addEngineNode:osc];
    }

    return self;
}

#pragma mark Lifecycle

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [self startRendering];
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

    [self stopRendering];
}

#pragma mark Engine delegate

- (BOOL)engine:(DSEngine *)e willTickWithDelta:(DSTime)delta {

    return YES;
}

- (void)engine:(DSEngine *)e didTickWithDelta:(DSTime)delta {
}

#pragma mark Gesture recognition

- (IBAction)longPressGesture:(UILongPressGestureRecognizer *)longPress {

    if (longPress.state == UIGestureRecognizerStateBegan) {

        // Create the spectacle shape picker popover
        MVPrefsViewController *prefsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"prefsViewController"];
        prefsViewController.delegate = renderer;

        prefsPopover = [[UIPopoverController alloc] initWithContentViewController:prefsViewController];

        // Show the popover from the long press recogniser actuation point.
        CGPoint longPressLocation = [longPress locationInView:longPress.view];
        CGRect popoverRect = CGRectMake(longPressLocation.x, longPressLocation.y, 1, 1);
        [prefsPopover presentPopoverFromRect:popoverRect inView:longPress.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
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
}

- (BOOL)view:(DSView *)view didPrepareDrawContext:(DSDrawContext *)drawContext {

    // Set up the draw context
    drawContext.depthTest = YES;
    drawContext.autoSetNormalMatrix = YES;
    drawContext.culling = kDSCullBackFaces;

    // Renderer post draw context setup
    [renderer setup];
    [engine.context addEngineNode:renderer];

    return YES;
}

- (void)view:(DSView *)view willRenderToContext:(DSDrawContext *)drawContext {

    // Give the engine a tick
    [engine tick];
    
    // The engine has now finished drawing so let's flush out the draw context.
    [drawContext flush];
}

@end
