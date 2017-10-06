//
//  IFPinView.m
//  MappingTest
//
//  Created by Richard Henry on 18/09/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import "IFPinView.h"

#import "MapLocation.h"
#import "Place.h"

#import <QuartzCore/QuartzCore.h>


@implementation IFPinView

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if ((self = [super initWithCoder:aDecoder])) {
        
        // Appearance
        CALayer *pinLayer = self.layer;
        pinLayer.shadowOffset = CGSizeMake(0, 3);
        pinLayer.shadowRadius = 5.0;
        pinLayer.shadowColor = [UIColor blackColor].CGColor;
        pinLayer.shadowOpacity = 0.5;
        pinLayer.anchorPoint = CGPointMake(0.5, 1);
    }
    
    return self;
}

- (void)dealloc {
    
    self.location = nil;
}

#pragma mark - Overrides

- (void)awakeFromNib {
    
    bannerView.hidden = YES;
}

-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    // Ignore hits in this view but not in the subviews…
    id hitView = [super hitTest:point withEvent:event];
    
    return (hitView == self) ? nil : hitView;
}

#pragma mark - Interface

- (void)recycle {
    
    bannerView.hidden = YES;
    [self removeFromSuperview];
}

- (void)setSingleLocation:(NSString *)locationName {
    
    // Set the correct button image
    [pinButton setImage:[UIImage imageNamed:@"map_pin_location.png"] forState:UIControlStateNormal];
    
    // Set the correct title
    [bannerButton setTitle:locationName forState:UIControlStateNormal];
}

- (void)setMultiLocation:(unsigned)locationCount {
    
    // Set the correct button image
    [pinButton setImage:[UIImage imageNamed:@"map_pin_multilocations.png"] forState:UIControlStateNormal];
    //[bannerButton setTitle:(multiLocation) ? [NSString stringWithFormat:@"%d locations", self.children.count + 1] : self.location.place.name forState:UIControlStateNormal];
    
    // Set the correct title
    [bannerButton setTitle:[NSString stringWithFormat:@"%d locations", locationCount] forState:UIControlStateNormal];
    
}

#pragma mark - Actions

- (void)locationButtonClicked:(UIButton *)sender {
    
    [self.delegate clickedPinView:self];
}

- (IBAction)toggleBannerView:(id)sender {
    
    bannerView.hidden = !bannerView.hidden;
    
    [self.delegate toggledBannerView:bannerView inPinView:self];
}

#pragma mark - Properties

- (void)setLocation:(MapLocation *)loc {
    
    _location = loc;
    //[bannerButton setTitle:_location.place.name forState:UIControlStateNormal];
}

@end
