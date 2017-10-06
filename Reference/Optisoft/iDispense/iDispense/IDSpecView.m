//
//  IDSpecView.m
//  iDispense
//
//  Created by Optisoft Ltd on 24/10/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import "IDSpecView.h"
#import "IDPatternDrawer.h"


#pragma mark - Image view

@implementation IDSpecView {

    CALayer                         *noteLayer;
    IDPatternDrawer                 *customDrawer;
}

- (id)initWithFrame:(CGRect)frame {

    if ((self = [super initWithFrame:frame])) {

        // Programmatic initialisation
        [self setup];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {

    if ((self = [super initWithCoder:decoder])) {

        // Initialisation from nib file
        [self setup];
    }

    return self;
}

- (void)dealloc {

    self.mugshotImage = nil;
    self.specImage = nil;
}

#pragma mark Setup

- (void)setup {

    // Custom drawing helper
    customDrawer = [IDPatternDrawer new];
    customDrawer.bgColour = [UIColor colorWithHue:0.6 saturation:1.0 brightness:1.0 alpha:0.25];

    // For futire expansion
    if (/* DISABLES CODE */ (NO)) {

        // Add the notations layer
        noteLayer = [CALayer layer];
        noteLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5].CGColor;
        noteLayer.shadowOffset = CGSizeMake(0, 3);
        noteLayer.shadowRadius = 5.0;
        noteLayer.shadowColor = [UIColor blackColor].CGColor;
        noteLayer.shadowOpacity = 0.8;
        noteLayer.frame = CGRectMake(30, 30, 128, 128);

        //noteLayer.delegate = customDrawer;

        [self.layer addSublayer:noteLayer];

        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];

        animation.fromValue = @0;
        animation.toValue = @3;
        animation.duration = 3;

        [CATransaction begin];
        [CATransaction setCompletionBlock:^{

            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];

            animation.fromValue = @3;
            animation.toValue = @0;
            animation.duration = .3;

            [noteLayer addAnimation:animation forKey:@"reverseRotate"];
        }];

        [noteLayer addAnimation:animation forKey:@"forwardRotate"];

        [CATransaction commit];

        [noteLayer setNeedsDisplay];
    }

    // Reset transform
    self.specTransform = CGAffineTransformIdentity;
}

- (void)drawRect:(CGRect)rect {

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSaveGState(context);
    CGContextConcatCTM(context, self.specTransform);

    const float w = self.specImage.size.width;
    const float h = self.specImage.size.height;

    [self.specImage drawInRect:CGRectMake(-0.5 * w, -0.5 * h, w, h)];

    CGContextRestoreGState(context);

    // We have restored the context now so there should be no transformation applied to anything after this.
    // [self.specImage drawInRect:CGRectMake(-0.5 * w, -0.5 * h, w, h)];
}

@end

#pragma mark - Movie view

@implementation IDMovieView

- (id)initWithFrame:(CGRect)frame {

    if ((self = [super initWithFrame:frame])) {

        // Programmatic initialisation
        [self setup];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {

    if ((self = [super initWithCoder:decoder])) {

        // Initialisation from nib file
        [self setup];
    }
    
    return self;
}

- (void)dealloc {
    
    self.movieUrl = nil;
}

#pragma mark Setup

- (void)setup { }

@end
