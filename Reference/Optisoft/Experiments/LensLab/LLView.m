//
//  LLView.m
//  LensLab
//
//  Created by Optisoft Ltd on 07/10/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import "LLView.h"


@implementation LLView {
    
    NSPoint frontLensCurveVector;
    NSPoint backLensCurveVector;
}

- (id)initWithFrame:(NSRect)frame {
    
    if ((self = [super initWithFrame:frame])) {
        
        // Initialization code here.
        self.window.graphicsContext.shouldAntialias = NO;

        frontLensCurveVector = NSMakePoint(20, 40);
        backLensCurveVector = NSMakePoint(20, -40);
    }
    
    return self;
}

#pragma mark Custom drawing

- (void)drawRect:(NSRect)dirtyRect {
    
	[super drawRect:dirtyRect];
	
    // Drawing code.
    CGContextRef graphicsPort = self.window.graphicsContext.graphicsPort;
    
    CGContextSetRGBFillColor(graphicsPort, 0, 0, 1, .1);
    CGContextFillRect(graphicsPort, self.bounds);
    
    // Draw a lens
    const NSPoint lensSize = NSMakePoint(200, 20);
    const NSPoint lensPos =  NSMakePoint(NSMidX(self.bounds) - lensSize.x * 0.5, NSMidY(self.bounds) - lensSize.y * 0.5);
    
    // Draw lens
    NSBezierPath *bezierPath = [NSBezierPath bezierPath];
    [bezierPath setLineWidth:3];
    [[NSColor blackColor] setStroke];
    
    [bezierPath moveToPoint:lensPos];
    [bezierPath lineToPoint:NSMakePoint(lensPos.x, lensPos.y + lensSize.y)];
    [bezierPath curveToPoint:NSMakePoint(lensPos.x + lensSize.x, lensPos.y + lensSize.y)
               controlPoint1:NSMakePoint(lensPos.x + frontLensCurveVector.x, lensPos.y + lensSize.y + frontLensCurveVector.y)
               controlPoint2:NSMakePoint(lensPos.x + lensSize.x - frontLensCurveVector.x, lensPos.y + lensSize.y + frontLensCurveVector.y)];
    [bezierPath lineToPoint:NSMakePoint(lensPos.x + lensSize.x, lensPos.y)];
    [bezierPath curveToPoint:lensPos
               controlPoint1:NSMakePoint(lensPos.x + lensSize.x - backLensCurveVector.x, lensPos.y + backLensCurveVector.y)
               controlPoint2:NSMakePoint(lensPos.x + backLensCurveVector.x, lensPos.y + backLensCurveVector.y)];
    
    [bezierPath stroke];
    
    // Draw CP
    [bezierPath setLineWidth:2];
    [[NSColor redColor] setStroke];
    
    // Front left
    [bezierPath removeAllPoints];
    [bezierPath moveToPoint:NSMakePoint(lensPos.x, lensPos.y + lensSize.y)];
    [bezierPath lineToPoint:NSMakePoint(lensPos.x + frontLensCurveVector.x, lensPos.y + lensSize.y + frontLensCurveVector.y)];
    [bezierPath stroke];
    
    // Front right
    [bezierPath removeAllPoints];
    [bezierPath moveToPoint:NSMakePoint(lensPos.x + lensSize.x, lensPos.y + lensSize.y)];
    [bezierPath lineToPoint:NSMakePoint(lensPos.x + lensSize.x - frontLensCurveVector.x, lensPos.y + lensSize.y + frontLensCurveVector.y)];
    [bezierPath stroke];
    
    // Back left
    [bezierPath removeAllPoints];
    [bezierPath moveToPoint:NSMakePoint(lensPos.x, lensPos.y)];
    [bezierPath lineToPoint:NSMakePoint(lensPos.x + backLensCurveVector.x, lensPos.y + backLensCurveVector.y)];
    [bezierPath stroke];
    
    // Back right
    [bezierPath removeAllPoints];
    [bezierPath moveToPoint:NSMakePoint(lensPos.x + lensSize.x, lensPos.y)];
    [bezierPath lineToPoint:NSMakePoint(lensPos.x + lensSize.x - backLensCurveVector.x, lensPos.y + backLensCurveVector.y)];
    [bezierPath stroke];
}

#pragma mark Dynamic properties

- (float)frontLensVector_x { return frontLensCurveVector.x; }

- (void)setFrontLensVector_x:(float)x {
    
    frontLensCurveVector.x = x;
    
    [self setNeedsDisplay:YES];
}

- (float)frontLensVector_y { return frontLensCurveVector.y; }

- (void)setFrontLensVector_y:(float)y {
    
    frontLensCurveVector.y = y;
    
    [self setNeedsDisplay:YES];
}

- (float)backLensVector_x { return backLensCurveVector.x; }

- (void)setBackLensVector_x:(float)x {
    
    backLensCurveVector.x = x;
    
    [self setNeedsDisplay:YES];
}

- (float)backLensVector_y { return backLensCurveVector.y; }

- (void)setBackLensVector_y:(float)y {
    
    backLensCurveVector.y = y;
    
    [self setNeedsDisplay:YES];
}

@end
