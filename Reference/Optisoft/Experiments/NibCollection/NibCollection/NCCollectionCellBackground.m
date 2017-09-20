//
//  IDCollectionCellBackground.m
//  iDispense
//
//  Created by Richard Henry on 08/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#import "NCCollectionCellBackground.h"


@implementation NCCollectionCellBackground

- (id)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {

        // Initialization code
        [self setup];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {

    if (self = [super initWithCoder:decoder]) {

        // Initialization code
        [self setup];
    }

    return self;
}

- (void)setup {

    const CALayer *layer = self.layer;

    //layer.anchorPoint = (const CGPoint) { 0, 0 };
    layer.shadowOffset = (const CGSize) { 3, 3 };
    layer.shadowOpacity = 0.7;
    layer.shadowRadius = 3.0f;
    layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:[self bounds] cornerRadius:12.0f] CGPath];
    layer.shouldRasterize = YES;
    layer.cornerRadius = 8.0f;
}

- (void)layoutSubviews {

    NSLog(@"Laying out");

    // Will probably need this a bit later if the size of the view changes.
    //[self invalidateIntrinsicContentSize];
    //self.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:[self bounds] cornerRadius:12.0f] CGPath];

    CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
    theAnimation.duration = 1.0;
    theAnimation.toValue = (id)[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:12.0f].CGPath;
    theAnimation.removedOnCompletion = YES;
    [self.layer addAnimation:theAnimation forKey:@"animateShadowPath"];
    //self.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:[self bounds] cornerRadius:12.0f] CGPath];
}

@end


@implementation NCCollectionSelectedCellBackground

- (void)drawRect:(CGRect)rect {
    
    // Draw a rounded rect bezier path filled with blue
    CGContextRef aRef = UIGraphicsGetCurrentContext();
    CGContextSaveGState(aRef);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:5.0f];
    [bezierPath setLineWidth:5.0f];
    [[UIColor blackColor] setStroke];
    
    UIColor *fillColor = [UIColor colorWithRed:0.529 green:0.808 blue:0.345 alpha:1];
    [fillColor setFill];
    
    [bezierPath stroke];
    [bezierPath fill];
    
    CGContextRestoreGState(aRef);
}

@end
