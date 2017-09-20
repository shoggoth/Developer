//
//  FCViewController.m
//  FilterChain
//
//  Created by Richard Henry on 07/01/2014.
//  Copyright (c) 2014 Optisoft. All rights reserved.
//

#import "FCViewController.h"


@interface CIImage (ImageNamed)

+ (CIImage *)imageNamed:(NSString *)imageName;

@end

@implementation CIImage (ImageNamed)

+ (CIImage *)imageNamed:(NSString *)imageName; { return [[CIImage alloc] initWithCGImage:[UIImage imageNamed:imageName].CGImage]; }

@end


@interface FCViewController ()

@end

@implementation FCViewController {

    __weak IBOutlet UIImageView *imageView;

    CIImage                     *sourceImage;
    CIImage                     *blurredImage;

    CIFilter                    *affineTransformFilter;
    CIFilter                    *blendWithMaskFilter;

    CGAffineTransform           transform;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    unsigned long foo = '    ';

    printf("foo = %lu %lx", foo, foo);

    // Source image
    sourceImage = [CIImage imageNamed:@"Stonehenge_16_9.png"];

    // Create a Gaussian blur filter
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:kCIInputImageKey, sourceImage, kCIInputRadiusKey, @3, nil];
    // Make a blur-filtered image
    blurredImage = [blurFilter valueForKey:kCIOutputImageKey];

    // Create a mask image
    CIImage *maskImage = [CIImage imageNamed:@"LensMask.png"];

    // Create a transform of the mask image
    transform = CGAffineTransformIdentity;
    affineTransformFilter = [CIFilter filterWithName:@"CIAffineTransform" keysAndValues:kCIInputImageKey, maskImage, kCIInputTransformKey, [NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)], nil];

    // Create a mask filter
    blendWithMaskFilter = [CIFilter filterWithName:@"CIBlendWithAlphaMask" keysAndValues:kCIInputImageKey, sourceImage, kCIInputBackgroundImageKey, blurredImage, kCIInputMaskImageKey, [affineTransformFilter valueForKey:kCIOutputImageKey], nil];

    // Apply to image view
    imageView.image = [UIImage imageWithCIImage:[blendWithMaskFilter valueForKey:kCIOutputImageKey]];
}

#pragma mark Updates

- (void)refresh {

    transform = CGAffineTransformMakeScale(20, 2);
    [affineTransformFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:kCIInputTransformKey];
    imageView.image = [UIImage imageWithCIImage:[blendWithMaskFilter valueForKey:kCIOutputImageKey]];
    //imageView.image = [UIImage imageWithCIImage:[affineTransformFilter valueForKey:kCIOutputImageKey]];
}

#pragma mark Gesture actions

- (IBAction)panGesture:(UIPanGestureRecognizer *)recogniser {

    static CGPoint lastPosition;
    CGPoint position = [recogniser translationInView:recogniser.view.superview];

    if (recogniser.state == UIGestureRecognizerStateBegan) lastPosition = position;

    else {

        CGPoint delta = CGPointMake(position.x - lastPosition.x, position.y - lastPosition.y);

        transform = CGAffineTransformTranslate(transform, delta.x, delta.y);

        [self refresh];

        lastPosition = position;
    }
}

@end
