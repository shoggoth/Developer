//
//  IFNoHitView.m
//  MappingTest
//
//  Created by Richard Henry on 18/09/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import "IFNoHitView.h"


@implementation IFNoHitView

#pragma mark - Overrides

-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    // Ignore hits in this view but not in the subviews…
    id hitView = [super hitTest:point withEvent:event];
    
    return (hitView == self) ? nil : hitView;
}

@end
