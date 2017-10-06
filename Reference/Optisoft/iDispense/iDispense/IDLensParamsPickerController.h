//
//  IDLensParamsPickerController.h
//  iDispense
//
//  Created by Richard Henry on 30/07/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

@import Foundation;

//
//  interface IDLensParamsPickerController
//
//  Pick the parameters for the lens comparisons.
//

@interface IDLensParamsPickerController : NSObject <UIPickerViewDataSource, UIPickerViewDelegate> {

    @public float values[6];
}

@property(weak, nonatomic) IBOutlet UIPickerView *picker;

- (IBAction)reset:(id)sender;

@end
