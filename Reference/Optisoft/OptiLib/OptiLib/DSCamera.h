//
//  DSCamera.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSRenderNode.h"


//
//  interface DSCameraNode
//
//  Scene graph node describing a camera projection
//  Orthographic and perspective modes are available.
//

@interface DSCameraNode : DSBinaryRenderNode

@property(nonatomic) float aspect;

@property(nonatomic) float near;
@property(nonatomic) float far;

@property(nonatomic, strong) DSTransform *transform;

@end


//
//  interface DSPerspectiveCameraNode
//
//  Scene graph node describing a camera projection
//  Orthographic and perspective modes are available.
//

@interface DSPerspectiveCameraNode : DSCameraNode

@property(nonatomic) float fov;

@end


//
//  interface DSOrthographicCameraNode
//
//  Scene graph node describing a camera projection
//  Orthographic and perspective modes are available.
//

@interface DSOrthographicCameraNode : DSCameraNode

@property(nonatomic) CGRect dimensions;

@end
