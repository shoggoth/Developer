//
//  IDGestureTransformer.h
//  iDispense
//
//  Created by Richard Henry on 28/05/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "DSTransform.h"


@interface IDGestureTransformer : NSObject

@property(nonatomic) BOOL recognise;
@property(nonatomic, strong) DS3DTransform *transform;

@end
