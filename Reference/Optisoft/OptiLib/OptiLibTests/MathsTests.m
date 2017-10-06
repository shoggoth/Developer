//
//  MathsTests.m
//  OptiLib
//
//  Created by Richard Henry on 18/07/2014.
//  Copyright (c) 2014 Optisoft. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "DSMaths.h"


@interface MathsTests : XCTestCase

@end

@implementation MathsTests

#pragma mark Polar - rectangular

- (void)testPolarRectangular {

    const float epsilon = 0.00001;

    NSLog(@"Testing polar <-> rectangular conversions epsilon = %f", epsilon);

    for (float radius = 0.01; radius < 100; radius *= 2) {

        for (float theta = -1.999 * M_PI; theta < 2 * M_PI; theta += 0.01 * M_PI) {

            GLKVector2 polar = (GLKVector2) { radius, theta };
            GLKVector2 rectangular = DSPolarToRectangular(polar);
            GLKVector2 rectToPolar = DSRectangularToPolar(rectangular);

            // Normalise angles for comparison
            if (polar.y < 0) polar.y += M_PI * 2;
            if (rectToPolar.y < 0) rectToPolar.y += M_PI * 2;

            XCTAssert(fabsf(polar.x - rectToPolar.x) < epsilon, @"Failed polar radius %f (%f in %f out)", radius, polar.x, rectToPolar.x);
            XCTAssert(fabsf(polar.y - rectToPolar.y) < epsilon, @"Failed polar angle %f (%f in %f out)", theta, polar.y, rectToPolar.y);
        }
    }
}

- (void)testRectangularPolar {

    const float epsilon = 0.00001;

    NSLog(@"Testing rectangular <-> polar conversions epsilon = %f", epsilon);

    for (float x = -10; x < 10; x += 0.1) {

        for (float y = -10; y < 10; y += 0.1) {


            if ((fabsf(x) < epsilon) || (fabsf(y) < epsilon)) continue;

            GLKVector2 rectangular = (GLKVector2) { x, y };
            GLKVector2 polar = DSRectangularToPolar(rectangular);
            GLKVector2 polarToRect = DSPolarToRectangular(polar);

            XCTAssert(fabsf(rectangular.x - polarToRect.x) < epsilon, @"Failed polar x %f (%f in %f out)", x, rectangular.x, polarToRect.x);
            XCTAssert(fabsf(rectangular.y - polarToRect.y) < epsilon, @"Failed polar y %f (%f in %f out)", y, rectangular.y, polarToRect.y);
        }
    }
}

#pragma mark Spherical - rectangular

- (void)testSphericalRectangular {

    const float epsilon = 0.0001;

    NSLog(@"Testing spherical <-> rectangular conversions epsilon = %f", epsilon);

    for (float radius = 0.01; radius < 100; radius *= 2) {

        for (float theta = -1.999 * M_PI; theta < 2 * M_PI; theta += 0.01 * M_PI) {

            for (float phi = 0.01; phi < M_PI; phi += 0.01 * M_PI) {

                GLKVector3 spherical = (GLKVector3) { radius, theta, phi };
                GLKVector3 rectangular = DSSphericalToRectangular(spherical);
                GLKVector3 rectToSphere = DSRectangularToSpherical(rectangular);

                // Normalise angles for comparison
                if (spherical.y < 0) spherical.y += M_PI * 2;
                if (rectToSphere.y < 0) rectToSphere.y += M_PI * 2;

                XCTAssert(fabsf(spherical.x - rectToSphere.x) < epsilon, @"Failed spherical radius %f (%f in %f out ( / M_PI))", radius, spherical.x / M_PI, rectToSphere.x / M_PI);
                XCTAssert(fabsf(spherical.y - rectToSphere.y) < epsilon, @"Failed spherical theta %f (%f in %f out ( / M_PI))", theta, spherical.y / M_PI, rectToSphere.y / M_PI);
                XCTAssert(fabsf(spherical.z - rectToSphere.z) < epsilon, @"Failed spherical phi %f (%f in %f out ( / M_PI))", theta, spherical.z / M_PI, rectToSphere.z / M_PI);
            }
        }
    }
}

