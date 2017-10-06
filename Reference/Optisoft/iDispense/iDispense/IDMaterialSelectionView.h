//
//  IDMaterialSelectionView.h
//  iDispense
//
//  Created by Richard Henry on 04/07/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "DSHorizontalPickerView.h"

@protocol IDMaterialSelectDelegate <NSObject>

- (void)materialPicker:(DSHorizontalPickerView *)picker didPickMaterialWithFilterIndex:(NSInteger)filterIndex index:(NSInteger)index;

@end

//
//  interface IDMaterialSelectionView
//
//  In the lens comparison, this control provides a horizontal picker that is used to select the material of the lens.
//

@interface IDMaterialSelectionView : UIView <DSHorizontalPickerViewDelegate>

// Properties
@property(nonatomic) BOOL collapsed;
@property(nonatomic) BOOL expanded;

@property(nonatomic, readonly) NSInteger filterIndex;

// Delegate
@property(nonatomic, weak) id <IDMaterialSelectDelegate> delegate;

// Outlets
@property(nonatomic, weak) IBOutlet UIButton *filterDiscloseButton;
@property(nonatomic, weak) IBOutlet UISegmentedControl *filterSegmentedControl;
@property(nonatomic, weak) IBOutlet DSHorizontalPickerView *horizontalPickerView;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *heightConstraint;

- (void)setup;
- (void)setCollapsedState:(BOOL)collapsing animated:(BOOL)animated;

@end
