//
//  IDDioptreValues.m
//  iDispense
//
//  Created by Richard Henry on 30/04/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDDioptreValues.h"


@interface IDDioptreValues ()

@property(nonatomic) NSNumber *leftEyeDioptreValue;
@property(nonatomic) NSNumber *rightEyeDioptreValue;

@end

@implementation IDDioptreValues {

    NSArray     *dioptreValues;
}

- (instancetype)init {

    if ((self = [super init])) {

        // Initialisation code here
        dioptreValues = @[ @4, @3, @2, @1, @0, @-1, @-2, @-3, @-4 ];
    }

    return self;
}

#pragma mark UIPickerViewDataSource conformance

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {

    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

    return [dioptreValues count];
}

#pragma mark UIPickerViewDelegate conformance

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {

    return [NSString stringWithFormat:@"%@ Dioptres", dioptreValues[row]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

    if (!component)
        self.leftEyeDioptreValue = dioptreValues[row];
}

@end
