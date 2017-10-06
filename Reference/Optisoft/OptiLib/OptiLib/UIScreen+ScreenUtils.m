//
//  UIScreen+ScreenUtils.m
//  OptiLib
//
//  Created by Richard Henry on 11/02/2014.
//  Copyright (c) 2014 Optisoft. All rights reserved.
//

#import "UIScreen+ScreenUtils.h"

@implementation UIScreen (ScreenUtils)

#pragma mark Discovery

+ (float)screenScale {

    static float screenScale = 1;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{

        UIScreen *mainScreen = self.mainScreen;

        if (mainScreen && [mainScreen respondsToSelector:@selector(scale)]) screenScale = mainScreen.scale;
    });
    
    return screenScale;
}

+ (BOOL)isRetinaDisplay {

    return [self screenScale] > 1;
}

#pragma mark Dimensions

+ (CGSize)screenSizeInPixels {

    float screenScale = [self screenScale];

    return CGSizeApplyAffineTransform([UIScreen mainScreen].bounds.size, CGAffineTransformMakeScale(screenScale, screenScale));
}
@end
