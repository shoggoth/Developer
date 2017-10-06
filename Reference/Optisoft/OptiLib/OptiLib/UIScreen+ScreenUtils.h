//
//  UIScreen+ScreenUtils.h
//  OptiLib
//
//  Created by Richard Henry on 11/02/2014.
//  Copyright (c) 2014 Optisoft. All rights reserved.
//


@interface UIScreen (ScreenUtils)

// Discovery of screen capabilities
+ (float)screenScale;
+ (BOOL)isRetinaDisplay;

// Pixel dimensions
+ (CGSize)screenSizeInPixels;

@end
