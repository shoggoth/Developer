//
//  UIImage+ImageUtils.m
//  OptiLib
//
//  Created by Richard Henry on 04/12/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#import "UIImage+ImageUtils.h"

#import <QuartzCore/QuartzCore.h>


@implementation UIImage (ImageUtils)

#pragma mark Image Production

+ (UIImage *)imageWithView:(UIView *)view {

    const float scale = 0;

    // Create a new graphics context that we can render the view into.
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, scale);

    [view.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithLayer:(CALayer *)layer {

    const float scale = 0;

    // Create a new graphics context that we can render the view into.
    UIGraphicsBeginImageContextWithOptions(layer.bounds.size, layer.opaque, scale);

    [layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return image;
}

#pragma mark Image Resize

- (UIImage *)imageScaledToSize:(CGSize)newSize {

    // Render to a new image context dependant on the aspect ratio
    if (self.size.height > self.size.width) {

        CGFloat finalHeight = self.size.height * newSize.width / self.size.width;

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(newSize.width, finalHeight), NO, 0);
        [self drawInRect:CGRectMake(0, 0, newSize.width, finalHeight)];

    } else {

        CGFloat finalWidth =  self.size.width * newSize.height / self.size.height;

        UIGraphicsBeginImageContextWithOptions( CGSizeMake(finalWidth, newSize.height), NO, 0);
        [self drawInRect:CGRectMake(0, 0, finalWidth, newSize.height)];
    }

    // Get the thumbnail image from the graphics context we just rendered to
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)imageScaledAndCroppedToSize:(CGSize)newSize {

    // Calculate the scale for the thumbnail image
    UIImage *scaledImage = [self imageScaledToSize:newSize];
    CGRect  rect = CGRectMake(0, MAX(0, (scaledImage.size.height - newSize.height) / 2), newSize.width, newSize.height);

    // Adjust the scale for the thumbnail image
    if (scaledImage.scale > 1.0f) rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(scaledImage.scale, scaledImage.scale));

    // Render the scaled image
    CGImageRef imageRef = CGImageCreateWithImageInRect(scaledImage.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:scaledImage.scale orientation:scaledImage.imageOrientation];
    CGImageRelease(imageRef);

    return result;
}

- (UIImage *)imageScaledProportionallyToSize:(CGSize)targetSize {

    UIImage *sourceImage = self;
    UIImage *newImage = nil;

    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;

    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;

    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;

    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);

    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {

        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;

        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;

        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;

        // Centre the image
        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }


    // Draw to context
    UIGraphicsBeginImageContext(targetSize);

    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;

    [sourceImage drawInRect:thumbnailRect];

    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    if(newImage == nil) NSLog(@"Could not scale UIImage");
    
    
    return newImage ;
}

- (UIImage *)imageScaledProportionallyToMinimumSize:(CGSize)targetSize {

    UIImage *sourceImage = self;
    UIImage *newImage = nil;

    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;

    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;

    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;

    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);

    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {

        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;

        if (widthFactor > heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;

        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;

        // Centre the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }

    // Draw to context
    UIGraphicsBeginImageContext(targetSize);

    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;

    [sourceImage drawInRect:thumbnailRect];

    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    if(newImage == nil) NSLog(@"Could not scale UIImage");


    return newImage ;
}

#pragma mark Image rotation

- (UIImage *)imageRotatedByAngle:(CGFloat)angle {

    // Calculate the size of the rotated view's containing box for our drawing space
    CGRect rotatedRect = CGRectApplyAffineTransform((CGRect) { .size = self.size }, CGAffineTransformMakeRotation(angle));
    CGSize rotatedSize = rotatedRect.size;

    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();

    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width * 0.5, rotatedSize.height * 0.5);

    // Rotate the image context
    CGContextRotateCTM(bitmap, angle);

    // Now, draw the rotated and scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(self.size.width * -0.5, self.size.height * -0.5, self.size.width, self.size.height), self.CGImage);

    // Get the image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

#pragma mark Sub-image

- (UIImage *)imageAtRect:(CGRect)rect {

    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *subImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);

    return subImage;
    
}

#pragma mark Thumbnail generation

- (UIImage *)image:(UIImage *)image inRoundedRectOfSize:(CGSize)roundedRectSize withCornerRadius:(float)cornerRadius {

    CGSize  origImageSize = [image size];
    CGRect  newRect = CGRectMake(0, 0, 40, 40);
    CGRect  projectRect;
    float   ratio = MAX(newRect.size.width / origImageSize.width, newRect.size.height / origImageSize.height);

    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);

    // Set the clipping region to be a rounded rectangle.
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:5.0];
    [path addClip];

    projectRect.size.width = ratio * origImageSize.width;
    projectRect.size.height = ratio * origImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) * 0.5;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) * 0.5;
    [image drawInRect:projectRect];

    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return smallImage;
}


@end

