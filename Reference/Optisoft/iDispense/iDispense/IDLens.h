//
//  IDLens.h
//  iDispense
//
//  Created by Richard Henry on 15/04/2014.
//  Copyright (c) 2014 Optisoft. All rights reserved.
//

#import "DSRenderNode.h"

typedef enum { rightEye, leftEye } IDEyePosition;

typedef struct {

    float       sph, cyl, add;

    float       axis;

    float       npd, dpd;

} IDLensPrescription;

typedef struct {

    float       refractiveIndex;
    float       specificGravity;        // g/cm^3
    float       minEdgeThickness;       // mm
    float       minCentreThickness;     // mm

} IDLensMaterial;

typedef struct {

    // Sphere grind
    float       baseCurve, baseSphereRadius, baseSagitta;
    float       backCurve, backSphereRadius, backSagitta;
    float       thickness;

    // Cylinder grind
    float       cylAxis, cylPower;

} IDLensGrind;

typedef struct {

    unsigned            shape;
    float               blankDiameter;
    float               minimumThickness;

    IDEyePosition       eyePosition;
    IDLensPrescription  prescription;
    IDLensGrind         grind;
    IDLensMaterial      material;

} IDLensParameters;

#pragma mark Curvature

static inline float radiusOfCurvature(const float refractiveIndex, const float focalPower) {

    return (refractiveIndex - 1) / focalPower;
}

#pragma mark Sagitta

/*
 
 Modern ophthalmic lenses are generally meniscus—or "crescent-shaped" in form.
 This means that they typically have a convex front surface (i.e., positive power) and a concave back surface (i.e., negative power).
 
 */

static inline float sagittaForSphereRadius(const float diameter, const float radius) {

    return radius - powf((powf(radius, 2) - powf(diameter * 0.5, 2)), 0.5);
}

static inline float approximateSagittaForSphereRadius(const float diameter, const float radius) {

    return powf(diameter * 0.5, 2) / (radius * 2);
}

static inline float approximateSagittaForSurfacePowerAndRefractiveIndex(const float diameter, float const surfacePower, float const refractiveIndex) {

    return (powf(diameter * 0.5, 2) * surfacePower) / ((refractiveIndex - 1) * 2000);
}

#pragma mark Thickness

/*
 
 Keep in mind that minus lenses are never made to a "zero" center thickness, and plus lenses are very seldom surfaced to a "zero"—or knife-edged—edge thickness.
 There is always some minimum substance or thickness to the lens.
 Typical minimum thickness guidelines for traditional ophthalmic lenses range from a minimum edge thickness of 1 mm to a minimum center thickness of 2 mm.
 
 */

static inline float centerThicknessForEdgeAndSagittas(const float edgeThickness, const float frontSag, const float backSag) {

    return edgeThickness + frontSag + backSag;
}

static inline float edgeThicknessForCenterAndSagittas(const float centerThickness, const float frontSag, const float backSag) {

    return centerThickness - (frontSag + backSag);
}

static inline float maximumThicknessForMinimumAndSagittas(const float minimumThickness, const float frontSag, const float backSag) {

    return minimumThickness + fabsf(frontSag + backSag);
}

#pragma mark Cylinder

static inline GLKVector4 cylinderAxisPlaneForGrind(IDLensParameters prescription) {

    // Change to the cylinder axis offset to match feedback from Ronnie.
    static const float cylinderAxisOffset = M_PI * 0.0;

    return (GLKVector4) { cosf(prescription.grind.cylAxis + cylinderAxisOffset), sinf(prescription.grind.cylAxis + cylinderAxisOffset), 0, 0 };
}

#pragma mark Lens node

@interface IDLensNode : DSProgrammableRenderNode

- (instancetype)initWithParameters:(IDLensParameters)parameters;

@end
