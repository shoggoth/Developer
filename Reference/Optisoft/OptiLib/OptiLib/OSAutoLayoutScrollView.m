//
//  OSAutoLayoutScrollView.m
//  OptiLib
//
//  Created by Richard Henry on 07/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#import "OSAutoLayoutScrollView.h"

@implementation OSAutoLayoutScrollView {
    
    UIView          *customContentView;

}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        // Create custom content view using auto-sizing
        customContentView = [[UIView alloc] initWithFrame:(CGRect) { .size = frame.size }];
        
        // Add it to the view hierarchy (being careful of the override)
        [super addSubview:customContentView];
    }
    
    return self;
}

#pragma mark Overrides

// Override so that new views are added to the content view.
- (void)addSubview:(UIView *)view {
    
    [customContentView addSubview:view];
}

// When the content size changes, adjust the custom content view as well
- (void)setContentSize:(CGSize)contentSize {
    
    customContentView.frame = (CGRect) { .size = contentSize };
}

@end
