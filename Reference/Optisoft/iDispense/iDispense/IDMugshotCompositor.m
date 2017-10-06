//
//  IDMugshotCompositor.m
//  iDispense
//
//  Created by Richard Henry on 29/01/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDMugshotCompositor.h"
#import "IDMugshot.h"
#import "IDImageStore.h"
#import "IDSharingController.h"
#import "IDDispensingDataStore.h"
#import "UIImage+ImageUtils.h"
#import "CALayer+LayerUtils.h"


@implementation IDMugshotCompositor

#pragma mark Mugshot drawing

+ (NSArray *)compositeMugshots:(NSArray *)mugshots {

    const BOOL  watermarking = [[[NSUserDefaults standardUserDefaults] objectForKey:@"optometrist_watermark_preference"] boolValue];
    CGSize      imageSize = [IDSharingController shareImageRect].size;

    NSMutableArray  *imageArray = [NSMutableArray array];

    for (id <IDMugshot> mugshot in mugshots) {

        CALayer *imageLayer = [CALayer layerWithFrame:(CGRect) { 0, 0, imageSize }];

        // Set up the image drawing layer
        imageLayer.backgroundColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
        imageLayer.contents = (__bridge id)([mugshot generatePreviewImageOfSize:imageSize].CGImage);
        imageLayer.cornerRadius = 3;
        imageLayer.masksToBounds = YES;

        // Set up the annotation layer
        CATextLayer *annotationLayer = [CATextLayer layer];

        // Annotation layer general properties.
        annotationLayer.frame = CGRectInset((CGRect) { .size = imageSize }, 3, 3);
        annotationLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0].CGColor;
        annotationLayer.foregroundColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
        annotationLayer.contentsScale = [[UIScreen mainScreen] scale];

        // Annotation layer text properties.
        annotationLayer.font = (__bridge CFTypeRef)(@"Helvetica-Bold");
        annotationLayer.fontSize = [IDSharingController shareImageFontSize];
        annotationLayer.alignmentMode = kCAAlignmentRight;

        // Annotiation layer content.
        annotationLayer.string = [NSString stringWithFormat:@"%lu", (unsigned long)mugshot.index];

        [imageLayer addSublayer:annotationLayer];

        if (watermarking) {

            // Set up the optometrist spiel layer.
            const float     halfWidth = imageSize.width * 0.5;
            const float     mostOfHeight = imageSize.height * 0.8;
            const CGSize    spielImageBorderSize = (CGSize) { 5, 5 };
            CGRect          spielImageFrame = CGRectMake(halfWidth, mostOfHeight, halfWidth, imageSize.height - mostOfHeight);
            UIImage         *spielImage = [[[IDImageStore defaultImageStore] optometristLogo] imageScaledProportionallyToSize:spielImageFrame.size];

            CALayer *spielImageLayer = [CALayer layerWithFrame:CGRectInset(spielImageFrame, spielImageBorderSize.width, spielImageBorderSize.height)];

            // Spiel image layer general properties.
            spielImageLayer.opacity = [[[NSUserDefaults standardUserDefaults] objectForKey:@"optometrist_logo_alpha_preference"] floatValue];
            spielImageLayer.contents = (__bridge id)spielImage.CGImage;

            [imageLayer addSublayer:spielImageLayer];

        } else {

            // Set up optometrist name layer
            CATextLayer *spielTextLayer = [CATextLayer layer];

            const float fontSize = [IDSharingController shareImageOptometristFontSize];

            spielTextLayer.frame = CGRectMake(0, imageSize.height - fontSize - 2, imageSize.width, fontSize + 2);
            spielTextLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0].CGColor;
            spielTextLayer.foregroundColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
            spielTextLayer.contentsScale = [[UIScreen mainScreen] scale];

            spielTextLayer.font = (__bridge CFTypeRef)(@"Helvetica");
            spielTextLayer.fontSize = fontSize;
            spielTextLayer.alignmentMode = kCAAlignmentRight;

            // Optometrist name layer content.
            NSDictionary *practiceDetails = [IDDispensingDataStore defaultDataStore].practiceDetails;
            NSString *practiceName = [practiceDetails objectForKey:@"practiceName"];
            spielTextLayer.string = practiceName;
            
            [imageLayer addSublayer:spielTextLayer];
        }

        // Render the layer to the image.
        [imageArray addObject:[imageLayer renderToImage]];
    }

    return imageArray;
}

