//
//  MVRenderer.h
//  MeshViewer
//
//  Created by Richard Henry on 23/07/2014.
//  Copyright (c) 2014 Dogstar Industries. All rights reserved.
//

#import "MVPrefsViewController.h"

#import "DSRenderer.h"
#import "DSEngine.h"

@class DSTrackball;
@protocol DSVertexSource;

@interface MVRenderer : DSNodeRenderer <MVPrefsDelegate, DSEngineNode>

@property(nonatomic, strong) IBOutlet id <DSVertexSource> mesh;
@property(nonatomic, strong) IBOutlet DSTrackball *trackball;

- (void)setup;

@end
