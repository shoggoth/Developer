//
//  IFMultiPinView.h
//  MappingTest
//
//  Created by Richard Henry on 18/09/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//


@class MapLocation;
@class IFMultiPinView;

@protocol IFPinViewDelegate;

/*@interface IFMultiPinView : UIView {
    
    __weak IBOutlet         UIView   *bannerView;
    __weak IBOutlet         UIButton *bannerButton;
    __weak IBOutlet         UIButton *pinButton;
}

// Pin data
@property (strong, nonatomic) MapLocation *location;

// Grouping properties
@property (strong, nonatomic) NSMutableArray *children;

// Delegate
@property (weak, nonatomic) id <IFPinViewDelegate> delegate;

// Actions
- (IBAction)locationButtonClicked:(UIButton *)sender;
- (IBAction)toggleBannerView:(id)sender;

// Operations
- (void)recycle;
- (void)setMultipleLocations:(BOOL)multiLocation;

@end*/


@interface IFMultiPinViewController : UIViewController {
    
    __weak IBOutlet         UIView   *bannerView;
    __weak IBOutlet         UIView   *tableView;
    __weak IBOutlet         UIButton *pinButton;
}

// Grouping properties
@property (strong, nonatomic) NSMutableArray *mapPoints;

@end