//
//  IDLensDetailViewController.h
//  iDispense
//
//  Created by Richard Henry on 24/06/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "DSView.h"
#import "IDLensParameters.h"


@interface IDLensDetailViewController : UIViewController<DSViewDelegate>

@property(nonatomic) IDLensParameters *lensParameters;

@end
