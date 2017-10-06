//
//  IFMultiPinView.m
//  MappingTest
//
//  Created by Richard Henry on 18/09/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import "IFMultiPinView.h"
#import "IFPinView.h"

#import "MapLocation.h"
#import "Place.h"

#import <QuartzCore/QuartzCore.h>


@implementation IFMultiPinViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
        // Components
        self.mapPoints = [NSMutableArray array];
    }
    
    return self;
}

- (void)dealloc {
    
    self.mapPoints = nil;
}

- (void)viewDidLoad {
    
    // Appearance
    CALayer *pinLayer = self.view.layer;
    pinLayer.shadowOffset = CGSizeMake(0, 3);
    pinLayer.shadowRadius = 5.0;
    pinLayer.shadowColor = [UIColor blackColor].CGColor;
    pinLayer.shadowOpacity = 0.5;
    pinLayer.anchorPoint = CGPointMake(0.5, 1);
    
    bannerView.hidden = YES;
}

- (void)viewDidUnload {
    
    self.mapPoints = nil;
}

#pragma mark - Actions

//- (void)locationButtonClicked:(UIButton *)sender {
//    
//    [self.delegate clickedPinView:nil];
//}

- (IBAction)toggleBannerView:(id)sender {
    
    bannerView.hidden = !bannerView.hidden;
    
    //[self.delegate toggledBannerView:bannerView inPinView:nil];
}

@end


/*@implementation IFMultiPinView

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
    
    [self.children removeAllObjects];
    
    bannerView.hidden = YES;
    [self removeFromSuperview];
}

- (void)setMultipleLocations:(BOOL)multiLocation {
    
    // Set the correct button image
    [pinButton setImage:(multiLocation) ? [UIImage imageNamed:@"map_pin_multilocations.png"] : [UIImage imageNamed:@"map_pin_location.png"] forState:UIControlStateNormal];
    
    // Set the correct title
    bannerButton.enabled = !multiLocation;
    
    [bannerButton setTitle:[NSString stringWithFormat:@"%d locations", self.children.count + 1] forState:UIControlStateDisabled];
}

#pragma mark - Actions

- (void)locationButtonClicked:(UIButton *)sender {
    
    [self.delegate clickedPinView:nil];
}

- (IBAction)toggleBannerView:(id)sender {
    
    bannerView.hidden = !bannerView.hidden;
    
    [self.delegate toggledBannerView:bannerView inPinView:nil];
}

#pragma mark - Properties

- (void)setLocation:(MapLocation *)loc {
    
    _location = loc;
    [bannerButton setTitle:_location.place.name forState:UIControlStateNormal];
}

@end*/
