//
//  IDRxPicker.m
//  iDispense
//
//  Created by Richard Henry on 26/11/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDRxPicker.h"

enum { kSph, kCyl, kAxis, kAdd, kDPD, kNPD };

static const float dioptreIncrement = 0.5;
static const float dioptreLimit = 10;

static float indexFromDioptreValue(const float dioptre) { return (dioptreLimit + dioptre) / dioptreIncrement; }
static float dioptreValueFromindex(const float index) { return index * dioptreIncrement - dioptreLimit; }

static const NSInteger pdMinimum = 40;
static const NSInteger pdMaximum = 70;

@interface IDRxPicker () <UIPickerViewDataSource, UIPickerViewDelegate>

@end

@implementation IDRxPicker

#pragma mark Properties

- (void)setLeftRx:(IDLensPrescription)rx {

    _leftRx = rx;

    [self animatePicker:_leftPicker toRx:rx animated:NO];
}

- (void)setRightRx:(IDLensPrescription)rx {

    _rightRx = rx;

    [self animatePicker:_rightPicker toRx:rx animated:NO];
}

- (void)animatePicker:(UIPickerView *)picker toRx:(IDLensPrescription)rx animated:(BOOL)animated {

    [picker selectRow:indexFromDioptreValue(rx.sph) inComponent:kSph animated:animated];
    [picker selectRow:indexFromDioptreValue(rx.cyl) inComponent:kCyl animated:animated];
    [picker selectRow:indexFromDioptreValue(rx.add) inComponent:kAdd animated:animated];

    [picker selectRow:(NSInteger)rx.axis % 180 inComponent:kAxis animated:animated];

    [picker selectRow:(NSInteger)rx.dpd - pdMinimum inComponent:kDPD animated:animated];
    [picker selectRow:(NSInteger)rx.npd - pdMinimum inComponent:kNPD animated:animated];
}

#pragma mark UIPickerViewDataSource conformance

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {

    return 6;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

    switch (component) {

        case kSph:
        case kCyl:
        case kAdd:
            return ((dioptreLimit * 2) / dioptreIncrement) + 1;

        case kAxis:
            return 180;
            
        case kDPD:
        case kNPD:
            return (pdMaximum - pdMinimum) + 1;
    }

    // The case statement above should be exhaustive, print a warning if it isn't.
    NSLog(@"Warning: Invalid row enumeration request in component %ld of picker %@", (long)component, pickerView);

    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {

    CGFloat pickerWidth = pickerView.frame.size.width;

    switch (component) {

        case kSph:
        case kCyl:
        case kAdd:
            return pickerWidth / 6;

        case kAxis:
            return pickerWidth / 6;

        case kDPD:
        case kNPD:
            return pickerWidth / 6;
    }

    // The case statement above should be exhaustive, print a warning if it isn't.
    NSLog(@"Warning: Invalid row width request in component %ld of picker %@", (long)component, pickerView);
    
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {

    return pickerView.frame.size.height * 0.2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {

    switch (component) {

        case kSph:
        case kCyl:
        case kAdd:
            return [NSString stringWithFormat:@"%.2f", -dioptreLimit + row * dioptreIncrement];

        case kAxis:
            return [NSString stringWithFormat:@"%ld", (long)row];

        case kDPD:
        case kNPD:
            return [NSString stringWithFormat:@"%ld", (long)row + pdMinimum];
    }

    // The case statement above should be exhaustive, print a warning if it isn't.
    NSLog(@"Warning: Invalid row (%ld) title request in component %ld of picker %@", (long)row, (long)component, pickerView);
    
    return @"?????";
}

@end
