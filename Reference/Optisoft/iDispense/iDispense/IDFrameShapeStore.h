//
//  IDFrameShapeStore.h
//  iDispense
//
//  Created by Richard Henry on 18/06/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//


//
//  interface IDFrameShapeStore
//
//  Unused in the current build.
//

@interface IDFrameShapeStore : NSObject

+ (instancetype)defaultFrameShapeStore;

- (NSUInteger)frameShapeCount;

- (NSString *)frameShapeDescriptionForFrameIndex:(NSInteger)index;
- (UIImage *)frameShapeThumbnailForFrameIndex:(NSInteger)index;

@end
