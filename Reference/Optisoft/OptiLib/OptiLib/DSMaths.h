//
//  DSMaths.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

@import GLKit;

extern const GLKVector3 kDSXAxis;
extern const GLKVector3 kDSYAxis;
extern const GLKVector3 kDSZAxis;

extern const double kDSDegreesToRadians;
extern const double kDSRadiansToDegrees;

#pragma mark Scalar

//
//  function DSClampFloat
//
//  Returns the translation specified in the supplied matrix.
//

static inline float DSClampFloat(const float val, const float min, const float max) {

    assert(min <= max);

    if (val < min) return min;
    else if (val > max) return max;
    else return val;
}

//
//  function DSClampFloat
//
//  Returns the translation specified in the supplied matrix.
//

static inline float DSInterpolateFloat(const float alpha, const float low, const float high) {

    assert(low <= high);

    return low + (high - low) * alpha;
}

#pragma mark Matrices

//
//  function DSMatrix4GetTranslate
//
//  Returns the translation specified in the supplied matrix.
//

static inline GLKVector3 DSMatrix4GetTranslate(GLKMatrix4 matrix) {

    GLKVector4 transWithW = GLKMatrix4GetColumn(matrix, 3);

    return (GLKVector3) { transWithW.x, transWithW.y, transWithW.z };
}

#pragma mark - Coordinate systems

//
//  function DSPolarToRectangular
//
//  Returns the 2D rectangular coordinates for the supplied polar coordinates.
//
//  The x, y and z components of the vector supplied represent the following:
//
//  polar.x = r (radius)
//  polar.y = theta (ccw rotation around z axis with 0 radians at x axis) typical range 0 - 2pi radians
//

static inline GLKVector2 DSPolarToRectangular(GLKVector2 polar) {

    GLKVector2 rectangular;

    rectangular.x = polar.x * cosf(polar.y);
    rectangular.y = polar.x * sinf(polar.y);

    return rectangular;
}

//
//  function DSRectangularToPolar
//
//  Returns the polar coordinates for the supplied 2D rectangular coordinates.
//

static inline GLKVector2 DSRectangularToPolar(GLKVector2 rectangular) {

    GLKVector2 polar;

    // Calculate r
    polar.x = GLKVector2Length(rectangular);

    // Calculate theta (arctan(y / x))
    polar.y = atan2f(rectangular.y, rectangular.x);

    return polar;
}

//
//  function DSCylindricalToRectangular
//
//  Returns the 3D rectangular coordinates for the supplied cylindrical polar coordinates.
//
//  The x, y and z components of the vector supplied represent the following:
//
//  cylindrical.x = r (radius)
//  cylindrical.y = theta (ccw rotation around z axis with 0 radians at x axis) typical range 0 - 2pi radians
//  cylindrical.z = h (elevation from x-y plane)
//

static inline GLKVector3 DSCylindricalToRectangular(GLKVector3 cylindrical) {

    GLKVector3 rectangular;

    const float r = cylindrical.x;

    rectangular.x = r * cosf(cylindrical.y);
    rectangular.y = r * sinf(cylindrical.y);
    rectangular.z = cylindrical.z;

    return rectangular;
}

//
//  function DSRectangularToCylindrical
//
//  Returns the cylindrical polar coordinates for the supplied 3D rectangular coordinates.
//

static inline GLKVector3 DSRectangularToCylindrical(GLKVector3 rectangular) {

    GLKVector3 cylindrical;

    // Calculate r
    cylindrical.x = GLKVector2Length((GLKVector2) { rectangular.x, rectangular.y });

    // Calculate theta (arctan(y / x))
    cylindrical.y = atan2f(rectangular.y, rectangular.x);

    // Calculate h
    cylindrical.z = rectangular.z;

    return cylindrical;
}

//
//  function DSSphericalToRectangular
//
//  Returns the 3D rectangular coordinates for the supplied spherical polar coordinates.
//
//  The meridian of the sphere is aligned in the x-y axis and the poles are at the z axis
//  The x, y and z components of the vector supplied represent the following:
//
//  spherical.x = r (radius)
//  spherical.y = theta (ccw rotation around z axis with 0 radians at x axis) typical range 0 - 2pi radians
//  spherical.z = phi (declination from z axis) typical range 0 - pi radians
//

static inline GLKVector3 DSSphericalToRectangular(GLKVector3 spherical) {

    GLKVector3  rectangular;

    const float r = spherical.x, sinPhiR = sinf(spherical.z) * r;

    rectangular.x = sinPhiR * cosf(spherical.y);
    rectangular.y = sinPhiR * sinf(spherical.y);
    rectangular.z = r * cosf(spherical.z);

    return rectangular;
}

//
//  function DSRectangularToSpherical
//
//  Returns the spherical polar coordinates for the supplied 3D rectangular coordinates.
//

static inline GLKVector3 DSRectangularToSpherical(GLKVector3 rectangular) {

    GLKVector3  spherical;
    const float radius = GLKVector3Length(rectangular);

    // Calculate r
    spherical.x = radius;

    // Calculate theta (arctan(y / x))
    spherical.y = atan2f(rectangular.y, rectangular.x);

    // Calculate phi (arccos(z / r))
    spherical.z = acosf(rectangular.z / radius);

    return spherical;
}

#pragma mark Plane

//
//  function DSPointPlaneDistance
//
//  Returns the distance from the supplied point to the supplied plane.
//
//  The plane data format is encapsulated in a 4d vector as follows:
//
//  x,y,z   - plane normal vector
//  w       - plane d (distance to the origin)
//

static inline float DSPointPlaneDistance(GLKVector3 point, GLKVector4 plane) {

    return GLKVector3DotProduct(point, (GLKVector3) { plane.x, plane.y, plane.z }) - plane.w;
}