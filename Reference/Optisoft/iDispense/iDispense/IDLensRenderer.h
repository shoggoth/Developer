//
//  IDLensRenderer.h
//  iDispense
//
//  Created by Richard Henry on 30/05/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDLens.h"
#import "DSRenderer.h"

@class IDTrackball;

//
//  interface IDLensRenderer
//
//  Uses OpenGL to render a mesh that represents a lens.
//

@interface IDLensRenderer : DSNodeRenderer

@property(nonatomic, strong) IBOutlet IDTrackball *trackball;

- (void)setupWithLeftLensParams:(IDLensParameters)leftPrescription rightLensParams:(IDLensParameters)rightPrescription;

@property(nonatomic) IDLensMaterial topMaterial;
@property(nonatomic) IDLensMaterial bottomMaterial;

@end
