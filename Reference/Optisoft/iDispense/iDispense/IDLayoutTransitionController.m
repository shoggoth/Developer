//
//  IDLayoutTransitionController.m
//  iDispense
//
//  Created by Richard Henry on 18/11/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import "IDLayoutTransitionController.h"


@implementation IDLayoutTransitionController {

    id <UIViewControllerContextTransitioning>   context;
    UICollectionViewTransitionLayout            *transitionLayout;
    UICollectionView                            *collectionView;

    CGFloat                                     pinchSensitivity;
}

- (instancetype)initWithCollectionView:(UICollectionView *)cv {

    if ((self = [super init])) {

        // Initialisation code
        collectionView = cv;

        // Gesture recogniser
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        [cv addGestureRecognizer:pinchGesture];
    }

    return self;
}

#pragma mark Pinch gesture handling

-(void)handlePinch:(UIPinchGestureRecognizer *)sender {

    if (sender.state == UIGestureRecognizerStateEnded)

        [self endInteractionWithSuccess:YES];

    else if (sender.state == UIGestureRecognizerStateCancelled)

        [self endInteractionWithSuccess:NO];

    else if (sender.numberOfTouches > 1) {

        UIView *view = sender.view;
        CGPoint point1 = [sender locationOfTouch:0 inView:view];
        CGPoint point2 = [sender locationOfTouch:1 inView:view];
        CGFloat distance = hypotf(point1.x - point2.x, point1.y - point2.y);
        CGPoint point = [sender locationInView:view];

        static CGFloat initialPinchDistance;

        if (sender.state == UIGestureRecognizerStateBegan) {

            // Get the current pinch sensitivity
            pinchSensitivity = [[NSUserDefaults standardUserDefaults] floatForKey:@"pinch_sens_preference"];

            if (!self.hasActiveInteraction) {

                _hasActiveInteraction = YES;
                initialPinchDistance = distance;

                [self.delegate interactionBeganAtPoint:point];
            }
        }

        else if (self.hasActiveInteraction && sender.state == UIGestureRecognizerStateChanged) {

            // Compute the distance delta
            CGFloat distanceDelta = distance - initialPinchDistance;
            CGFloat dimension = hypotf(collectionView.bounds.size.width, collectionView.bounds.size.height);

            // Adjust the distance delta to suit the settings
            distanceDelta *= pinchSensitivity;
            if (self.navigationOperation == UINavigationControllerOperationPop) distanceDelta *= -1;

            // Pin the progress between the max and min values.
            CGFloat progress = MAX(MIN((distanceDelta / dimension), 1.0), 0.0);

            //NSLog(@"ipd = %f pd = %f dd = %f sens = %f", initialPinchDistance, distance, distanceDelta, [[NSUserDefaults standardUserDefaults] floatForKey:@"pinch_sens_preference"]);
            [self updateWithProgress:progress];
        }
    }
}

-(void)updateWithProgress:(CGFloat)progress {

    if (context && progress != transitionLayout.transitionProgress) {

        [transitionLayout setTransitionProgress:progress];
        [transitionLayout invalidateLayout];

        [context updateInteractiveTransition:progress];
    }
}

-(void)endInteractionWithSuccess:(BOOL)success {

    if (!context) _hasActiveInteraction = NO;

    else if ((transitionLayout.transitionProgress > 0.5) && success) {

        [collectionView finishInteractiveTransition];
        [context finishInteractiveTransition];
        
    } else {
        
        [collectionView cancelInteractiveTransition];
        [context cancelInteractiveTransition];
    }
    
    transitionLayout = nil;
}

#pragma mark UIViewControllerAnimatedTransitioning conformance

// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
-(void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {}


-(NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {

    // This is used for percent driven interactive transitions, as well as for container controllers that have companion
    // animations that might need to synchronize with the main animation.
    return 1.0;
}

#pragma mark UIViewControllerInteractiveTransitioning conformance

- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext {

    context = transitionContext;
    UICollectionViewController *fromCollectionViewController = (UICollectionViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UICollectionViewController *toCollectionViewController   = (UICollectionViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    UICollectionViewLayoutInteractiveTransitionCompletion completion = ^(BOOL didFinish, BOOL didComplete) {

        [context.containerView addSubview:toCollectionViewController.view];
        [context completeTransition:didComplete];

        collectionView.delegate = (didComplete) ? toCollectionViewController : fromCollectionViewController;
        transitionLayout = nil;
        context = nil;
        _hasActiveInteraction = NO;
    };
    
    transitionLayout = [fromCollectionViewController.collectionView startInteractiveTransitionToCollectionViewLayout:toCollectionViewController.collectionViewLayout completion:completion];
}


#pragma mark UINavigationControllerDelegate conformance

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController {

    return (animationController == self) ? self : nil;
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC {

    if (![fromVC isKindOfClass:[UICollectionViewController class]] || ![toVC isKindOfClass:[UICollectionViewController class]]) return nil;
    if (!_hasActiveInteraction) return nil;

    _navigationOperation = operation;

    return self;
}

@end
