//
//  MyCIView.m
//  CIMessing
//
//  Created by Richard Henry on 11/07/2008.
//  Copyright 2008 University of Teesside. All rights reserved.
//

#import "MyCIView.h"

static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext);


@implementation MyCIView

@dynamic image;

- (id)initWithFrame:(NSRect)frame {
	
	// Specify pixel format
	NSOpenGLPixelFormatAttribute attr[] = { NSOpenGLPFAAccelerated, NSOpenGLPFANoRecovery, NSOpenGLPFAColorSize, 32, 0 };
	pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:(void *)&attr];
	
	if (self = [super initWithFrame:frame pixelFormat:pixelFormat]) {
		
		// Make context current and update
		[[self openGLContext] makeCurrentContext];
		[[self openGLContext] update];
		
		// Create frame lock
		frameLock = [[NSRecursiveLock alloc] init];
		
		// Observe window movements in case the window gets dragged to another monitor
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowChangedScreen:) name:NSWindowDidMoveNotification object:nil];
	}
	
	return self;
}

- (void)dealloc {

	// Stop the CV animation thread
	CVDisplayLinkStop(displayLink);
	
	// Dispose of the various things
	
}

- (void)awakeFromNib {
	
    CVReturn			error = kCVReturnSuccess;
    
	currentDisplayID = CGMainDisplayID();
	
	// Create CV animation thread on main monitor
    if (CVDisplayLinkCreateWithCGDisplay(currentDisplayID, &displayLink)) {
		
        NSLog(@"DisplayLink created with error:%d", error);
        displayLink = NULL;
        return;
    }
	
	// Set callback
    CVDisplayLinkSetOutputCallback(displayLink, MyDisplayLinkCallback, (__bridge void *)(self));
	
	// Start the CV animation thread
	CVDisplayLinkStart(displayLink);
}

#pragma mark Getting and setting image

- (void)setImage:(CIImage *)theImage {
	
	if (image == theImage) return;
	
	// Lock the rendering and change the image
	[frameLock lock];
	image = theImage;
	[frameLock unlock];
}

- (CIImage *)image {
	
	return image;
}

#pragma mark Drawing

- (CVReturn)displayFrame:(const CVTimeStamp *)timeStamp {
	
	@autoreleasepool {

		[self drawRect:[self bounds]];
		
#ifdef __DEBUG__
		int64_t secondNow = timeStamp->videoTime / timeStamp->videoTimeScale;
		if (secondNow != secondCounter) {
			
			NSLog(@"frame time = %lu", (unsigned long)frames);
			
			secondCounter = secondNow;
			frames = 0;
		}
		
		frames++;
#endif
		
		
		return kCVReturnSuccess;
	}
}

- (void)drawRect:(NSRect)rect {
	
	[frameLock lock];
	
	[[self openGLContext] makeCurrentContext];

	glClear(GL_COLOR_BUFFER_BIT);
	
	glPushMatrix();
	//glTranslatef(param2 * 512.0f, param3 * 256.0f, 0.0f);
	//glRotatef(param4 * 360.0f, 0.0f, 0.0f, 1.0f);
	//glScalef(2.0f, 2.0f, 0.0f);
	
    glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	[context drawImage:image atPoint:CGPointMake(0.0f, 0.0f) fromRect:NSRectToCGRect(rect)];
	
	glPopMatrix();
	glFlush();
	
	[frameLock unlock];
}

- (void)update {
	
	// Introduce some locking to the update
    [frameLock lock];
	[super update];
    [frameLock unlock];
}

#pragma mark OpenGL initialisation

- (void)prepareOpenGL {
    
	NSRect				bounds = [self bounds];
	
	// Disable OpenGL features we shan't be needing
    glDisable(GL_ALPHA_TEST);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_SCISSOR_TEST);
    glDisable(GL_BLEND);
    glDisable(GL_DITHER);
    glDisable(GL_CULL_FACE);
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    glDepthMask(GL_FALSE);
    glStencilMask(0);
	
	// Set default OpenGL parameters
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glHint(GL_TRANSFORM_HINT_APPLE, GL_FASTEST);
	
	glViewport(0, 0, bounds.size.width, bounds.size.height);
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0, bounds.size.width, 0, bounds.size.height, -1, 1);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	// Core image rendering context
	context = [CIContext contextWithCGLContext:CGLGetCurrentContext() pixelFormat:[pixelFormat CGLPixelFormatObj] colorSpace:CGColorSpaceCreateDeviceRGB() options:nil];
}

- (void)windowChangedScreen:(NSNotification*)inNotification {
	
	NSWindow *window = [self window];
	CGDirectDisplayID displayID = (CGDirectDisplayID)[[[window screen] deviceDescription][@"NSScreenNumber"] intValue];
	
	// Change the refresh rate to match the new monitor
	if(displayID && (currentDisplayID != displayID)) {
		
		CVDisplayLinkSetCurrentCGDisplay(displayLink, displayID);
		currentDisplayID = displayID;
        NSLog(@"Changed monitor");
	}
}

@end

#pragma mark Core Video callback

static CVReturn MyDisplayLinkCallback (CVDisplayLinkRef displayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext) {
	
	CVReturn error = [(__bridge MyCIView *)displayLinkContext displayFrame:inOutputTime];
	
	return error;
}