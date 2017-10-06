//
//  DSView.m
//  Dogstar Engine 2011 (Unified)
//
//  Created by Richard Henry on 16/09/2011.
//  Copyright (c) 2011 Dogstar Diversions. All rights reserved.
//

#import "DSView.h"
#import "DSDrawContext.h"


@implementation DSView

@synthesize context;
@synthesize delegate;

+ (Class)layerClass { return [CAEAGLLayer class]; }

- (id)initWithFrame:(CGRect)frame {

    if ((self = [super initWithFrame:frame])) { [self setup]; }

    return self;
}

- (void)awakeFromNib { [super awakeFromNib]; [self setup]; }

- (void)dealloc {

    context = nil;
}

#pragma mark Setup

- (void)setup {

    // Defaults are set here. If they need to be changed, the delegate can do so before the layer is attached.
    self.depthBuffer = NO;
    self.contentScaleFactor = [[UIScreen mainScreen] scale];

    // Get the backing layer (this should have been set as the required layer in + (Class)layerClass
    CAEAGLLayer *glLayer = (CAEAGLLayer *)self.layer;

    // Set up the layer
    glLayer.opaque = YES;
    glLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking : @NO, kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8 };

    // Create a new draw context
    context = [DSDrawContext new];

    // Inform the delegate that the view is about to be set up
    [delegate view:self willPrepareDrawContext:context];

    // Attach the draw context to the backing layer
    [context attachToCAEAGLLayer:(CAEAGLLayer *)self.layer depthBuffer:self.depthBuffer];

    // Inform the delegate that the view is set up
    [delegate view:self didPrepareDrawContext:context];
}

#pragma mark Rendering

- (void)render:(CADisplayLink *)link {

#if defined (DEBUG)
    glPushGroupMarkerEXT(0, "DSView render");
#endif

    [delegate view:self willRenderToContext:context];

#if defined (DEBUG)
    glPopGroupMarkerEXT();
#endif
}

@end

