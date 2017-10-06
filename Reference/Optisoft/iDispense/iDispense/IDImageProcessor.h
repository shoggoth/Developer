//
//  IDImageProcessor.h
//  iDispense
//
//  Created by Richard Henry on 03/01/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//


//
//  interface IDImageProcessor
//
//  Contains functionality that allows the processing of images so that they make the customer
//  appear better looking and complement the frames they're trying on.
//
//  At the moment, the image filtering consists of the application of a vibrance filter to
//  enhance colour followed by a Gaussian blur filter to provide a little soft focus. The
//  parameters for both these filters can be altered in the application's settings.
//

@interface IDImageProcessor : NSObject

+ (UIImage *)filterImage:(UIImage *)srcImage;

@end
