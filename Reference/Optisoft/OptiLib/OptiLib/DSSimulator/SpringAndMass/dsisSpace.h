//
//  dsisSpace.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//


#ifndef DS_IS_SPACE_H
#define DS_IS_SPACE_H

#include <GLKit/GLKMath.h>


typedef struct {
    
    GLKVector2          pos;
    GLKVector2          frc;
    
    float               mass;
    float               radius;
    
} DSISSimMass;


typedef struct {

    unsigned            number_of_masses;
    
    DSISSimMass         **masses, **masses_end;
    
} DSISSimSpace;


DSISSimSpace *dsisSpaceNew(const unsigned max_masses);
void dsisSpaceFree(DSISSimSpace * const space);

void dsisSpaceStep(DSISSimSpace * const space);

void dsisSpaceAddMass(DSISSimSpace *space, DSISSimMass *mass);
void dsisSpaceRemMass(DSISSimSpace *space, DSISSimMass *mass);

#endif