+ (NSArray *)compositeMugshots:(NSArray *)mugshots inImagesWithSize:(CGSize)imageSize imagesPerPage:(const int)imagesPerPage {

    long        count = mugshots.count;

    // First of all, check if there have been at least one image supplied otherwise how can we expect to do any pagination.
    if (!count) return nil;

    NSMutableArray  *imageArray = [NSMutableArray array];
    const float     borderSize = 20;
    CGSize          imageRenderSize = imageSize;
    int             arrayImageIndex = 0;

    for (; count > 0; count -= imagesPerPage) {

        CALayer     *rootLayer = [CALayer layerWithFrame:(CGRect) { 0, 0, imageSize }];
        const long  imagesOnThisPage = (count > imagesPerPage) ? imagesPerPage : count;

        // Set up the root layer that we are going to render the page content into.
        // For each page that we render, there will be a layer created for the root which will end up being rendered itself into an
        // image that will be returned to the caller in an array of images.
        rootLayer.backgroundColor = [UIColor colorWithWhite:1 alpha:1].CGColor;

        // Render the images into the root layer we just set up.
        for (int thisPageImageIndex = 0; thisPageImageIndex < imagesOnThisPage; thisPageImageIndex++) {

            void (^pageCompletionBlock)(CALayer *layer);

            if (imagesOnThisPage == 1) {

                // Reset the image render size for the new page of images.
                imageRenderSize = imageSize;

                // Reduce the needed size so that we get a border on both sides of the image
                imageRenderSize.width -= borderSize * 2;
                imageRenderSize.height -= borderSize * 2;

                pageCompletionBlock = ^(CALayer *layer) {

                    // There is only one image, just draw it with a border. Translate to the border size we made room for above this block.
                    layer.transform = CATransform3DMakeTranslation(borderSize, borderSize, 0);
                };

            } else if (imagesOnThisPage == 2) {

                //imageRenderSize = (CGSize) { imageSize.width - borderSize * 2, imageSize.height - borderSize * 2 };

                pageCompletionBlock = ^(CALayer *layer) {

                    // In this case, there are two images. Rotate them by 90 degrees and position them side by side to make the most of the available space.
                    float aspect = imageSize.width / (imageSize.height + borderSize * 2);
                    CATransform3D transform = CATransform3DIdentity;

                    transform = CATransform3DRotate(transform, M_PI * 0.5, 0, 0, 1);
                    transform = CATransform3DScale(transform, aspect, aspect, 1);
                    transform = CATransform3DTranslate(transform, thisPageImageIndex * 100 - 50, 0, 0);
                    layer.transform = transform;
                };
                
            } else if (imagesOnThisPage == 3) {

                pageCompletionBlock = ^(CALayer *layer) {

                    // In this case, there are three images. Rotate them by 90 degrees and position them side by side to make the most of the available space.
                    float aspect = imageSize.width / (imageSize.height + borderSize * 2);
                    CATransform3D transform = CATransform3DIdentity;

                    transform = CATransform3DRotate(transform, M_PI * 0.5, 0, 0, 1);
                    transform = CATransform3DScale(transform, aspect, aspect, 1);
                    transform = CATransform3DTranslate(transform, thisPageImageIndex * 100 - 50, 0, 0);
                    layer.transform = transform;
                };
                
            } else {

                pageCompletionBlock = ^(CALayer *layer) {

                    // In this case, there are more than three images. Rotate them by 90 degrees and position them side by side to make the most of the available space.
                    float aspect = imageSize.width / (imageSize.height + borderSize * 2);
                    CATransform3D transform = CATransform3DIdentity;

                    transform = CATransform3DRotate(transform, M_PI * 0.5, 0, 0, 1);
                    transform = CATransform3DScale(transform, aspect, aspect, 1);
                    transform = CATransform3DTranslate(transform, thisPageImageIndex * 100 - 50, 0, 0);
                    layer.transform = transform;
                };
            }

            id <IDMugshot> mugshot = [mugshots objectAtIndex:arrayImageIndex];

            arrayImageIndex++;

            // Determine the type of the mugshot we are dealing with here. If it's a movie then we can use the thumbnail
            // and if we have an image then let's use the full size image.

            UIImage *imageToComposite = [mugshot generatePreviewImageOfSize:imageRenderSize];
            // UIImage *imageToComposite = [mugshot generatePreviewImageToBestFitSize:imageSize allowRotation:YES];

            NSString *annotation = [NSString stringWithFormat:@"Image %lu", (unsigned long)mugshot.index];
            [self createBorderedLayerWithImage:imageToComposite annotation:annotation inLayer:rootLayer withCompletion:pageCompletionBlock];
        }

        // Render the layer to the image.
        [imageArray addObject:[rootLayer renderToImage]];
    }

    return imageArray;
}

