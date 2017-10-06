//
//  IDSpecShape.m
//  iDispense
//
//  Created by Richard Henry on 09/12/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import "IDSpecShape.h"
#import "UIImage+ImageUtils.h"


@implementation IDSpecShape

- (instancetype)initWithImage:(UIImage *)image name:(NSString *)name {

    if ((self = [super init])) {

        // Initialisation
        self.image = image;
        self.thumbnail = [image imageScaledAndCroppedToSize:(CGSize ) { 64, 64 }];

        self.name = name;
    }

    return self;
}

@end
