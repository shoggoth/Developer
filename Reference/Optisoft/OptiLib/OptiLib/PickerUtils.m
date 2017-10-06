//
//  PickerUtils.m
//  OptiLib
//
//  Created by Richard Henry on 31/07/2015.
//  Copyright (c) 2015 Optisoft. All rights reserved.
//

#import "PickerUtils.h"

NSAttributedString *dioptrePickerStringForValue(double dioptre) {

    return dioptrePickerStringForValueWithZeroString(dioptre, @"0");
}

NSAttributedString *dioptrePickerStringForValueWithZeroString(double dioptre, NSString *zeroString) {

    static dispatch_once_t      onceToken;
    static NSNumberFormatter    *formatter;
    static NSParagraphStyle     *paragraphStyle;
    static UIColor              *plusColour, *negColour, *zeroColour;

    dispatch_once(&onceToken, ^{

        // Create a number formatter.
        formatter = [NSNumberFormatter new];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        formatter.positivePrefix = @"+";
        formatter.minimumFractionDigits = 2;

        // Create the options for the formatted string.
        NSMutableParagraphStyle *ps = [NSMutableParagraphStyle new];
        ps.alignment = NSTextAlignmentCenter;
        paragraphStyle = ps;

        // Create the colours
        plusColour = [UIColor blueColor];
        negColour  = [UIColor redColor];
        zeroColour = [UIColor blackColor];
    });

    formatter.zeroSymbol = zeroString;

    UIColor *colour = (dioptre < 0) ? negColour : (dioptre > 0) ? plusColour : zeroColour;

    NSDictionary *formatDictionary = @{ NSForegroundColorAttributeName : colour };

    NSString *string = [formatter stringFromNumber:[NSNumber numberWithDouble: dioptre]];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString: string attributes:formatDictionary];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range: NSMakeRange(0, string.length)];
    
    return attributedString;
}
