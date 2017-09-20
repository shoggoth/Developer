//
//  DemoController.m
//  CIMessing
//
//  Created by Richard Henry on 13/07/2008.
//  Copyright 2008 University of Teesside. All rights reserved.
//

#import "DemoController.h"
#import "MyCIView.h"


@implementation DemoController

@synthesize user1;
@synthesize user2;
@synthesize user3;
@synthesize user4;

- (id)init {
	
	if (self = [super init]) {
		
		// Default values for sliders
		user1 = 0.5f;
		user2 = 0.5f;
		user3 = 0.5f;
		user4 = 0.5f;
	}
	
	return self;
}

- (void)dealloc {
	
	NSLog(@"DC dealloc");
	
}

- (void)awakeFromNib {
	
	CGRect accRect = NSRectToCGRect([myCIView bounds]);
	CIImageAccumulator *acc = [[CIImageAccumulator alloc] initWithExtent:accRect format:kCIFormatARGB8];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"alphaTest" ofType:@"gif"];
	//NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"bmp"];
	NSURL *url = [NSURL fileURLWithPath:path];
	testImage = [CIImage imageWithContentsOfURL:url];
	//testImage = [[CIImage alloc] initWith
	
	CIFilter *ccFilter = [CIFilter filterWithName:@"CIRandomGenerator"];
	[ccFilter setDefaults];
	
	/*NSDictionary *stringAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
									  [NSFont fontWithName:@"Arial" size:48], NSFontAttributeName,
									  //[NSNumber numberWithFloat:3.0], NSStrokeWidthAttributeName,
									  [NSColor clearColor], NSBackgroundColorAttributeName,
									  [NSColor whiteColor], NSForegroundColorAttributeName, nil];
	NSAttributedString *lowerString = [[NSAttributedString alloc] initWithString:@"Hello, World!!!11!!" attributes:stringAttributes];
	
	CIImage *strImage = [self imageFromString:lowerString withMargin:NSMakeSize(0.0f, 0.0f)];*/
	
	// Bump distortion filter
	bumpDistortion = [CIFilter filterWithName:@"CIBumpDistortion"];
	[bumpDistortion setDefaults];
	[bumpDistortion setValue:testImage forKey: @"inputImage"];
	[bumpDistortion setValue:[CIVector vectorWithX:100 Y:100] forKey: @"inputCenter"];
	[bumpDistortion setValue: @70.0f forKey: @"inputRadius"];
	[bumpDistortion setValue: @3.0f forKey: @"inputScale"];
	
//    testImage = [bumpDistortion valueForKey: @"outputImage"];
//	[bumpDistortion setValue: [NSNumber numberWithFloat:param1 * 6.0f] forKey: @"inputScale"];
//	[bumpDistortion valueForKey: @"outputImage"]
	
//	CIFilter *efrFilter = [CIFilter filterWithName:@"CIEightfoldReflectedTile"];
//	[efrFilter setDefaults];
//	[efrFilter setValue:[bumpDistortion valueForKey: @"outputImage"] forKey: @"inputImage"];
//	
//	[myCIView setImage:[efrFilter valueForKey: @"outputImage"]];
	
	[myCIView setImage:[bumpDistortion valueForKey: @"outputImage"]];

	//NSLog(@"Image = %@", [myCIView image]);
}

- (CIImage *)imageFromString:(NSAttributedString *)string withMargin:(NSSize)marginSize {
	
	NSImage				*image;
	NSBitmapImageRep	*bitmap;
	NSSize				frameSize = [string size];
	
	// Add padding to the string frame
	frameSize.width += marginSize.width * 2.0f;
	frameSize.height += marginSize.height * 2.0f;
	
	// Create a new NSImage and lock focus on it
	image = [[NSImage alloc] initWithSize:frameSize];
	[image lockFocus];
	[[NSGraphicsContext currentContext] setShouldAntialias:YES];
	
	// Draw the text
	[[NSColor blackColor] set];
	[NSBezierPath fillRect:NSMakeRect(0.0f, 0.0f, frameSize.width, frameSize.height)];
	[string drawAtPoint:NSMakePoint(marginSize.width, marginSize.height)];
	
	// Create a bitmap representation and thence the CI image
	bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0.0f, 0.0f, frameSize.width, frameSize.height)];
	CIImage *ciImage = [[CIImage alloc] initWithBitmapImageRep:bitmap];
	
	// Tidy up
	[image unlockFocus];
	
	return ciImage;
}

@end
