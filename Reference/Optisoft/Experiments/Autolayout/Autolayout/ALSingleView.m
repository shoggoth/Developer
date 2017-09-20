//
//  ALSingleView.m
//  Autolayout
//
//  Created by Richard Henry on 01/11/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import "ALSingleView.h"


@interface ALSingleView ()

@property (weak, nonatomic) IBOutlet UIButton *embiggenButton;

@end


@implementation ALSingleView

- (id)initWithFrame:(CGRect)frame {
    
    if ((self = [super initWithFrame:frame])) {
        
        // Initialization code
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super initWithCoder:decoder])) {
        
        // Initialization code
        [self setup];
    }
    
    return self;
}

- (void)setup {
    
    const CGFloat shadowFactor = 5;
    
    // Appearance
    CALayer *layer = self.layer;
    layer.shadowOffset = (const CGSize){ shadowFactor, shadowFactor };
    layer.shadowRadius = shadowFactor;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.5;
    //layer.anchorPoint = CGPointMake(0.5, 1);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
