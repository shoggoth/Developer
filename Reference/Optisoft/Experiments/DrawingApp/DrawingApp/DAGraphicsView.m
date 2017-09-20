//
//  DAGraphicsView.m
//  DrawingApp
//
//  Created by Optisoft Ltd on 26/09/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import "DAGraphicsView.h"


@implementation DAGraphicsView

- (id)initWithFrame:(NSRect)frame {
    
    if ((self = self = [super initWithFrame:frame])) {
        
        self.foo = @0.5;
        
        srand((unsigned)time(NULL));
        
        [[NSRunLoop mainRunLoop] addTimer:[NSTimer timerWithTimeInterval:1 target:self selector:@selector(refresh) userInfo:nil repeats:YES] forMode:NSRunLoopCommonModes];
    }
    
    return self;
}

- (void)refresh { [self setNeedsDisplay:YES]; }

- (void)drawRect:(NSRect)dirtyRect {
    
	[super drawRect:dirtyRect];
	
    CGContextRef graphicsContext = [[NSGraphicsContext currentContext] graphicsPort];
    
    const int   figureDensity = 500;
    const int   figureDivs = 8;
    const float figureCellSize = 480 / figureDivs;
    
    const float xCentre = CGRectGetWidth(self.frame) * 0.5;
    const float yCentre = CGRectGetHeight(self.frame) * 0.5;
    
    CGContextSetRGBFillColor(graphicsContext, 0, 0, 0, 1);
    CGContextFillRect(graphicsContext, dirtyRect);
    
    CGContextSetRGBFillColor(graphicsContext, 1, 0, 0, [self.foo floatValue]);
    
    for (int y = 0; y < figureDivs; y++) {
        
        const float yPosition = yCentre + figureCellSize * (y - figureDivs * 0.5);
        
        for (int x = 0; x < figureDivs / 2; x++) {
            
            if ((rand() % 1000) < figureDensity) {
                
                CGContextFillRect(graphicsContext, CGRectMake(xCentre + figureCellSize * x, yPosition, figureCellSize, figureCellSize));
                CGContextFillRect(graphicsContext, CGRectMake(xCentre - figureCellSize * (x + 1), yPosition, figureCellSize, figureCellSize));
            }
        }
    }
}

@end
