//
//  IDImageProcessor.m
//  iDispense
//
//  Created by Richard Henry on 03/01/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDImageProcessor.h"


@implementation IDImageProcessor

+ (UIImage *)filterImage:(UIImage *)srcImage {

    // Filtering chain: InputImage -> Vibrance -> Gaussian blur -> Output image

    // Get the user preferences from the settings…
    const float gaussianBlurAmount = [[NSUserDefaults standardUserDefaults] floatForKey:@"gaussian_blur_amount_preference"];
    const float vibranceAmount = [[NSUserDefaults standardUserDefaults] floatForKey:@"vibrance_filter_amount_preference"];

    // Create a vibrance filter to enhance the colors a little bit (and leave pleasing fleshtones).
    CIFilter *vibranceFilter = [CIFilter filterWithName:@"CIVibrance" keysAndValues:kCIInputImageKey, [[CIImage alloc] initWithCGImage:srcImage.CGImage], @"inputAmount", @(vibranceAmount), nil];
    // Create a core image Gaussian Blur filter. Everybody loves a little bit of soft focus don't they.
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:kCIInputImageKey, [vibranceFilter valueForKey:kCIOutputImageKey], kCIInputRadiusKey, @(gaussianBlurAmount), nil];

    // Get the filtered image.
    CIImage *filteredImage = [blurFilter valueForKey:kCIOutputImageKey];

    // Create a CG image from the CI image the filter returned.
    // It turns out that if the image is converted straight to a UIImage from a CIImage, we can't convert it to a JPG later
    // on because it doesn't have a CGImageRef (see the documentation for UIImageJPEGRepresentation).
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:filteredImage fromRect:filteredImage.extent];

    // Create the UIImage that the caller expects from the CGImage and then release the CGImage.
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);

    // Return the UIImage we created from the CGImage we created from the CIImage from the filter.
    return image;
}

@end
