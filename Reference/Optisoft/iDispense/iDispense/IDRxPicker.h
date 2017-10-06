//
//  IDRxPicker.h
//  iDispense
//
//  Created by Richard Henry on 26/11/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDLens.h"

@interface IDRxPicker : NSObject

// Prescription
@property(nonatomic, assign) IDLensPrescription leftRx;
@property(nonatomic, assign) IDLensPrescription rightRx;

// UI
@property(nonatomic, weak) IBOutlet UIPickerView *leftPicker;
@property(nonatomic, weak) IBOutlet UIPickerView *rightPicker;

@end
