//
//  DSHorizontalPickerView.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//


@class DSHorizontalPickerView;

@protocol DSHorizontalPickerViewDelegate <NSObject>

@required
- (NSUInteger)numberOfItemsInPickerView:(DSHorizontalPickerView *)pickerView;
- (NSString *)pickerView:(DSHorizontalPickerView *)pickerView titleForItem:(NSInteger)item;

@optional
- (void)pickerView:(DSHorizontalPickerView *)pickerView didSelectItem:(NSInteger)item;

@end

@interface DSHorizontalPickerView : UIView

@property(nonatomic, weak) IBOutlet id <DSHorizontalPickerViewDelegate> delegate;

@property(nonatomic, strong) UIFont *font;
@property(nonatomic, strong) UIColor *textColour;
@property(nonatomic, strong) UIColor *highlightedTextColour;
@property(nonatomic, assign) CGFloat interitemSpacing;

@property(nonatomic, assign, readonly) NSUInteger selectedItem;

- (void)reloadData;
- (void)scrollToItem:(NSUInteger)item animated:(BOOL)animated;
- (void)selectItem:(NSUInteger)item animated:(BOOL)animated;

@end
