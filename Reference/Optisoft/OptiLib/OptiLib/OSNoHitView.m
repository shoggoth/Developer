//
//  OSNoHitView.m
//  OptiLib
//
//  Created by Richard Henry on 31/10/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import "OSNoHitView.h"


@implementation OSNoHitView

- (instancetype)init {

    if ((self = [super init])) {

        // Initialisation
        _hitIgnoreType = kOSDontIgnoreHits;
    }

    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {

    if (_hitIgnoreType != kOSIgnoreHitsUsingPointInsideTest) return YES;

    for (UIView *view in [self subviews]) {

        if (view.userInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event]) {

            return YES;
        }
    }

    return NO;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {

    // Ignore hits in this view but not in the subviews…
    UIView *hitView = [super hitTest:point withEvent:event];

    if (_hitIgnoreType != kOSIgnoreHitsUsingHitTest) return hitView;
    
    return (hitView == self) ? nil : hitView;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {

    NSLog(@"Testing (Y) = %@", gestureRecognizer);

    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

@end
