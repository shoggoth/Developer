//
//  IFPinView.h
//  MappingTest
//
//  Created by Richard Henry on 18/09/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//


@class IFPinView;

@protocol IFPinViewDelegate <NSObject>

- (void)clickedPinView:(IFPinView *)pinView;
- (void)toggledBannerView:(UIView *)bannerView inPinView:(IFPinView *)pinView;

@end


@protocol IFPin;

@interface IFPinView : UIView {
    
    __weak IBOutlet         UIView *bannerView;
    __weak IBOutlet         UIButton *bannerButton;
    __weak IBOutlet         UIButton *pinButton;
}

// Pin data
@property (weak, nonatomic) id <IFPin> location;

// Delegate
@property (weak, nonatomic) id <IFPinViewDelegate> delegate;

// Actions
- (IBAction)locationButtonClicked:(UIButton *)sender;
- (IBAction)toggleBannerView:(id)sender;

// Operations
- (void)recycle;

- (void)setSingleLocation:(NSString *)locationName;
- (void)setMultiLocation:(unsigned)locationCount;

@end