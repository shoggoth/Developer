//
//  IDFrameShapeStore.m
//  iDispense
//
//  Created by Richard Henry on 18/06/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDFrameShapeStore.h"


@implementation IDFrameShapeStore {

    NSDictionary        *frameShapes;
}

+ (instancetype)defaultFrameShapeStore {

    static IDFrameShapeStore *defaultFrameShapeStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        defaultFrameShapeStore = [IDFrameShapeStore new];
    });

    return defaultFrameShapeStore;
}

- (instancetype)init {

    if ((self = [super init])) {

        // Dictionary initialisation
        // index, thumb image name, model name
        frameShapes = @{
                        @0 : @[ @"OMAThumb_0", @"shape1_oma_polar", @"OMA 1" ],
                        @1 : @[ @"OMAThumb_1", @"shape2_oma_polar", @"OMA 2" ],
                        @2 : @[ @"OMAThumb_2", @"shape3_oma_polar", @"OMA 3" ],
                        @3 : @[ @"OMAThumb_3", @"shape4_oma_polar", @"OMA 4" ],
                        @4 : @[ @"OMAThumb_4", @"shape5_oma_polar", @"OMA 5" ],
                        @5 : @[ @"OMAThumb_5", @"shape6_oma_polar", @"OMA 6" ],
                        @6 : @[ @"OMAThumb_6", @"shape7_oma_polar", @"OMA 7" ],
                        @7 : @[ @"OMAThumb_7", @"shape8_oma_polar", @"OMA 8" ]
                        };
    }

    return self;
}

- (NSUInteger)frameShapeCount {

    return frameShapes.count;
}

- (NSString *)frameShapeDescriptionForFrameIndex:(NSInteger)index {

    NSArray *frameShapeDetails = frameShapes[@(index)];

    return frameShapeDetails[2];
}

- (UIImage *)frameShapeThumbnailForFrameIndex:(NSInteger)index {

    NSArray *frameShapeDetails = frameShapes[@(index)];

    return [UIImage imageNamed:frameShapeDetails[0]];
}

@end
