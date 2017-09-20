//
//  DemoController.h
//  CIMessing
//
//  Created by Richard Henry on 13/07/2008.
//  Copyright 2008 University of Teesside. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>


@class MyCIView;

@interface DemoController : NSObject {
	
	// Parameters (bound from sliders)
	float					user1;
	float					user2;
	float					user3;
	float					user4;
	
	// CoreImage view subclass
	IBOutlet MyCIView		*myCIView;
	
	// CoreImage things
	CIImage					*testImage;
	CIFilter				*bumpDistortion;
}

@property float		user1;
@property float		user2;
@property float		user3;
@property float		user4;

- (CIImage *)imageFromString:(NSAttributedString *)string withMargin:(NSSize)marginSize;

@end
