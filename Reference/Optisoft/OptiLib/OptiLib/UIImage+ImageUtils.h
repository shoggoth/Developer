//
//  UIImage+ImageUtils.h
//  OptiLib
//
//  Created by Richard Henry on 04/12/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//


@interface UIImage (ImageUtils)

// Images that are created from other things
+ (UIImage *)imageWithLayer:(CALayer *)layer;
+ (UIImage *)imageWithView:(UIView *)view;

// Image resizing / scaling
- (UIImage *)imageScaledToSize:(CGSize)newSize;
- (UIImage *)imageScaledAndCroppedToSize:(CGSize)newSize;
- (UIImage *)imageScaledProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageScaledProportionallyToMinimumSize:(CGSize)targetSize;

// Image rotation
- (UIImage *)imageRotatedByAngle:(CGFloat)angle;

// Sub-image
- (UIImage *)imageAtRect:(CGRect)rect;

// Thumbnail generation
- (UIImage *)image:(UIImage *)image inRoundedRectOfSize:(CGSize)roundedRectSize withCornerRadius:(float)cornerRadius;

@end
