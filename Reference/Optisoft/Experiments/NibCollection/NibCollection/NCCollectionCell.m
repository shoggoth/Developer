//
//  NCCollectionCell.m
//  NibCollection
//
//  Created by Richard Henry on 25/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#import "NCCollectionCell.h"
#import "NCCollectionCellBackground.h"


@implementation NCCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {

    if ((self = [super initWithFrame:frame])) { [self setup]; }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {

    if ((self = [super initWithCoder:decoder])) { [self setup]; }

    return self;
}

- (void)setup {

    // Change to our custom selected background view
    self.backgroundView = [[NCCollectionCellBackground alloc] initWithFrame:CGRectZero];
    self.selectedBackgroundView = [[NCCollectionSelectedCellBackground alloc] initWithFrame:CGRectZero];

//    CALayer *layer;
//
//    layer = [CALayer layer];
//    layer.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.5].CGColor;
//    layer.frame = CGRectInset(self.frame, 8, 8);
//    [self.layer addSublayer:layer];
//
//    layer = [CALayer layer];
//    layer.backgroundColor = [UIColor redColor].CGColor;
//    layer.frame = (CGRect) { 0, 0, 75, 75 };
//    [self.layer addSublayer:layer];
//
//    layer = [CALayer layer];
//    layer.backgroundColor = [UIColor blueColor].CGColor;
//    layer.frame = (CGRect) { 0, 0, 50, 50 };
//    [self.layer addSublayer:layer];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {

    [super layoutSublayersOfLayer:layer];
    
    NSLog(@"Object = %@ %@ %@ %f", layer, self.layer, NSStringFromCGRect(self.frame), self.f);
}

@end
