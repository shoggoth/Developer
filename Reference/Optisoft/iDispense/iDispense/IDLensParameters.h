//
//  IDLensParameters.h
//  iDispense
//
//  Created by Richard Henry on 19/06/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

typedef enum { leftEye, rightEye } IDEyePosition;

typedef struct {

    float       sphere[2];
    float       cyl[2];
    float       axis[2];
    float       add[2];

} IDLensPrescription;

typedef struct {

    unsigned int            shape;
    IDEyePosition           eyePosition;
    IDLensPrescription      prescription;

} IDLensDescription;

@interface IDLensParameters : NSObject

- (instancetype)initWithShape:(unsigned)shape prescription:(IDLensPrescription)prescription;

@property(nonatomic) unsigned shape;
@property(nonatomic) IDLensPrescription prescription;

@end
