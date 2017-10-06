//
//  DSGridMesh.h
//  OptiLib
//
//  Created by Richard Henry on 16/12/2015.
//  Copyright © 2015 Optisoft. All rights reserved.
//

#import "DSTriMesh.h"


//
//  interface DSGridMesh
//
//  Standard triangle mesh with distinct vertices for each of the triangles in the mesh.
//

@interface DSGridMesh : DSIndexedTriMesh

- (instancetype)initWithGridDensity:(unsigned)gridDensity vertexSize:(unsigned)vs;

@end
