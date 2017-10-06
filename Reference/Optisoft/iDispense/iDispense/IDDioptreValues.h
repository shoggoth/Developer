//
//  IDDioptreValues.h
//  iDispense
//
//  Created by Richard Henry on 30/04/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//


@interface IDDioptreValues : NSObject <UIPickerViewDataSource, UIPickerViewDelegate>

@property(nonatomic, readonly) NSNumber *leftEyeDioptreValue;
@property(nonatomic, readonly) NSNumber *rightEyeDioptreValue;

@end
