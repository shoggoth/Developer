//
//  DSTrackball.m
//  MeshViewer
//
//  Created by Richard Henry on 23/07/2014.
//  Copyright (c) 2014 Dogstar Industries. All rights reserved.
//

#import "DSTrackball.h"
#import "DSTransform.h"
#import "DSMaths.h"

@implementation DSTrackball {

    __weak IBOutlet UIView      *view;

    // Gesture recognisers
    UIPanGestureRecognizer      *panGestureRecogniser;
    UIPinchGestureRecognizer    *pinchGestureRecogniser;
    UIRotationGestureRecognizer *rotateGestureRecogniser;
    UITapGestureRecognizer      *tapGestureRecogniser;
}

- (instancetype)init {

    if ((self = [super init])) {

        // Initialisation
        self.recognise = YES;

        self.panSensitivity = 0.01;
        self.pinchSensitivity = 10;
        self.rotateSensitivity = 1;

        self.pinchLimits = (CGPoint) { -100, 100 };

        self.transform = [[DS3DTransform alloc] initWithPos:(GLKVector3) { 0, 0, 0 }];
    }

    return self;
}

#pragma mark Lifecycle

- (void)setView:(UIView *)v {

    view = v;

    // Panning
    panGestureRecogniser = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    panGestureRecogniser.minimumNumberOfTouches = 1;
    panGestureRecogniser.maximumNumberOfTouches = 1;
    panGestureRecogniser.delegate = self;

    // Pinching
    pinchGestureRecogniser = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    pinchGestureRecogniser.delegate = self;

    // Rotating
    rotateGestureRecogniser = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateGesture:)];
    rotateGestureRecogniser.delegate = self;

    // Double tap
    tapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGesture:)];
    tapGestureRecogniser.numberOfTapsRequired = 2;
    tapGestureRecogniser.delegate = self;

    // Add gesture recognisers to the view
    [view addGestureRecognizer:panGestureRecogniser];
    [view addGestureRecognizer:pinchGestureRecogniser];
    [view addGestureRecognizer:rotateGestureRecogniser];
    [view addGestureRecognizer:tapGestureRecogniser];
}

#pragma mark Gesture recognition

- (IBAction)panGesture:(UIPanGestureRecognizer *)pan {

    CGPoint         panTouchPoint = [pan locationInView:pan.view];
    static CGPoint  panStartPoint;

    if (pan.state == UIGestureRecognizerStateChanged) {

        CGPoint delta = CGPointMake(panTouchPoint.x - panStartPoint.x, -(panTouchPoint.y - panStartPoint.y));
        self.transform.rot = [self rotateQuaternion:self.transform.rot withDelta:delta];
    }

    panStartPoint = panTouchPoint;
}

- (IBAction)pinchGesture:(UIPinchGestureRecognizer *)pinch {

    // Get the pinch gesture scaling factor in the gesture recogniser's view's superview
    static GLKVector3   pinchBeginPos;

    if (pinch.state == UIGestureRecognizerStateBegan) { pinchBeginPos = _transform.pos; }

    else {

        float zPos = pinchBeginPos.z + (1 - pinch.scale) * -_pinchSensitivity;

        // Apply limits
        if (zPos < _pinchLimits.x) zPos = _pinchLimits.x;
        if (zPos > _pinchLimits.y) zPos = _pinchLimits.y;

        _transform.pos = (GLKVector3) { pinchBeginPos.x, pinchBeginPos.y, zPos };
    }
}

- (IBAction)rotateGesture:(UIRotationGestureRecognizer *)rotate {

    static float    startRotation;
    float           rotation = rotate.rotation;

    if (rotate.state == UIGestureRecognizerStateChanged) {

        self.transform.rot = [self rotateQuaternion:self.transform.rot withAngle:rotation - startRotation];
    }

    startRotation = rotation;
}

- (IBAction)doubleTapGesture:(UITapGestureRecognizer *)tap {

    self.transform.rot = GLKQuaternionIdentity;
}

#pragma mark Arcball calculations

- (GLKQuaternion)rotateQuaternion:(GLKQuaternion)rotation withDelta:(CGPoint)delta {

    // We're going to rotate the x delta around the eye space up axis and the y delta around the eye space right axis.
	GLKVector3 up = (GLKVector3) { 0, 1, 0 };
	GLKVector3 right = (GLKVector3) { -1, 0, 0 };

	up = GLKQuaternionRotateVector3(GLKQuaternionInvert(rotation), up);
	rotation = GLKQuaternionMultiply(rotation, GLKQuaternionMakeWithAngleAndVector3Axis(delta.x * _panSensitivity, up));

	right = GLKQuaternionRotateVector3(GLKQuaternionInvert(rotation), right );
	rotation = GLKQuaternionMultiply(rotation, GLKQuaternionMakeWithAngleAndVector3Axis(delta.y * _panSensitivity, right));

    return rotation;
}

- (GLKQuaternion)rotateQuaternion:(GLKQuaternion)rotation withAngle:(float)delta {

    // We're going to rotate the delta around the eye space out axis.
	GLKVector3 out = (GLKVector3) { 0, 0, 1 };

	out = GLKQuaternionRotateVector3(GLKQuaternionInvert(rotation), out);
	rotation = GLKQuaternionMultiply(rotation, GLKQuaternionMakeWithAngleAndVector3Axis(delta * -_rotateSensitivity, out));

    return rotation;
}

#pragma mark UIGestureRecognizerDelegate conformance

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

    return _recognise;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

    // if the gesture recognizers's view isn't one of our views, don't allow simultaneous recognition
    if (gestureRecognizer.view != view || otherGestureRecognizer.view != view) return NO;

    // if the gesture recognizers are on different views, don't allow simultaneous recognition
    if (gestureRecognizer.view != otherGestureRecognizer.view) return NO;

    // if either of the gesture recognizers is the long press, don't allow simultaneous recognition
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) return NO;

    return YES;
}

@end
