//
//  PGView.m
//  Paginator
//
//  Created by Richard Henry on 23/01/2014.
//  Copyright (c) 2014 Optisoft. All rights reserved.
//

#import "PGView.h"

@implementation PGView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
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
}

@end
