//
//  IDLensMesh.h
//  iDispense
//
//  Created by Richard Henry on 15/04/2014.
//  Copyright (c) 2014 Optisoft. All rights reserved.
//

#import "DSTriMesh.h"

#import "IDLens.h"

//
//  interface IDLensMesh
//
//  Generates a triangle mesh that represents a lens of a certain thickness specified by the parameters given.
//

@interface IDLensMesh : DSIndexedTriMesh

- (void)makeFrontMeshWithParameters:(IDLensParameters)parameters;
- (void)makeSideMeshWithParameters:(IDLensParameters)parameters;
- (void)makeBackMeshWithParameters:(IDLensParameters)parameters;

@end

// Temp

@interface IDDemoLensMesh : IDLensMesh

@end