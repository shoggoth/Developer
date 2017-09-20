//
//  MyCIView.h
//  CIMessing
//
//  Created by Richard Henry on 11/07/2008.
//  Copyright 2008 University of Teesside. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreVideo/CoreVideo.h>
#import <QuartzCore/QuartzCore.h>

@interface MyCIView : NSOpenGLView {
	
	// OpenGL specific things
	NSOpenGLPixelFormat		*pixelFormat;
	
	// CoreImage things
	CIContext				*context;
	CIImage					*image;
	
	// Timing by CoreVideo
	CVDisplayLinkRef		displayLink;
	CGDirectDisplayID		currentDisplayID;
	NSRecursiveLock			*frameLock;
	
	// FPS counting
	NSUInteger				frames;
	int64_t					secondCounter;
}

@property(weak) CIImage     *image;

@end
