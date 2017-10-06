//
//  DSFrustum.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

@import GLKit;


//
//  struct DSFrustum
//
//  Describes a 3D frustum by way of its plane normals and d values.
//

typedef struct {
    
    GLKVector3      normals[6];         // Frustum plane normals
    float           d[6];               // Frustum distances
    
} DSFrustum;


//
//  function DSSphereInCullingFrustum
//
//  Returns a boolean value indicating whether the supplied sphere (specified by
//  the vector 'pos' and the float 'radius') intersects the supplied frustum.
//

static inline BOOL DSSphereInCullingFrustum(const DSFrustum frustum, const GLKVector3 pos, const float radius) {

    const float        radiusCheck = -radius;

    // Check that the radius is valid (invalid if negative)
    if (radiusCheck > 0) return NO;

    // Check sphere against each of the culling planes
    for (int i = 0; i < 6; i++) {
        
        const float dotNormal = GLKVector3DotProduct(pos, frustum.normals[i]);
        
        // Find the distance to the plane
        const float    d = dotNormal + frustum.d[i];
        
        if (d < radiusCheck) return NO; // Sphere is outside the current plane
    }
    
    return YES; // Inside all 6 culling planes... pass the test
}


//
//  function DSFrustumMake
//
//  Given a modelView and projection matrix, this function will return
//  a DSFrustum struct defining the viewing frustum for the supplied matrices. The frustum
//  can then be used to perform culling tests on various types of shapes.
//  
//  This function is usually called from the drawing context as needed so that cull tests can
//  be performed on objects as required. DSCamera objects should generally regenerate the draw
//  context's frustum.
//

static inline DSFrustum DSFrustumMake(GLKMatrix4 modelView, GLKMatrix4 projection) {
    
    DSFrustum           frustum;

    // Calculate the clipping matrix (projection * modelView)
    GLKMatrix4 clipping = GLKMatrix4Multiply(projection, modelView);

    // Calculate the right side of the frustum.
    frustum.normals[0].x = clipping.m03 - clipping.m00;
    frustum.normals[0].y = clipping.m13 - clipping.m10;
    frustum.normals[0].z = clipping.m23 - clipping.m20;
    frustum.d[0] = clipping.m33 - clipping.m30;
    
    // Calculate the left side of the frustum.
    frustum.normals[1].x = clipping.m03 + clipping.m00;
    frustum.normals[1].y = clipping.m13 + clipping.m10;
    frustum.normals[1].z = clipping.m23 + clipping.m20;
    frustum.d[1] = clipping.m33 + clipping.m30;
    
    // Calculate the top side of the frustum.
    frustum.normals[2].x = clipping.m03 - clipping.m01;
    frustum.normals[2].y = clipping.m13 - clipping.m11;
    frustum.normals[2].z = clipping.m23 - clipping.m21;
    frustum.d[2] = clipping.m33 - clipping.m31;
    
    // Calculate the bottom side of the frustum.
    frustum.normals[3].x = clipping.m03 + clipping.m01;
    frustum.normals[3].y = clipping.m13 + clipping.m11;
    frustum.normals[3].z = clipping.m23 + clipping.m21;
    frustum.d[3] = clipping.m33 + clipping.m31;
    
    // Calculate the far side of the frustum.
    frustum.normals[4].x = clipping.m03 - clipping.m02;
    frustum.normals[4].y = clipping.m13 - clipping.m12;
    frustum.normals[4].z = clipping.m23 - clipping.m22;
    frustum.d[4] = clipping.m33 - clipping.m32;
    
    // Calculate the near side of the frustum.
    frustum.normals[5].x = clipping.m03 + clipping.m02;
    frustum.normals[5].y = clipping.m13 + clipping.m12;
    frustum.normals[5].z = clipping.m23 + clipping.m22;
    frustum.d[5] = clipping.m33 + clipping.m32;
    
    // Normalise the frustum
    for (int i = 0; i < 6; i++) {
        
        float    magnitude = 1.0f / sqrtf(frustum.normals[i].x * frustum.normals[i].x + frustum.normals[i].y * frustum.normals[i].y + frustum.normals[i].z * frustum.normals[i].z);
        
        frustum.normals[i].x *= magnitude;
        frustum.normals[i].y *= magnitude;
        frustum.normals[i].z *= magnitude;
        
        frustum.d[i] *= magnitude;
    }
    
    return frustum;
}

