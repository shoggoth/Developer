//
//  IDLensCompareViewController.h
//  iDispense
//
//  Created by Richard Henry on 20/05/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "DSView.h"
#import "IDLensRenderer.h"
#import "IDMaterialSelectionView.h"
#import "IDLens.h"

//
//  interface IDLensCompareViewController
//
//  Lens comparison settings are managed by this view controller.
//

@interface IDLensCompareViewController : UIViewController <DSViewDelegate, UIGestureRecognizerDelegate, IDMaterialSelectDelegate>

@property(nonatomic) IDLensParameters leftLensParameters;
@property(nonatomic) IDLensParameters rightLensParameters;

- (void)resetSavedTransforms;

@end
