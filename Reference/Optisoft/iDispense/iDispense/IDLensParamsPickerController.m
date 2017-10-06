//
//  IDLensParamsPickerController.m
//  iDispense
//
//  Created by Richard Henry on 30/07/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

#import "IDLensParamsPickerController.h"
#import "PickerUtils.h"

static struct {

    NSInteger   zeroIndex;
    NSInteger   rowCount;
    float       resolution;

} pickerParams = { 60, 121, 0.25 };

@implementation IDLensParamsPickerController

#pragma mark Actions

- (IBAction)reset:(id)sender {

    for (int i = 0; i < 6; i += 3) {

        const BOOL animate = (sender != nil);

        // Reset the pickers.
        [self.picker selectRow:pickerParams.zeroIndex inComponent:i animated:animate];
        [self.picker selectRow:pickerParams.zeroIndex inComponent:i + 1 animated:animate];
        [self.picker selectRow:0  inComponent:i + 2 animated:animate];

        // Reset the values.
        values[i] = 0;
        values[i + 1] = 0;
        values[i + 2] = 0;
    }
}

#pragma mark Data Source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { return 6; }

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

    switch (component % 3) {

        case 1: return pickerParams.rowCount;   // Cylinder power
        case 2: return 181;                     // Cylinder angle
    }

    return pickerParams.rowCount;               // Sphere power
}

#pragma mark Delegate

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {

    const float pickerHalfWidth = pickerView.frame.size.width * 0.5;

    switch (component % 3) {

        case 1: return pickerHalfWidth * 0.3;   // Cylinder power
        case 2: return pickerHalfWidth * 0.3;   // Cylinder angle
    }

    return pickerHalfWidth * 0.3;               // Sphere power
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {

    switch (component % 3) {

        case 1: return dioptrePickerStringForValue((row - pickerParams.zeroIndex) * pickerParams.resolution);   // Cylinder power
        case 2: return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", (long)row]];   // Cylinder angle
    }

    // Sphere power
    return dioptrePickerStringForValueWithZeroString((row - pickerParams.zeroIndex) * pickerParams.resolution, @"Plano");
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

    if ((component % 3) == 2) values[component] = row; else values[component] = (row - pickerParams.zeroIndex) * pickerParams.resolution;
}

@end