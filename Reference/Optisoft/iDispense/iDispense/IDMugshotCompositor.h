//
//  IDMugshotCompositor.h
//  iDispense
//
//  Created by Richard Henry on 29/01/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//


//
//  interface IDMugshotCompositor
//
//  This class contains methods that are used to composite a number of images into a larger image in preparation
//  for sharing or to create decorated images for layouts.
//

@interface IDMugshotCompositor : NSObject

+ (NSArray *)compositeMugshots:(NSArray *)mugshots;
+ (NSArray *)compositeMugshots:(NSArray *)mugshots inImagesWithSize:(CGSize)imageSize imagesPerPage:(const int)imagesPerPage;

+ (void)createBorderedLayerWithImage:(UIImage *)image annotation:(NSString *)annotation inLayer:(CALayer *)rootLayer withCompletion:(void(^)(CALayer *))completionBlock;

@end