+ (void)createBorderedLayerWithImage:(UIImage *)image annotation:(NSString *)annotation inLayer:(CALayer *)rootLayer withCompletion:(void(^)(CALayer *))completionBlock {

    const BOOL imageIsQuiteLarge = (image.size.width > 256);

    const float shadowRadius = 3;
    const float shadowOpacity = 0.3;
    const float cornerRadius = 7;
    const float borderWidth = 3;
    const float borderLineWidth = 1;
    const float fontSize = 32;

    CALayer *(^createBorderedLayerWithImage)(UIImage *image) = ^(UIImage *image) {

        CGRect frame = (CGRect) { .size = image.size};

        // Add the background layer to the view's root layer.
        CALayer *bgLayer = [CALayer layer];

        bgLayer.frame = CGRectInset(frame, -borderWidth, -borderWidth);
        bgLayer.backgroundColor = [UIColor whiteColor].CGColor;

        // Background layer shadow
        bgLayer.shadowOffset = (CGSize) { 0, shadowRadius };
        bgLayer.shadowRadius = shadowRadius;
        bgLayer.shadowColor = [UIColor blackColor].CGColor;
        bgLayer.shadowOpacity = shadowOpacity;

        // Background layer border
        bgLayer.borderColor = [UIColor blackColor].CGColor;
        bgLayer.borderWidth = borderLineWidth;
        bgLayer.cornerRadius = cornerRadius;

        [rootLayer addSublayer:bgLayer];

        // Add the image layer to the background layer that we created just now.
        CALayer *imageLayer = [CALayer layer];
        imageLayer.contents = (__bridge id)(image.CGImage);
        imageLayer.frame = CGRectOffset(frame, borderWidth, borderWidth);

        imageLayer.cornerRadius = cornerRadius;

        imageLayer.masksToBounds = YES;

        [bgLayer addSublayer:imageLayer];

        // Add the annotation layer that contains the index number as an overlay to the image layer and the background layer.
        CATextLayer *annotationLayer = [CATextLayer layer];

        annotationLayer.frame = CGRectInset(frame, 0, borderWidth);
        annotationLayer.foregroundColor = [UIColor whiteColor].CGColor;

        // Annotation layer text properties.
        annotationLayer.font = (__bridge CFTypeRef)(@"Helvetica-Bold");
        annotationLayer.fontSize = fontSize;
        annotationLayer.alignmentMode = kCAAlignmentRight;

        // Annotiation layer content.
        annotationLayer.string = annotation;

        // Annotation layer shadow.
        annotationLayer.shadowOffset = (CGSize) { 0, shadowRadius };
        annotationLayer.shadowRadius = shadowRadius;
        annotationLayer.shadowColor = [UIColor blackColor].CGColor;
        annotationLayer.shadowOpacity = shadowOpacity;

        [bgLayer addSublayer:annotationLayer];

        if (imageIsQuiteLarge) {

            // Add the spiel layers that contain the optician's spiel (text and image)
            CALayer *spielImageLayer = [CALayer layer];

            UIImage *spielImage = [[IDImageStore defaultImageStore] optometristLogo];
            spielImageLayer.frame = (CGRect) { frame.size.width * 0.5 - spielImage.size.width * 0.5, frame.size.height - spielImage.size.height - borderLineWidth, spielImage.size };
            spielImageLayer.opacity = [[[NSUserDefaults standardUserDefaults] objectForKey:@"optometrist_logo_alpha_preference"] floatValue];
            spielImageLayer.contents = (__bridge id)spielImage.CGImage;

            CATextLayer *spielTextLayer = [CATextLayer layer];

            spielTextLayer.frame = CGRectMake(frame.origin.x + borderWidth, frame.size.height - 40, frame.size.width - (borderWidth * 2), 40);
            spielTextLayer.foregroundColor = [UIColor blackColor].CGColor;

            // Annotation layer text properties.
            spielTextLayer.font = (__bridge CFTypeRef)(@"Helvetica");
            spielTextLayer.fontSize = 18;
            spielTextLayer.alignmentMode = kCAAlignmentCenter;

            // Annotation layer content.
            NSDictionary *practiceDetails = [IDDispensingDataStore defaultDataStore].practiceDetails;
            NSString *practiceName = [practiceDetails objectForKey:@"practiceName"];
            spielTextLayer.string = practiceName;
            
            [bgLayer addSublayer:spielImageLayer];
            [bgLayer addSublayer:spielTextLayer];
        }

        // Display the root layer
        [bgLayer setNeedsDisplay];

        return bgLayer;
    };

    // Create a bordered layer out of the image that the caller supplied.
    CALayer *imageLayer = createBorderedLayerWithImage(image);

    // If there is a completion block, apply it to the layer that we just created.
    // This is the perfect place to apply transforms to the new layer and suchlike.
    if (completionBlock) completionBlock(imageLayer);
}

@end