- (void)testRectangularSpherical {

    const float epsilon = 0.0001;

    NSLog(@"Testing rectangular <-> spherical conversions epsilon = %f", epsilon);

    for (float x = -10; x < 10; x += 0.1) {

        for (float y = -10; y < 10; y += 0.1) {

            for (float z = -10; z < 10; z += 0.1) {


                if ((fabsf(x) < epsilon) || (fabsf(y) < epsilon) || (fabsf(z) < epsilon)) continue;

                GLKVector3 rectangular = (GLKVector3) { x, y, z };
                GLKVector3 spherical = DSRectangularToSpherical(rectangular);
                GLKVector3 sphereToRect = DSSphericalToRectangular(spherical);

                XCTAssert(fabsf(rectangular.x - sphereToRect.x) < epsilon, @"Failed rect -> spherical x %f (%f in %f out)", x, rectangular.x, sphereToRect.x);
                XCTAssert(fabsf(rectangular.y - sphereToRect.y) < epsilon, @"Failed rect -> spherical y %f (%f in %f out)", y, rectangular.y, sphereToRect.y);
                XCTAssert(fabsf(rectangular.z - sphereToRect.z) < epsilon, @"Failed rect -> spherical z %f (%f in %f out)", z, rectangular.z, sphereToRect.z);
            }
        }
    }
}

#pragma mark Cylindrical - rectangular

- (void)testCylindricalRectangular {

    const float epsilon = 0.00001;

    NSLog(@"Testing cylindrical <-> rectangular conversions epsilon = %f", epsilon);

    for (float radius = 0.01; radius < 100; radius *= 2) {

        for (float theta = -1.999 * M_PI; theta < 2 * M_PI; theta += 0.01 * M_PI) {

            for (float h = -100; h < 100; h += 2.3) {

                GLKVector3 cylindrical = (GLKVector3) { radius, theta, h };
                GLKVector3 rectangular = DSCylindricalToRectangular(cylindrical);
                GLKVector3 rectToCylinder = DSRectangularToCylindrical(rectangular);

                // Normalise angles for comparison
                if (cylindrical.y < 0) cylindrical.y += M_PI * 2;
                if (rectToCylinder.y < 0) rectToCylinder.y += M_PI * 2;

                XCTAssert(fabsf(cylindrical.x - rectToCylinder.x) < epsilon, @"Failed cylindrical radius %f (%f in %f out)", radius, cylindrical.x, rectToCylinder.x);
                XCTAssert(fabsf(cylindrical.y - rectToCylinder.y) < epsilon, @"Failed cylindrical theta %f (%f in %f out)", theta, cylindrical.y, rectToCylinder.y);
                XCTAssert(fabsf(cylindrical.z - rectToCylinder.z) < epsilon, @"Failed cylindrical h %f (%f in %f out)", theta, cylindrical.z, rectToCylinder.z);
            }
        }
    }
}

- (void)testRectangularCylindrical {

    const float epsilon = 0.00001;

    NSLog(@"Testing rectangular <-> cylindrical conversions epsilon = %f", epsilon);

    for (float x = -10; x < 10; x += 0.1) {

        for (float y = -10; y < 10; y += 0.1) {

            for (float z = -10; z < 10; z += 0.1) {


                if ((fabsf(x) < epsilon) || (fabsf(y) < epsilon) || (fabsf(z) < epsilon)) continue;

                GLKVector3 rectangular = (GLKVector3) { x, y, z };
                GLKVector3 cylindrical = DSRectangularToCylindrical(rectangular);
                GLKVector3 cylinderToRect = DSCylindricalToRectangular(cylindrical);

                XCTAssert(fabsf(rectangular.x - cylinderToRect.x) < epsilon, @"Failed rect -> cylindrical x %f (%f in %f out)", x, rectangular.x, cylinderToRect.x);
                XCTAssert(fabsf(rectangular.y - cylinderToRect.y) < epsilon, @"Failed rect -> cylindrical y %f (%f in %f out)", y, rectangular.y, cylinderToRect.y);
                XCTAssert(fabsf(rectangular.z - cylinderToRect.z) < epsilon, @"Failed rect -> cylindrical z %f (%f in %f out)", z, rectangular.z, cylinderToRect.z);
            }
        }
    }
}

#pragma mark - Point and plane

