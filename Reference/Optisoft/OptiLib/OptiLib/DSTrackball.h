//
//  DSTrackball.h
//  MeshViewer
//
//  Created by Richard Henry on 23/07/2014.
//  Copyright (c) 2014 Dogstar Industries. All rights reserved.
//

@import Foundation;
#import "DSFilter.h"

@class DS3DTransform;

@interface DSTrackball : NSObject <UIGestureRecognizerDelegate>

// Resolved transform
@property(nonatomic, strong) DS3DTransform *transform;

// Settings
@property(nonatomic) BOOL recognise;

@property(nonatomic) float panSensitivity;
@property(nonatomic) float pinchSensitivity;
@property(nonatomic) float rotateSensitivity;

@property(nonatomic) CGPoint pinchLimits;

@property(nonatomic, strong) id <DSFilter>filter;

@end
