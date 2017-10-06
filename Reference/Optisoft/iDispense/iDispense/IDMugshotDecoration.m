//
//  IDMugshotDecoration.m
//  iDispense
//
//  Created by Richard Henry on 29/01/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDMugshotDecoration.h"

#import <QuartzCore/QuartzCore.h>


// This is the information structure that is used to pass parameters between the pattern drawing callback function
// and the caller which generated the pattern.

struct info {

    float       perfWidth;
    CGPoint     perfOffset;
    float       cornerRadius;
};

// Callback function for the Core Graphics pattern drawer.

#pragma mark Callback

static void drawFilmPerforationPattern(void *info_ptr, CGContextRef context) {

    // Get the information structure that was passed in from the caller.
    struct info *info = info_ptr;

    // Set up the colours we'll be needing for the drawing of the film perforations.
    CGColorRef  holeColour = [UIColor colorWithWhite:1 alpha:1].CGColor;
    CGColorRef  shadowColour = [UIColor colorWithWhite:0 alpha:1].CGColor;
    CGPathRef   roundedRect = [UIBezierPath bezierPathWithRoundedRect:(CGRect) { info->perfOffset.x, info->perfOffset.y, info->perfWidth, info->perfWidth * 0.625 } cornerRadius:info->cornerRadius].CGPath;

    // Fill the path
    CGContextAddPath(context, roundedRect);
    CGContextSetFillColorWithColor(context, holeColour);
    CGContextFillPath(context);

    // Make the path be the context's clipping region.
    CGContextAddPath(context, roundedRect);
    CGContextClip(context);

    // Set up the shadow and stroke the path so that the shadow gets drawn.
    CGContextAddPath(context, roundedRect);
    CGContextSetShadowWithColor(context, CGSizeMake(1, 1), 3, shadowColour);
    CGContextSetStrokeColorWithColor(context, holeColour);
    CGContextStrokePath(context);
}

#pragma mark - Layer delegate

@interface OSFilmBorderLayerDelegate : NSObject

@end

@implementation OSFilmBorderLayerDelegate

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {

    // Save the state of the graphics context
    CGContextSaveGState(context);

    // Fill the background with the background colour.
    CGColorRef bgColour = layer.backgroundColor;
    CGContextSetFillColorWithColor(context, bgColour);
    CGContextFillRect(context, layer.bounds);

    // Set the callbacks for pattern filling.
    static const CGPatternCallbacks patternCallback = { 0, &drawFilmPerforationPattern, NULL };

    // Create a colour space for pattern drawing and set the fill colour space.
    CGColorSpaceRef patternFillColourSpace = CGColorSpaceCreatePattern(NULL);
    CGContextSetFillColorSpace(context, patternFillColourSpace);
    CGColorSpaceRelease(patternFillColourSpace);

    // Create the info structure that will be passed to the callback pattern drawer function.
    struct info info = { 18, { 3, 3 }, 3 };

    // Create the film fill pattern and set it to be the current fill pattern for this graphics context.
    CGPatternRef pattern = CGPatternCreate(&info, layer.bounds, CGAffineTransformIdentity, layer.bounds.size.width - 24, 24, kCGPatternTilingConstantSpacing, true, &patternCallback);
    CGFloat patternAlpha = 0.8;
    CGContextSetFillPattern(context, pattern, &patternAlpha);
    CGPatternRelease(pattern);

    CGContextFillRect(context, layer.bounds);

    // Restore the state of the graphics context.
    CGContextRestoreGState(context);
}

@end

#pragma mark - Mugshot decorator

@implementation IDMugshotDecoration

+ (void)decorateImage:(UIImage *)image withFilmPerforationsAndAddToLayer:(CALayer *)layer {

    static OSFilmBorderLayerDelegate *layerDrawDelegate;
    static dispatch_once_t onceToken;

    // The delegate is a singleton so all the layers here will call the same object.
    dispatch_once(&onceToken, ^{

        layerDrawDelegate = [OSFilmBorderLayerDelegate new];
    });

    // Block that adds the supplied sublayer to the layer that was supplied by the caller
    // and marks the layer as needing to be displayed.
    CALayer *(^addNewCALayer)() = ^{

        CALayer *newLayer = [CALayer layer];

        [layer addSublayer:newLayer];
        [newLayer setNeedsDisplay];

        return newLayer;
    };

    const CGRect subLayerRect = layer.frame;

    // Layer one is a background layer which looks like a photo frame or a movie frame with the tractor bits at the side or whatever they are called.
    // Ah, it turns out that those holes in the sided of the film are called perforations, at least that is what Wikipedia says and when is that oracle of all knowledge ever wrong.
    CALayer *filmDogLayer = addNewCALayer();
    filmDogLayer.frame = CGRectInset(subLayerRect, 30, 30);
    //filmDogLayer.delegate = layerDrawDelegate;
    filmDogLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:1].CGColor;

    // Layer two is an overlay to the background layer which contains the image that was supplied by the caller. In this layer, the image is drawn inside a rounded rectangle that
    // complements the film perforation pattern that was drawn into the background layer.
    CALayer *imageLayer = addNewCALayer();
    imageLayer.frame = CGRectInset(subLayerRect, 60, 60);
    imageLayer.backgroundColor = [UIColor blueColor].CGColor;
    imageLayer.contents = (__bridge id)(image.CGImage);
    imageLayer.cornerRadius = 10;
    imageLayer.masksToBounds = YES;
}

+ (void)decorateImage:(UIImage *)image withSnapPerforationsAndAddToLayer:(CALayer *)layer {

    NSLog(@"Unfinished: Decorating %@ with snap in layer %@", image, layer);
}

@end
