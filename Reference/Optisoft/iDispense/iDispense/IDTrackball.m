//
//  IDTrackball.m
//  iDispense
//
//  Created by Richard Henry on 19/08/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDTrackball.h"

@interface DSTrackball ()

- (void)panGesture:(UIPanGestureRecognizer *)pan;
- (void)pinchGesture:(UIPinchGestureRecognizer *)pinch;
- (void)rotateGesture:(UIRotationGestureRecognizer *)rotate;

@end

@implementation IDTrackball

- (instancetype)init {

    if ((self = [super init])) {

        // Initialisation
        self.recognise = YES;

        self.panSensitivity = 0.01;
        self.pinchSensitivity = 10;
        self.rotateSensitivity = 1;

        self.pinchLimits = (CGPoint) { -100, 100 };
    }
    
    return self;
}

#pragma mark Gesture recognition

- (void)panGesture:(UIPanGestureRecognizer *)pan {

    [self adjustTrackballForTouchFromGestureRecognizer:pan];

    [super panGesture:pan];
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)pinch {

    [self adjustTrackballForTouchFromGestureRecognizer:pinch];

    [super pinchGesture:pinch];
}

- (void)rotateGesture:(UIRotationGestureRecognizer *)rotate {

    [self adjustTrackballForTouchFromGestureRecognizer:rotate];

    [super rotateGesture:rotate];
}

#pragma mark Utility

- (void)adjustTrackballForTouchFromGestureRecognizer:(UIGestureRecognizer *)gr {

    if (gr.state == UIGestureRecognizerStateBegan) {

        if ([self touchWasOnRight:gr])
            self.transform = self.rightTransform;
        else
            self.transform = self.leftTransform;
    }
}

- (BOOL)touchWasOnRight:(UIGestureRecognizer *)gr {

    if (_viewToTrack) {

        // Tracking zoomed view
        return _viewToTrack == 2 || _viewToTrack == 4;

    } else {

        // Tracking all views
        CGPoint touchPoint = [gr locationInView:gr.view];

        return touchPoint.x > gr.view.frame.size.width * 0.5;
    }
}

#pragma mark Save and restore

- (void)saveTransformState {

}

- (void)restoreTransformState {
    
}
@end
