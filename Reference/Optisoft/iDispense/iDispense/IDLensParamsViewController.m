//
//  IDLensParamsViewController.m
//  iDispense
//
//  Created by Richard Henry on 18/06/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDLensParamsViewController.h"
#import "IDLensCompareViewController.h"
#import "IDLensParamsPickerController.h"
#import "IDFrameShapeStore.h"
#import "IDLens.h"

#import "DSMaths.h"

#pragma mark - Custom View

@interface IDFrameShapeCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UIImageView *frameImageView;
//@property(nonatomic, weak) IBOutlet UILabel *frameDescription;

@end

@implementation IDFrameShapeCell

+ (NSString *)cellIdentifier { return @"FrameShapeCell"; }

@end

#pragma mark - View Controller

@interface IDLensParamsViewController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak) IBOutlet IDLensParamsPickerController *pickerController;

@end

@implementation IDLensParamsViewController {

    unsigned            selectedLensShape;
    BOOL                resetTransforms;
}

#pragma mark Lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];
    
    [self.pickerController reset:nil];
}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"pushLensMaterialVC"]) {

        IDLensCompareViewController *compareViewController = segue.destinationViewController;

        if (resetTransforms) { [compareViewController resetSavedTransforms]; resetTransforms = NO; }

        compareViewController.rightLensParameters = (IDLensParameters) {

            .shape = selectedLensShape,
            .blankDiameter = 6.5,
            .minimumThickness = 0.2,
            .eyePosition = rightEye,
            .prescription = (IDLensPrescription) {

                .sph  = self.pickerController->values[0],
                .cyl  = self.pickerController->values[1],
                .add  = 0,
                .axis = self.pickerController->values[2] * kDSDegreesToRadians
            },
        };

        compareViewController.leftLensParameters = (IDLensParameters) {

            .shape = selectedLensShape,
            .blankDiameter = 6.5,
            .minimumThickness = 0.2,
            .eyePosition = leftEye,
            .prescription = (IDLensPrescription) {

                .sph  = self.pickerController->values[3],
                .cyl  = self.pickerController->values[4],
                .add  = 0,
                .axis = self.pickerController->values[5] * kDSDegreesToRadians
            },
        };
    }
}

#pragma mark UITableViewDataSource conformance

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {


    IDFrameShapeCell *cell = [tableView dequeueReusableCellWithIdentifier:[IDFrameShapeCell cellIdentifier] forIndexPath:indexPath];

    cell.frameImageView.image = [[IDFrameShapeStore defaultFrameShapeStore] frameShapeThumbnailForFrameIndex:indexPath.row];
    //cell.frameDescription.text = [[IDFrameShapeStore defaultFrameShapeStore] frameShapeDescriptionForFrameIndex:indexPath.row];

    return cell;
}

#pragma mark UITableViewDelegate conformance

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    selectedLensShape = (unsigned)indexPath.row;
}

@end

