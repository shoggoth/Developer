//
//  IDImageStore.m
//  iDispense
//
//  Created by Richard Henry on 03/02/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDImageStore.h"

#import <AssetsLibrary/AssetsLibrary.h>


@implementation IDImageStore {

    NSMutableDictionary     *imageCache;
    NSString                *documentDirectory;
    NSString                *imageCaptureDirectory;
}

+ (instancetype)defaultImageStore {

    static IDImageStore *defaultImageStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        defaultImageStore = [IDImageStore new];
    });

    return defaultImageStore;
}

- (instancetype)init {

    if ((self = [super init])) {

        // Initialise the image cache
        imageCache = [NSMutableDictionary dictionary];

        // Cache the document directory for later use when we are looking for the image cache.
        documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        imageCaptureDirectory = [documentDirectory stringByAppendingPathComponent:@"ImageCaptures"];


        // Register us for the low memory warning notification. In the case we receive one of these, we'll clear the image cache.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearImageCache:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }

    return self;
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Caching

- (void)clearImageCache:(NSNotification *)note {

    // Remove the references from the cache so that they will be reloaded from flash memory in the future.
    [imageCache removeAllObjects];
}

- (void)clearImageDiskCache {

    // Delete the image capture files within the standard image capture directory.
    NSError *err;
    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:imageCaptureDirectory error:&err];

    for (NSString *capture in directoryContents) {

        [[NSFileManager defaultManager] removeItemAtPath:[imageCaptureDirectory stringByAppendingPathComponent:capture] error:&err];
    }

    // There are no more images cached in the flash memory so we should clear the references to them.
    [self clearImageCache:nil];
}

- (void)clearMovieDiskCache {

    // Get the contents of the tmp directory that have been created by the movie capture.
    NSString *tempDirectoryPath = NSTemporaryDirectory();

    NSError *err;
    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tempDirectoryPath error:&err];
    NSArray *captures = [directoryContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH 'capture'"]];

    // Delete the movie capture directories within the tmp directory.
    for (NSString *capture in captures) {

        [[NSFileManager defaultManager] removeItemAtPath:[tempDirectoryPath stringByAppendingPathComponent:capture] error:&err];
    }
}
#pragma mark Image Keys

- (UIImage *)imageForKey:(NSString *)imageKey {

    // If possible, get it out of the cache
    UIImage *result = [imageCache objectForKey:imageKey];

    if (!result) {

        NSString *imagePath = [self capturedImagePathForKey:imageKey];

        // Create UIImage object from file
        result = [UIImage imageWithContentsOfFile:imagePath];

        // If we found an image on the file system, place it into the cache
        if (result) [imageCache setObject:result forKey:imageKey];
    }

    return result;
}

- (void)setImage:(UIImage *)image forKey:(NSString *)imageKey inDirectory:(NSString *)directoryName {

    // Store the image in the disctionary initially.
    [imageCache setObject:image forKey:imageKey];

    // Create full path for image
    NSString *imagePath = [self capturedImagePathForKey:imageKey];

    // Chuck this off to GCD so that the main thread isn't blocked.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        // Turn image into JPEG data
        NSData *jpegImageData = UIImageJPEGRepresentation(image, [[NSUserDefaults standardUserDefaults] floatForKey:@"jpeg_image_quality_preference"]);

        // Examine the directory we want to write to to see if it already exists and whether it's a directory of not if it does.
        NSFileManager   *fileManager = [NSFileManager defaultManager];
        NSError         *error;
        BOOL            fileExists, isDirectory;

        fileExists = [fileManager fileExistsAtPath:directoryName isDirectory:&isDirectory];

        // If the directory doesn't exist, it should be created
        if (!fileExists) {

            [fileManager createDirectoryAtPath:directoryName withIntermediateDirectories:YES attributes:nil error:&error];

            if (error) NSLog(@"IDImageStore: failed to create directory %@ (%@)", directoryName, error);
        }

        // If something exists at the specified path and it isn't a directory then we should delete it.
        // This shouldn't actually ever happen as this app. is sandboxed and nothing else should be able
        // to write to the directory structure but better to be safe than sorry eh.
        else if (!isDirectory) {

            [fileManager removeItemAtPath:directoryName error:&error];

            if (error) NSLog(@"IDImageStore: failed to remove non-directory %@ (%@)", directoryName, error);
        }

        // Write it to full path
        BOOL success = [jpegImageData writeToFile:imagePath options:NSDataWritingAtomic error:&error];
        if (!success) NSLog(@"IDImageStore: failed to write image data %@ (%@)", directoryName, error);
    });
}

- (void)setImage:(UIImage *)image forKey:(NSString *)imageKey {

    [self setImage:image forKey:imageKey inDirectory:imageCaptureDirectory];
}

- (void)deleteImageForKey:(NSString *)imageKey {

    if (!imageKey) return;

    [imageCache removeObjectForKey:imageKey];

    [[NSFileManager defaultManager] removeItemAtPath:[self capturedImagePathForKey:imageKey] error:NULL];
}

#pragma mark Asset Lib

- (void)getImageAssetAtURL:(NSURL *)mediaURL withCompletionBlock:(void(^)(UIImage *))completionBlock {

    ALAssetsLibrary *assetslibrary = [ALAssetsLibrary new];

    [assetslibrary assetForURL:mediaURL
                   resultBlock:^(ALAsset *asset) {

                       // We want the full resolution version of the picture that was chosen from the photo library.
                       ALAssetRepresentation *defaultRepresentation = [asset defaultRepresentation];
                       CGImageRef imageReference = [defaultRepresentation fullResolutionImage];

                       // We have got the image reference to the full resolution image, create a UIImage from it…
                       if (imageReference) completionBlock([UIImage imageWithCGImage:imageReference scale:defaultRepresentation.scale orientation:UIImageOrientationUp]);
                   }

                  failureBlock:^(NSError *error) { NSLog(@"IDImageStore failed to get image at URL %@ err %@", mediaURL, error); }
     ];
}

#pragma mark Preference Images

- (UIImage *)optometristLogo {

    return [UIImage imageWithData:[NSData dataWithContentsOfFile:[documentDirectory stringByAppendingPathComponent:@"OpticianLogo.png"]]];
}

- (void)setOptometristLogo:(UIImage *)logoImage {

    NSString *logoFileName = [documentDirectory stringByAppendingPathComponent:@"OpticianLogo.png"];
    NSData *imageData = UIImagePNGRepresentation(logoImage);

    // Write the image to a file in the Documents directory
    [imageData writeToFile:logoFileName atomically:YES];

    // Write the path to the png image to the preferences
    [[NSUserDefaults standardUserDefaults] setObject:logoFileName forKey:@"optometrist_logo_image_preference"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Utility

- (NSString *)capturedImagePathForKey:(NSString *)imageKey {

    return [imageCaptureDirectory stringByAppendingPathComponent:imageKey];
}

- (NSString *)imageCaptureDirectoryPath { return imageCaptureDirectory; }

@end
