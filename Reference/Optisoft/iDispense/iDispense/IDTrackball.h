//
//  IDTrackball.h
//  iDispense
//
//  Created by Richard Henry on 19/08/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "DSTrackball.h"
#import "DSTransform.h"

//
//  interface IDTrackball
//
//  Simulate a trackball for rotate and zoom of the lens graphic.
//

@interface IDTrackball : DSTrackball

@property(nonatomic, strong) DS3DTransform *leftTransform;
@property(nonatomic, strong) DS3DTransform *rightTransform;

@property(nonatomic) NSInteger viewToTrack;

@end