- (void)testPointPlaneDistance {

    NSLog(@"Testing Point-plane distance conversions");

    for (float amount = FLT_EPSILON; amount < 1000; amount *= 2) {

        // Points on planes
        XCTAssert(DSPointPlaneDistance((GLKVector3) { 0, 0, 0 }, (GLKVector4) { 1, 0, 0, 0 }) == 0);
        XCTAssert(DSPointPlaneDistance((GLKVector3) { 0, 0, 0 }, (GLKVector4) { 0, 1, 0, 0 }) == 0);
        XCTAssert(DSPointPlaneDistance((GLKVector3) { 0, 0, 0 }, (GLKVector4) { 0, 0, 1, 0 }) == 0);

        XCTAssert(DSPointPlaneDistance((GLKVector3) { 0, 0, 0 }, (GLKVector4) { -1, 0, 0, 0 }) == 0);
        XCTAssert(DSPointPlaneDistance((GLKVector3) { 0, 0, 0 }, (GLKVector4) { 0, -1, 0, 0 }) == 0);
        XCTAssert(DSPointPlaneDistance((GLKVector3) { 0, 0, 0 }, (GLKVector4) { 0, 0, -1, 0 }) == 0);

        XCTAssert(DSPointPlaneDistance((GLKVector3) { amount, 0, 0 }, (GLKVector4) { 1, 0, 0, amount }) == 0);
        XCTAssert(DSPointPlaneDistance((GLKVector3) { 0, amount, 0 }, (GLKVector4) { 0, 1, 0, amount }) == 0);
        XCTAssert(DSPointPlaneDistance((GLKVector3) { 0, 0, amount }, (GLKVector4) { 0, 0, 1, amount }) == 0);

        XCTAssert(DSPointPlaneDistance((GLKVector3) { -amount, 0, 0 }, (GLKVector4) { 1, 0, 0, -amount }) == 0);
        XCTAssert(DSPointPlaneDistance((GLKVector3) { 0, -amount, 0 }, (GLKVector4) { 0, 1, 0, -amount }) == 0);
        XCTAssert(DSPointPlaneDistance((GLKVector3) { 0, 0, -amount }, (GLKVector4) { 0, 0, 1, -amount }) == 0);

        // Points to the positive
        XCTAssert(DSPointPlaneDistance((GLKVector3) { amount, 0, 0 }, (GLKVector4) { 1, 0, 0, 0 }) == amount);
        XCTAssert(DSPointPlaneDistance((GLKVector3) { 0, amount, 0 }, (GLKVector4) { 0, 1, 0, 0 }) == amount);
        XCTAssert(DSPointPlaneDistance((GLKVector3) { 0, 0, amount }, (GLKVector4) { 0, 0, 1, 0 }) == amount);

        XCTAssert(DSPointPlaneDistance((GLKVector3) { 0, 0, 0 }, (GLKVector4) { 1, 0, 0, -amount }) == amount);
        XCTAssert(DSPointPlaneDistance((GLKVector3) { 0, 0, 0 }, (GLKVector4) { 0, 1, 0, -amount }) == amount);
        XCTAssert(DSPointPlaneDistance((GLKVector3) { 0, 0, 0 }, (GLKVector4) { 0, 0, 1, -amount }) == amount);

        // Points to the negative
        XCTAssert(DSPointPlaneDistance((GLKVector3) { -amount, 0, 0 }, (GLKVector4) { 1, 0, 0, 0 }) == -amount);
        XCTAssert(DSPointPlaneDistance((GLKVector3) { 0, -amount, 0 }, (GLKVector4) { 0, 1, 0, 0 }) == -amount);
        XCTAssert(DSPointPlaneDistance((GLKVector3) { 0, 0, -amount }, (GLKVector4) { 0, 0, 1, 0 }) == -amount);

        XCTAssert(DSPointPlaneDistance((GLKVector3) { 0, 0, 0 }, (GLKVector4) { 1, 0, 0, amount }) == -amount);
        XCTAssert(DSPointPlaneDistance((GLKVector3) { 0, 0, 0 }, (GLKVector4) { 0, 1, 0, amount }) == -amount);
        XCTAssert(DSPointPlaneDistance((GLKVector3) { 0, 0, 0 }, (GLKVector4) { 0, 0, 1, amount }) == -amount);
    }
}

@end
