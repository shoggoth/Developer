//
//  IDMaterialSelectionView.m
//  iDispense
//
//  Created by Richard Henry on 04/07/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDMaterialSelectionView.h"
#import "IDLensMaterialStore.h"

#import "DSHorizontalPickerView.h"


const static int expandedHeight = 86;
const static int unexpandedHeight = 44;
const static int collapsedHeight = 0;


@implementation IDMaterialSelectionView {

    int         heightBeforeCollapsing;
    float       alphaBeforeCollapsing;

    enum { upper = 1, lower };
}

- (void)dealloc {

    // Expanded preference
    [[NSUserDefaults standardUserDefaults] setObject:@(self.expanded) forKey:(self.tag == upper) ? @"lens_comparison_top_bar_expanded" : @"lens_comparison_bottom_bar_expanded"];

    // Selection preferences
    [[NSUserDefaults standardUserDefaults] setObject:@(self.filterSegmentedControl.selectedSegmentIndex) forKey:[NSString stringWithFormat:@"material_selection_filter_%ld", (long)self.tag]];
    [[NSUserDefaults standardUserDefaults] setObject:@(_filterIndex) forKey:[NSString stringWithFormat:@"material_selection_type_index_%ld", (long)self.tag]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.horizontalPickerView.selectedItem) forKey:[NSString stringWithFormat:@"material_selection_index_%ld", (long)self.tag]];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Setup


- (void)setup {

    // Expanded preference
    const BOOL expanded = [[[NSUserDefaults standardUserDefaults] objectForKey:(self.tag == upper) ? @"lens_comparison_top_bar_expanded" : @"lens_comparison_bottom_bar_expanded"] boolValue];
    self.heightConstraint.constant = (expanded) ? expandedHeight : unexpandedHeight;

    // Selection preferences
    self.filterSegmentedControl.selectedSegmentIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"material_selection_filter_%ld", (long)self.tag]] integerValue];

    _filterIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"material_selection_type_index_%ld", (long)self.tag]] integerValue];
    [self.horizontalPickerView reloadData];

    [self.horizontalPickerView selectItem:[[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"material_selection_index_%ld", (long)self.tag]] integerValue] animated:NO];
    //[self pickerView:self.horizontalPickerView didSelectItem:self.horizontalPickerView.selectedItem];

    // Set disclosure button title
    [self.filterDiscloseButton setTitle:[self.filterSegmentedControl titleForSegmentAtIndex:self.filterSegmentedControl.selectedSegmentIndex] forState:UIControlStateNormal];

    // Set horizontal picker look
    self.horizontalPickerView.highlightedTextColour = self.tintColor;
}

#pragma mark Actions

- (IBAction)materialFilterChanged:(UISegmentedControl *)segControl {

    _filterIndex = segControl.selectedSegmentIndex;

    // Set disclosure button title
    [self.filterDiscloseButton setTitle:[self.filterSegmentedControl titleForSegmentAtIndex:self.filterSegmentedControl.selectedSegmentIndex] forState:UIControlStateNormal];

    [self.horizontalPickerView reloadData];
    [self.horizontalPickerView selectItem:0 animated:NO];
    [self pickerView:self.horizontalPickerView didSelectItem:0];
}


- (IBAction)toggleExpand:(UIButton *)sender {

    self.expanded = !self.expanded;
}

#pragma mark DSHorizontalPickerViewDelegate conformance

- (NSUInteger)numberOfItemsInPickerView:(DSHorizontalPickerView *)pickerView {

	return [[IDLensMaterialStore defaultLensMaterialStore] materialCountForFilterIndex:self.filterIndex];
}

- (NSString *)pickerView:(DSHorizontalPickerView *)pickerView titleForItem:(NSInteger)item {

	return [[IDLensMaterialStore defaultLensMaterialStore] materialNameForFilterIndex:self.filterIndex index:item];
}

- (void)pickerView:(DSHorizontalPickerView *)pickerView didSelectItem:(NSInteger)item {

    [self.delegate materialPicker:self.horizontalPickerView didPickMaterialWithFilterIndex:self.filterIndex index:item];
}

#pragma mark Properties

- (BOOL)expanded {

    return self.heightConstraint.constant == expandedHeight;
}

- (void)setExpanded:(BOOL)expanding {

    [UIView animateWithDuration:0.23
                          delay:(expanding) ? 0 : 0.1
                        options:(expanding) ? UIViewAnimationOptionCurveEaseIn : UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.heightConstraint.constant = (expanding) ? expandedHeight : unexpandedHeight;
                         [self.superview layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {}];

    [UIView animateWithDuration:0.23
                          delay:(expanding) ? 0.1 : 0
                        options:(expanding) ? UIViewAnimationOptionCurveEaseIn : UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.filterSegmentedControl.alpha = (expanding) ? 1 : 0;
                     }
                     completion:^(BOOL finished) {}];
}

- (BOOL)collapsed {

    return self.heightConstraint.constant == collapsedHeight;
}

- (void)setCollapsed:(BOOL)collapsing {

    [self setCollapsedState:collapsing animated:YES];
}

#pragma mark Collapsing

- (void)setCollapsedState:(BOOL)collapsing animated:(BOOL)animated {

    // Save the height of the constraint before the hide so that we can restore it to the correct height
    if (collapsing) {

        heightBeforeCollapsing = self.heightConstraint.constant;
        alphaBeforeCollapsing = self.filterSegmentedControl.alpha;
    }

    const BOOL expanding = !collapsing;

    [UIView animateWithDuration:0.23
                          delay:0
                        options:(expanding) ? UIViewAnimationOptionCurveEaseIn : UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.heightConstraint.constant = (expanding) ? heightBeforeCollapsing : collapsedHeight;
                         if (animated) [self.superview layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {}];

    [UIView animateWithDuration:0.23
                          delay:0
                        options:(expanding) ? UIViewAnimationOptionCurveEaseIn : UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.filterSegmentedControl.alpha = (expanding) ? 1 : 0;
                     }
                     completion:^(BOOL finished) {}];
}

@end
