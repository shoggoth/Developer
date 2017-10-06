//
//  IDLens.m
//  iDispense
//
//  Created by Richard Henry on 15/04/2014.
//  Copyright (c) 2014 Optisoft. All rights reserved.
//

#import "IDLensMesh.h"
#import "DSMaths.h"

const float kIDRadiusOfCurvatureDivisor = 185;

#pragma mark Lens RenderNode

@implementation IDLensNode {

    IDLensParameters        parameters;
}

- (instancetype)initWithParameters:(IDLensParameters)params {

    if ((self = [super init])) {

        // Parameter mungeing
        [self mungeParameters:params];

        // Meshes
        IDLensMesh *frontMesh = [IDLensMesh new];
        [frontMesh makeFrontMeshWithParameters:parameters];

        IDLensMesh *sideMesh = [IDLensMesh new];
        [sideMesh makeSideMeshWithParameters:parameters];

        IDLensMesh *backMesh = [IDLensMesh new];
        [backMesh makeBackMeshWithParameters:parameters];

        // VBOs
        DSVertexBufferObject *frontMeshVBO = [[DSVertexBufferObject alloc] initWithVertexSource:frontMesh];
        DSVertexBufferObject *sideMeshVBO  = [[DSVertexBufferObject alloc] initWithVertexSource:sideMesh];
        DSVertexBufferObject *backMeshVBO  = [[DSVertexBufferObject alloc] initWithVertexSource:backMesh];

        // Drawing
        self.drawBlock = ^(DSDrawContext *context) {

            [frontMeshVBO drawInContext:context];
            [sideMeshVBO drawInContext:context];
            [backMeshVBO drawInContext:context];
        };
    }

    return self;
}

#pragma mark Mungeing

- (void)mungeParameters:(IDLensParameters)params {

    //static struct { float lensPower; float baseCurve; } bestFitValues[7] = { { -20, 0.5 }, { -10, 2.0 }, { -5, 4.0 }, { -3, 6.0 }, { +3, 8.0 }, { +8, 10.0 }, { +10, 12.0 }};
    static struct { float lensPower; float baseCurve; } bestFitValues[8] = { { -20, 0.5 }, { -10, 2.0 }, { -5, 4.0 }, { -3, 6.0 }, { +3, 7.0 }, { +6, 10.0 }, { +8, 12.0 }, { +13, 13.5 }};
    static const float kIDMinRefractiveIndex = 1.4, kIDMaxRefractiveIndex = 2.0;
    static const float kIDRefractiveIndexRange = kIDMaxRefractiveIndex - kIDMinRefractiveIndex;
    parameters = params;

    const float sphere = parameters.prescription.sph;

    // Sanity check on values
    parameters.material.refractiveIndex = DSClampFloat(parameters.material.refractiveIndex, kIDMinRefractiveIndex, kIDMaxRefractiveIndex);

#if defined (USE_VOGELS_FORMULA)
    // Find the curves due to sphere on the front and back surfaces (Vogel's formula)
    if (sphere > 0) {

        parameters.grind.baseCurve = sphere + 6;
        parameters.grind.backCurve = parameters.grind.baseCurve - sphere;

    } else if (sphere < 0) {

        parameters.grind.baseCurve = sphere * 0.5 + 6;
        parameters.grind.backCurve = parameters.grind.baseCurve - sphere;

    } else parameters.grind.baseCurve = parameters.grind.backCurve = FLT_EPSILON;

#else

    if (sphere == 0) parameters.grind.baseCurve = parameters.grind.backCurve = FLT_EPSILON;

    else {

        for (int i = 0; i < 8; i++) {

            if (sphere < bestFitValues[i].lensPower) break;

            parameters.grind.baseCurve = bestFitValues[i].baseCurve;
        }

        parameters.grind.backCurve = fabsf(sphere - parameters.grind.baseCurve);
    }
#endif

    // NOTE: I have added in the multiply by .67 here to compensate for extending the range that can be represented in
    // the cylinder power. It has been raised from 10 to 15
    const float cylPowerRefractiveMultiplier = ((kIDRefractiveIndexRange - (parameters.material.refractiveIndex - kIDMinRefractiveIndex)) + 0.1) * 0.67;

    // Find the curves due to the cyl
    if (parameters.prescription.cyl < 0) {

        parameters.grind.cylAxis = parameters.prescription.axis + M_PI * 0.5;
        parameters.grind.cylPower = -cylPowerRefractiveMultiplier * parameters.prescription.cyl;

    } else {

        parameters.grind.cylAxis = parameters.prescription.axis;
        parameters.grind.cylPower = cylPowerRefractiveMultiplier * parameters.prescription.cyl;
    }

    // Sagittas and sphere radii
    parameters.grind.baseSphereRadius = radiusOfCurvature(parameters.material.refractiveIndex, parameters.grind.baseCurve) * kIDRadiusOfCurvatureDivisor;
    parameters.grind.backSphereRadius = radiusOfCurvature(parameters.material.refractiveIndex, parameters.grind.backCurve) * kIDRadiusOfCurvatureDivisor;
    parameters.grind.baseSagitta = sagittaForSphereRadius(parameters.blankDiameter, parameters.grind.baseSphereRadius);
    parameters.grind.backSagitta = sagittaForSphereRadius(parameters.blankDiameter, parameters.grind.backSphereRadius);

    // Compensate for the minimum lens thickness
    parameters.grind.thickness = (parameters.grind.baseSagitta + parameters.grind.backSagitta <= parameters.minimumThickness) ? parameters.minimumThickness : 0;
}

@end
