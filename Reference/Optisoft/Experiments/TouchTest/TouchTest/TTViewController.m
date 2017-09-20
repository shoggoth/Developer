//
//  TTViewController.m
//  TouchTest
//
//  Created by Richard Henry on 20/12/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#import "TTViewController.h"
#import "DSCGPointExt.h"

@import GLKit;

const unsigned maxTouches = 3;


@interface TTViewController ()

@property(nonatomic, assign) float deadZone;

@end

@implementation TTViewController {

    CGAffineTransform   moveTransform;

    UITouch             *joyTouches[maxTouches];
    CGPoint             joyPoints[maxTouches];
    NSTimeInterval      timeStamp[maxTouches];

    unsigned            numTouches;

    CALayer             *layer1, *layer2, *layer3;
    CGPoint             redLoc, greenLoc;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    layer1 = [CALayer new];
    layer1.frame = (CGRect) { self.view.bounds.size.width * 0.5 - 50, self.view.bounds.size.height * 0.5 - 50, 100, 100 };
    layer1.backgroundColor = [UIColor redColor].CGColor;

    [self.view.layer addSublayer:layer1];

    layer2 = [CALayer new];
    layer2.frame = (CGRect) { self.view.bounds.size.width * 0.5 - 25, self.view.bounds.size.height * 0.5 - 25, 50, 50 };
    layer2.backgroundColor = [UIColor greenColor].CGColor;

    [self.view.layer addSublayer:layer2];

    layer3 = [CALayer new];
    layer3.frame = (CGRect) { self.view.bounds.size.width * 0.5 - 10, self.view.bounds.size.height * 0.5 - 10, 20, 20 };
    layer3.backgroundColor = [UIColor blueColor].CGColor;

    [self.view.layer addSublayer:layer3];

    for (int i = 0; i < maxTouches; i++) joyTouches[i] = nil;
    numTouches = 0;
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    if (numTouches > maxTouches) return;

    for (UITouch *t in touches) {

        for (int i = 0; i < maxTouches; i++) {

            if (!joyTouches[i]) {

                joyTouches[i] = t;
                joyPoints[i]  = [t locationInView:self.view];
                timeStamp[i] = t.timestamp;

                numTouches++;
                break;
            }
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    for (UITouch *t in touches) {

        for (int i = 0; i < maxTouches; i++) {

            if (t == joyTouches[i]) {

                if (i == 0) {

                    NSTimeInterval timestamp = t.timestamp;

                    if (timestamp - timeStamp[i] > 1.0) {

                        NSLog(@"More than a sec");
                        joyPoints[i] = [t locationInView:self.view];
                    }

                    timeStamp[i] = timestamp;

                    redLoc = DSCGPointSubtract([t locationInView:self.view], joyPoints[i]);
                    layer1.affineTransform = CGAffineTransformMakeTranslation(redLoc.x, redLoc.y);

                } else if (i == 1) {

                    greenLoc = DSCGPointSubtract([t locationInView:self.view], joyPoints[i]);

                    // Experimental
                    //loc = DSCGPointProject(loc, kDSCGPointYAxis);
                    //greenLoc = DSCGPointPerp(greenLoc);
                    layer2.affineTransform = CGAffineTransformMakeTranslation(greenLoc.x, greenLoc.y);
                }

                else NSLog(@"Other");

                CGPoint blueLoc = DSCGPointLerp(greenLoc, redLoc, 0.5);
                layer3.affineTransform = CGAffineTransformMakeTranslation(blueLoc.x, blueLoc.y);
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    for (UITouch *t in touches) {

        for (int i = 0; i < maxTouches; i++) {

            if (t == joyTouches[i]) {

                if (i == 0) {

                    layer1.affineTransform = CGAffineTransformIdentity;

                } else if (i == 1) {

                    layer2.affineTransform = CGAffineTransformIdentity;
                }

                joyTouches[i] = nil;
                --numTouches;
            }
        }

    }
}

@end
