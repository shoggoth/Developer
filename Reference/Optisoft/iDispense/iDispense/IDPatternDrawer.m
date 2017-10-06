//
//  IDPatternDrawer.m
//  iDispense
//
//  Created by Optisoft Ltd on 25/10/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import "IDPatternDrawer.h"


@implementation IDPatternDrawer

#pragma mark Custom drawing

static void drawColouredPattern(void *info, CGContextRef context) {
    
    const CGFloat radians = M_PI * 2;
    
    CGColorRef dotColor = [UIColor colorWithHue:0 saturation:0 brightness:0.07 alpha:1.0].CGColor;
    CGColorRef shadowColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1].CGColor;
    
    CGContextSetFillColorWithColor(context, dotColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 1, shadowColor);
    
    CGContextAddArc(context, 3, 3, 4, 0, radians, 0);
    CGContextFillPath(context);
    
    CGContextAddArc(context, 16, 16, 4, 0, radians, 0);
    CGContextFillPath(context);
    
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    
    CGColorRef bgColor = self.bgColour.CGColor;
    CGContextSetFillColorWithColor(context, bgColor);
    CGContextFillRect(context, layer.bounds);
    
    static const CGPatternCallbacks callbacks = { 0, &drawColouredPattern, NULL };
    
    CGContextSaveGState(context);
    CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern(NULL);
    CGContextSetFillColorSpace(context, patternSpace);
    CGColorSpaceRelease(patternSpace);
    
    CGPatternRef pattern = CGPatternCreate(NULL, layer.bounds, CGAffineTransformIdentity, 24, 24, kCGPatternTilingConstantSpacing, true, &callbacks);
    CGFloat alpha = 0.3;
    CGContextSetFillPattern(context, pattern, &alpha);
    CGPatternRelease(pattern);
    CGContextFillRect(context, layer.bounds);
    CGContextRestoreGState(context);
}

@end