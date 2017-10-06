//
//  IDGestureTransformer.m
//  iDispense
//
//  Created by Richard Henry on 28/05/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDGestureTransformer.h"
#import "DSMaths.h"

@import GLKit;


@implementation IDGestureTransformer {

    // Gesture recognisers
    __weak IBOutlet UIPanGestureRecognizer      *panGestureRecogniser;
    __weak IBOutlet UIPinchGestureRecognizer    *pinchGestureRecogniser;
}

- (instancetype)init {

    if ((self = [super init])) {

        // Initialisation
        self.recognise = YES;
    }

    return self;
}

#pragma mark Gesture recognition

- (IBAction)panGesture:(UIPanGestureRecognizer *)pan {

    static CGPoint          startPosition;
    static GLKQuaternion    startRotation;

    CGPoint posInView = [pan translationInView:pan.view];

    if (pan.state == UIGestureRecognizerStateBegan) {

        startPosition = posInView;
        startRotation = _transform.rot;

    } else {

        CGPoint trackBallVector = (CGPoint) { (posInView.x - startPosition.x) * 0.001, (posInView.y - startPosition.y) * 0.001 };

        GLKQuaternion rot = GLKQuaternionMultiply(startRotation, GLKQuaternionMakeWithAngleAndVector3Axis(trackBallVector.y, kDSXAxis));
        _transform.rot = GLKQuaternionMultiply(rot, GLKQuaternionMakeWithAngleAndVector3Axis(trackBallVector.x, kDSYAxis));

        // NSLog(@"Pan = %@", pan);
    }
}

- (IBAction)pinchGesture:(UIPinchGestureRecognizer *)pinch {

    // Get the pinch gesture scaling factor in the gesture recogniser's view's superview
    static GLKVector3   pinchBeginPos;

    if (pinch.state == UIGestureRecognizerStateBegan) { pinchBeginPos = _transform.pos; }

    else { _transform.pos = (GLKVector3) { pinchBeginPos.x, pinchBeginPos.y, pinchBeginPos.z + (1 - pinch.scale) * -100 }; }
 }

#pragma mark UIGestureRecognizerDelegate conformance

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

    if (gestureRecognizer == panGestureRecogniser) {

        return (!(touch.view.gestureRecognizers.count));

        NSLog(@"view = %@", touch.view);
    }

    return _recognise;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gr1 shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)gr2 {

    // All of the gesture recognisers need to be simultaneous apart from the long press gesture recogniser.
    return YES;//!(gr1 == longPressGestureRecogniser || gr2 == longPressGestureRecogniser);
}

/*
 
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

 */

@end
