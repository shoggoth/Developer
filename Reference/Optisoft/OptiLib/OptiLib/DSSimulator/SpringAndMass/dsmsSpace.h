//
//  dsmsSpace.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//


#ifndef DS_MS_SPACE_H
#define DS_MS_SPACE_H


#include "dsmsSpring.h"
#include "dsmsPlane.h"


typedef int(*DSSMMassCollisionCallback)(DSSMSimMass *mass1, DSSMSimMass *mass2);

typedef struct {
    
    float                       friction;
    float                       v_factor, a_factor;
    float                       separation_force;
    
    unsigned                    number_of_masses;
    unsigned                    number_of_springs;
    unsigned                    number_of_planes;
    
    DSSMSimMass                 **masses, **masses_end;
    DSSMSimSpring               **springs, **springs_end;
    DSSMSimPlane                **planes, **planes_end;
    
    DSSMMassCollisionCallback   mass_collision_callback;
    
} DSSMSimSpace;


DSSMSimSpace *dsmsSpaceNew(const unsigned max_masses, const unsigned max_springs, const unsigned max_planes);
void dsmsSpaceFree(DSSMSimSpace * const space);

void dsmsSpaceStep(DSSMSimSpace * const space);

void dsmsSpaceAddMass(DSSMSimSpace *space, DSSMSimMass *mass);
void dsmsSpaceRemMass(DSSMSimSpace *space, DSSMSimMass *mass);

void dsmsSpaceAddSpring(DSSMSimSpace *space, DSSMSimSpring *spring);
void dsmsSpaceRemSpring(DSSMSimSpace *space, DSSMSimSpring *spring);

void dsmsSpaceAddPlane(DSSMSimSpace *space, DSSMSimPlane *plane);
void dsmsSpaceRemPlane(DSSMSimSpace *space, DSSMSimPlane *plane);

#endif