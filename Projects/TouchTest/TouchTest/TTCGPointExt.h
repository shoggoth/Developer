//
//  DSCGPointExt.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

extern const float kDSCGPointEpsilon;
extern const CGPoint kDSCGPointXAxis, kDSCGPointYAxis;

// Negative of the given point
static inline CGPoint DSCGPointNegate(const CGPoint v) { return (CGPoint) { -v.x, -v.y }; }

// Calculates sum of two points.
static inline CGPoint DSCGPointAdd(const CGPoint v1, const CGPoint v2) { return (CGPoint) { v1.x + v2.x, v1.y + v2.y }; }

// Calculates difference of two points.
static inline CGPoint DSCGPointSubtract(const CGPoint v1, const CGPoint v2) { return (CGPoint) { v1.x - v2.x, v1.y - v2.y }; }

// Returns point multiplied by given factor.
static inline CGPoint DSCGPointMultiply(const CGPoint a, const CGPoint b) { return (CGPoint) { a.x * b.x, a.y * b.y }; }
static inline CGPoint DSCGPointMultiplyScalar(const CGPoint v, const CGFloat s) { return (CGPoint) { v.x * s, v.y * s }; }

// Calculates midpoint between two points.
static inline CGPoint DSCGPointMidpoint(const CGPoint v1, const CGPoint v2) { return DSCGPointMultiplyScalar(DSCGPointAdd(v1, v2), 0.5f); }

// Calculates dot product of two points.
static inline CGFloat DSCGPointDotProduct(const CGPoint v1, const CGPoint v2) { return v1.x * v2.x + v1.y * v2.y; }

// Calculates cross product of two points.
static inline CGFloat DSCGPointCrossProduct(const CGPoint v1, const CGPoint v2) { return v1.x * v2.y - v1.y * v2.x; }

// Calculates perpendicular of v, rotated 90 degrees counter-clockwise -- cross(v, perp(v)) >= 0
static inline CGPoint DSCGPointPerp(const CGPoint v) { return (CGPoint) { -v.y, v.x }; }

// Calculates perpendicular of v, rotated 90 degrees clockwise -- cross(v, rperp(v)) <= 0
static inline CGPoint DSCGPointRPerp(const CGPoint v) { return (CGPoint) { v.y, -v.x }; }

// Calculates the projection of v1 over v2.
static inline CGPoint DSCGPointProject(const CGPoint v1, const CGPoint v2) { return DSCGPointMultiplyScalar(v2, DSCGPointDotProduct(v1, v2) / DSCGPointDotProduct(v2, v2)); }

// Rotates two points.
static inline CGPoint DSCGPointRotate(const CGPoint v1, const CGPoint v2) { return (CGPoint) { v1.x * v2.x - v1.y * v2.y, v1.x * v2.y + v1.y * v2.x }; }

// Unrotates two points.
static inline CGPoint DSCGPointUnrotate(const CGPoint v1, const CGPoint v2) { return (CGPoint) { v1.x * v2.x + v1.y * v2.y, v1.y * v2.x - v1.x * v2.y }; }

// Calculates the square length of a CGPoint (not calling sqrt() )
static inline CGFloat DSCGPointLengthSquared(const CGPoint v) { return DSCGPointDotProduct(v, v); }

// Calculates the square distance between two points (not calling sqrt() )
static inline CGFloat DSCGPointDistanceSquared(const CGPoint p1, const CGPoint p2) { return DSCGPointLengthSquared(DSCGPointSubtract(p1, p2)); }

// Calculates distance between point an origin
CGFloat DSCGPointLength(const CGPoint v);

// Calculates the distance between two points
CGFloat DSCGPointDistance(const CGPoint v1, const CGPoint v2);

// Returns point multiplied to a length of 1.
CGPoint DSCGPointNormalize(const CGPoint v);

// Converts radians to a normalized vector.
CGPoint DSCGPointForAngle(const CGFloat a);

// Converts a vector to radians.
CGFloat DSCGPointToAngle(const CGPoint v);

// Clamp a value between from and to.
float clampf(float value, float min_inclusive, float max_inclusive);

// Clamp a point between from and to.
CGPoint DSCGPointClamp(CGPoint p, CGPoint from, CGPoint to);

// Quickly convert CGSize to a CGPoint
CGPoint DSCGPointFromSize(CGSize s);

// Run a math operation function on each point component
CGPoint DSCGPointCompOp(CGPoint p, float (*opFunc)(float));

// Linear Interpolation between two points a and b
CGPoint DSCGPointLerp(CGPoint a, CGPoint b, float alpha);

// If points have fuzzy equality which means equal with some degree of variance.
BOOL DSCGPointFuzzyEqual(CGPoint a, CGPoint b, float variance);

// The signed angle in radians between two vector directions
float DSCGPointAngleSigned(CGPoint a, CGPoint b);

// The angle in radians between two vector directions
float DSCGPointAngle(CGPoint a, CGPoint b);

// Rotates a point counter clockwise by the angle around a pivot
CGPoint DSCGPointRotateByAngle(CGPoint v, CGPoint pivot, float angle);

// A general line-line intersection test
BOOL DSCGPointLineIntersect(CGPoint p1, CGPoint p2, CGPoint p3, CGPoint p4, float *s, float *t);

// DSCGPointSegmentIntersect returns YES if Segment A-B intersects with segment C-D
BOOL DSCGPointSegmentIntersect(CGPoint A, CGPoint B, CGPoint C, CGPoint D);

// DSCGPointIntersectPoint returns the intersection point of line A-B, C-D
CGPoint DSCGPointIntersectPoint(CGPoint A, CGPoint B, CGPoint C, CGPoint D);
