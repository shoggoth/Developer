//
//  DSCGPointExt.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSCGPointExt.h"

const float kDSCGPointEpsilon = FLT_EPSILON;
const CGPoint kDSCGPointXAxis = (CGPoint) { 1, 0 };
const CGPoint kDSCGPointYAxis = (CGPoint) { 0, 1 };


CGFloat DSCGPointLength(const CGPoint v) { return sqrtf(DSCGPointLengthSquared(v)); }

CGFloat DSCGPointDistance(const CGPoint v1, const CGPoint v2) { return DSCGPointLength(DSCGPointSubtract(v1, v2)); }

CGPoint DSCGPointNormalize(const CGPoint v) { return DSCGPointMultiplyScalar(v, 1.0f / DSCGPointLength(v)); }

CGPoint DSCGPointForAngle(const CGFloat a) { return (CGPoint) { cosf(a), sinf(a) }; }

CGFloat DSCGPointToAngle(const CGPoint v) { return atan2f(v.y, v.x); }

CGPoint DSCGPointLerp(CGPoint a, CGPoint b, float alpha) { return DSCGPointAdd(DSCGPointMultiplyScalar(a, 1.f - alpha), DSCGPointMultiplyScalar(b, alpha)); }

float clampf(float value, float min_inclusive, float max_inclusive) {

	assert (max_inclusive >= min_inclusive);

    return (value < min_inclusive) ? min_inclusive : (value < max_inclusive) ? value : max_inclusive;
}

CGPoint DSCGPointClamp(CGPoint p, CGPoint min_inclusive, CGPoint max_inclusive) {

	return (CGPoint) { clampf(p.x, min_inclusive.x, max_inclusive.x), clampf(p.y, min_inclusive.y, max_inclusive.y) };
}

CGPoint DSCGPointFromSize(CGSize s) {

	return (CGPoint) { s.width, s.height };
}

CGPoint DSCGPointCompOp(CGPoint p, float (*opFunc)(float)) {

	return (CGPoint) { opFunc(p.x), opFunc(p.y) };
}

BOOL DSCGPointFuzzyEqual(CGPoint a, CGPoint b, float variance) { return ((a.x - variance <= b.x && b.x <= a.x + variance) && (a.y - variance <= b.y && b.y <= a.y + variance)); }

float DSCGPointAngleSigned(CGPoint a, CGPoint b) {

	CGPoint a2 = DSCGPointNormalize(a);
	CGPoint b2 = DSCGPointNormalize(b);

    float angle = atan2f(a2.x * b2.y - a2.y * b2.x, DSCGPointDotProduct(a2, b2));

    if (fabs(angle) < kDSCGPointEpsilon) return 0.f;

    return angle;
}

CGPoint DSCGPointRotateByAngle(CGPoint v, CGPoint pivot, float angle) {

	CGPoint r = DSCGPointSubtract(v, pivot);
	float cosa = cosf(angle), sina = sinf(angle);
	float t = r.x;

	r.x = t * cosa - r.y * sina + pivot.x;
	r.y = t * sina + r.y * cosa + pivot.y;

    return r;
}


BOOL DSCGPointSegmentIntersect(CGPoint A, CGPoint B, CGPoint C, CGPoint D) {

	float S, T;

	return (DSCGPointLineIntersect(A, B, C, D, &S, &T) && (S >= 0.0f && S <= 1.0f && T >= 0.0f && T <= 1.0f));
}

CGPoint DSCGPointIntersectPoint(CGPoint A, CGPoint B, CGPoint C, CGPoint D) {

	float S, T;

	if (DSCGPointLineIntersect(A, B, C, D, &S, &T)) {

        CGPoint P;  // Point of intersection

		P.x = A.x + S * (B.x - A.x);
		P.y = A.y + S * (B.y - A.y);

        return P;
	}

	return CGPointZero;
}

BOOL DSCGPointLineIntersect(CGPoint A, CGPoint B, CGPoint C, CGPoint D, float *S, float *T) {

	// FAIL: Line undefined
	if ((A.x == B.x && A.y == B.y) || (C.x == D.x && C.y == D.y)) return NO;

	const float BAx = B.x - A.x;
	const float BAy = B.y - A.y;
	const float DCx = D.x - C.x;
	const float DCy = D.y - C.y;
	const float ACx = A.x - C.x;
	const float ACy = A.y - C.y;

	const float denom = DCy * BAx - DCx * BAy;

	*S = DCx * ACy - DCy * ACx;
	*T = BAx * ACy - BAy * ACx;

	if (denom == 0) {
		if (*S == 0 || *T == 0) {
			// Lines incident
			return YES;
		}
		// Lines parallel and not incident
		return NO;
	}

	*S = *S / denom;
	*T = *T / denom;

	// Point of intersection
	// CGPoint P;
	// P.x = A.x + *S * (B.x - A.x);
	// P.y = A.y + *S * (B.y - A.y);

	return YES;
}

float DSCGPointAngle(CGPoint a, CGPoint b) {

	float angle = acosf(DSCGPointDotProduct(DSCGPointNormalize(a), DSCGPointNormalize(b)));
    
    if (fabs(angle) < kDSCGPointEpsilon) return 0.f;
    
    return angle;
}
