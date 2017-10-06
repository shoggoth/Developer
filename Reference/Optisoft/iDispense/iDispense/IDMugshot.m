//
//  IDMugshot.m
//  iDispense
//
//  Created by Richard Henry on 04/12/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import "IDMugshot.h"
#import "UIImage+ImageUtils.h"
#import "NSString+StringUtils.h"
#import "IDImageStore.h"

@import AVFoundation;


#pragma mark Mugshot

@implementation IDMugshot

- (instancetype)init {

    if ((self = [super init])) {

        // Default when the capture device is locked to portrait, can be set after initialisation by the image capture delegate if that's required.
        self.orientation = UIInterfaceOrientationPortrait;

        // Generate a unique string to identify the captured image.
        imageKey = [NSString uniqueIdentifierString];
    }

    return self;
}

- (void)dealloc {

    // No longer need this image so we can delete it from the shared store
    [[IDImageStore defaultImageStore] deleteImageForKey:imageKey];
}

#pragma mark IDMugshot conformance

- (UIImage *)generatePreviewImageOfSize:(CGSize)previewImageSize {

    UIImage *previewImage;

    // See if the preview image of the size we require is already in the image store…
    NSString *previewImageKey = [NSString stringWithFormat:@"%@-Preview-%@", imageKey, NSStringFromCGSize(previewImageSize)];

    if (!(previewImage = [[IDImageStore defaultImageStore] imageForKey:previewImageKey])) {

        // The preview image was not found in the image store so let's create it and add it to the image store in case it
        // is needed in the future.

        // Create the preview image…
        previewImage = [[[IDImageStore defaultImageStore] imageForKey:imageKey] imageScaledAndCroppedToSize:previewImageSize];

        // Store it for future use…
        [[IDImageStore defaultImageStore] setImage:previewImage forKey:previewImageKey];
    }

    return previewImage;
}

@end

#pragma mark - Image mugshot

@implementation IDMugshotImage

- (instancetype)initWithImage:(UIImage *)img {

    if ((self = [super init])) {

        // Store the captured default image in the image store (identified by the unique string we just generated).
        [[IDImageStore defaultImageStore] setImage:img forKey:imageKey];
    }

    return self;
}

- (UIImage *)image { return [[IDImageStore defaultImageStore] imageForKey:imageKey]; }

@end

#pragma mark - Movie mugshot

@implementation IDMugshotMovie

- (instancetype)initWithURL:(NSURL *)url {

    if ((self = [super init])) {

        // Initialisation
        self.movieURL = url;

        // Create an asset image generator. This will allow us to generate a still 'preview' image from the captured movie.
        AVAssetImageGenerator *imageGen = [[AVAssetImageGenerator alloc] initWithAsset:[[AVURLAsset alloc] initWithURL:self.movieURL options:nil]];
        imageGen.appliesPreferredTrackTransform = YES;

        // Try to generate the thumbnail image from the preview.
        NSError *error = nil;
        CMTime  actualTime;
        CMTime  wantedTime = CMTimeMakeWithSeconds(0.0, 600);
        UIImage *img = [[UIImage alloc] initWithCGImage:[imageGen copyCGImageAtTime:wantedTime actualTime:&actualTime error:&error]];

        // Generate a unique string to identify the captured image
        imageKey = [NSString uniqueIdentifierString];

        // Store the captured default image in the image store (identified by the unique string we just generated).
        [[IDImageStore defaultImageStore] setImage:img forKey:imageKey];
    }

    return self;
}

- (void)dealloc {

    // Delete the cached movie
    NSError *err;
    [[NSFileManager defaultManager] removeItemAtURL:self.movieURL error:&err];

    // Delete the cached preview image
    [[IDImageStore defaultImageStore] deleteImageForKey:imageKey];

    // Remove the references to the movie file we just deleted.
    self.movieURL = nil;
}

@end