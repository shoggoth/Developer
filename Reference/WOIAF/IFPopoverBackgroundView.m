//
//  IFPopoverBackgroundView.m
//  WOIAF
//
//  Created by Richard Henry on 23/10/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import "IFPopoverBackgroundView.h"

#import <QuartzCore/QuartzCore.h>


static const CGFloat kIFPBVContentInset = 10.0;
static const CGFloat kIFPBVCapInset = 16.0;
static const CGFloat kIFPBVArrowBase = 23.0;
static const CGFloat kIFPBVArrowHeight = 23.0;

@implementation IFPopoverBackgroundView {
    
    UIImageView         *imageView;
    UIImageView         *arrowView;
}

+ (UIEdgeInsets)contentViewInsets { return UIEdgeInsetsMake(kIFPBVContentInset, kIFPBVContentInset, kIFPBVContentInset, kIFPBVContentInset); }

+ (CGFloat)arrowHeight { return kIFPBVArrowHeight; }

+ (CGFloat)arrowBase { return kIFPBVArrowBase; }

- (id)initWithFrame:(CGRect)frame {
    
    if ((self = [super initWithFrame:frame])) {
        
        imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"popover_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(kIFPBVCapInset, kIFPBVCapInset, kIFPBVCapInset, kIFPBVCapInset)]];
        arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popover_arrow.png"]];

        // Appearance
        self.backgroundColor = arrowView.backgroundColor = imageView.backgroundColor = [UIColor clearColor];
        
        CALayer *layer = imageView.layer;
        layer.shadowOffset = CGSizeMake(5, 1);
        layer.shadowRadius = 5.0;
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowOpacity = 1.0;
        
        layer = arrowView.layer;
        layer.shadowOffset = CGSizeMake(5, 1);
        layer.shadowRadius = 5.0;
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowOpacity = 1.0;
        
        [self addSubview:imageView];
        [self addSubview:arrowView];
    }
    
    return self;
}

@synthesize arrowDirection, arrowOffset;

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGFloat             x = 0, y = 0, w  = self.frame.size.width, h = self.frame.size.height;
    CGAffineTransform   arrowRotation = CGAffineTransformIdentity;
    
    // Calculate view parameters for rotation
    if (arrowDirection == UIPopoverArrowDirectionUp) {
        
        y += kIFPBVArrowHeight;
        h -= kIFPBVArrowHeight;
        
        CGFloat coordinate = (w * 0.5 + self.arrowOffset) - kIFPBVArrowBase * 0.5;
        arrowView.frame = CGRectMake(coordinate, 0, kIFPBVArrowBase, kIFPBVArrowHeight);
        
        arrowRotation = CGAffineTransformMakeRotation(M_PI);
    }
    
    else if (arrowDirection == UIPopoverArrowDirectionDown) {
        
        h -= kIFPBVArrowHeight;
        
        CGFloat coordinate = (w * 0.5 + self.arrowOffset) - kIFPBVArrowBase * 0.5;
        arrowView.frame = CGRectMake(coordinate, h, kIFPBVArrowBase, kIFPBVArrowHeight);
    }
    
    else if (arrowDirection == UIPopoverArrowDirectionLeft) {
        
        x += kIFPBVArrowBase;
        w -= kIFPBVArrowBase;
        
        CGFloat coordinate = (h * 0.5 + self.arrowOffset) - kIFPBVArrowHeight * 0.5;
        arrowView.frame = CGRectMake(0, coordinate, kIFPBVArrowBase, kIFPBVArrowHeight);
        
        arrowRotation = CGAffineTransformMakeRotation(M_PI_2);
    }
    
    else if (arrowDirection == UIPopoverArrowDirectionRight) {
        
        w -= kIFPBVArrowBase;
        
        CGFloat coordinate = (h * 0.5 + self.arrowOffset) - kIFPBVArrowHeight * 0.5;
        arrowView.frame = CGRectMake(w, coordinate, kIFPBVArrowBase, kIFPBVArrowHeight);
        
        arrowRotation = CGAffineTransformMakeRotation(-M_PI_2);
    }
    
    // Set view parameters
    imageView.frame = CGRectMake(x, y, w, h);
    arrowView.transform = arrowRotation;
}

@end
