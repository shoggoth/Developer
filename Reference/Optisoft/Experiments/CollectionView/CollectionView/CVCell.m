//
//  CVCell.m
//  CollectionView
//
//  Created by Richard Henry on 08/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#import "CVCell.h"
#import "CVCellBackground.h"


@implementation CVCell

- (instancetype)initWithCoder:(NSCoder *)decoder {
    
    if (self = [super initWithCoder:decoder]) {
        
        // Change to our custom selected background view
        self.backgroundView = [[CVCellBackground alloc] initWithFrame:CGRectZero];
        self.selectedBackgroundView = [[CVSelectedCellBackground alloc] initWithFrame:CGRectZero];
    }
    
    return self;
}

@end
