//
//  IDRxView.m
//  iDispense
//
//  Created by Richard Henry on 05/02/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

#import "IDRxView.h"

@implementation IDRxView {

    CALayer             *subLayer;
    CATextLayer         *textLayer;

    UIFont              *normalFont, *boldFont;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {

    if ((self = [super initWithCoder:aDecoder])) {

        NSLog(@"IWC lay = %@", self.layer);

        normalFont = [UIFont systemFontOfSize:17.0];
        boldFont = [UIFont boldSystemFontOfSize:17.0];

        subLayer = [CALayer layer];
        subLayer.backgroundColor = [UIColor greenColor].CGColor;

        // Annotation layer text properties.
        textLayer = [CATextLayer layer];

        textLayer.foregroundColor = [UIColor blackColor].CGColor;

        // Annotiation layer content.
        textLayer.string = [[NSAttributedString alloc] initWithString:@"Flipping heck\nFooling Noone" attributes:@{ NSFontAttributeName : normalFont }];

        [self.layer addSublayer:subLayer];
        [subLayer addSublayer:textLayer];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {

    if ((self = [super initWithFrame:frame])) {

        NSLog(@"IWF lay = %@", self.layer);
    }

    return self;
}

- (void)layoutSubviews {

    NSLog(@"Lay out SV %@", NSStringFromCGRect(self.frame));

    subLayer.frame = CGRectInset(self.bounds, 10, 10);
    textLayer.frame = CGRectInset(self.bounds, 10, 10);
}

@end
