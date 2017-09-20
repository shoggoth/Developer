//
//  CVCellBackground.m
//  CollectionView
//
//  Created by Richard Henry on 08/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#import "CVCellBackground.h"


@implementation CVCellBackground

- (void)drawRect:(CGRect)rect {
    
    // Draw a rounded rect bezier path filled with blue
    CGContextRef aRef = UIGraphicsGetCurrentContext();
    CGContextSaveGState(aRef);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:5.0f];
    [bezierPath setLineWidth:5.0f];
    [[UIColor blackColor] setStroke];
    
    UIColor *fillColor = [UIColor colorWithRed:0.529 green:0.808 blue:0.922 alpha:1];
    [fillColor setFill];
    
    [bezierPath stroke];
    [bezierPath fill];
    
    CGContextRestoreGState(aRef);
}

@end


@implementation CVSelectedCellBackground

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
