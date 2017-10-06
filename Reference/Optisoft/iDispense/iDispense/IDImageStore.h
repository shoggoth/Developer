//
//  IDImageStore.h
//  iDispense
//
//  Created by Richard Henry on 03/02/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//


//
//  interface IDImageStore
//
//  As a part of the MVCS paradigm, this class supports the keying of large images and thumbnails
//  with flash-backed storage. Also supports the clearing of its internal caches when a low memory
//  condition arises.
//

@interface IDImageStore : NSObject

+ (instancetype)defaultImageStore;

@property(nonatomic, readonly) NSString *imageDirectoryPath;

// Dispose of cached files
- (void)clearImageDiskCache;
- (void)clearMovieDiskCache;

// Image keying and caching
- (UIImage *)imageForKey:(NSString *)imageKey;
- (void)setImage:(UIImage *)image forKey:(NSString *)imageKey;
- (void)deleteImageForKey:(NSString *)imageKey;

// Asset library
- (void)getImageAssetAtURL:(NSURL *)mediaURL withCompletionBlock:(void(^)(UIImage *))completionBlock;

// Preference images
- (UIImage *)optometristLogo;
- (void)setOptometristLogo:(UIImage *)logo;

@end
