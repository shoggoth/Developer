//
//  dsmsMass.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//


#ifndef DS_MS_MASS_H
#define DS_MS_MASS_H

#include <GLKit/GLKMath.h>


typedef struct {
    
    // Dynamic properties
    GLKVector2          pos;
    GLKVector2          vel;
    GLKVector2          acc;
    GLKVector2          frc;
    
    // Physical properties
    float               e;
    float               mass;
    float               radius;
    
    // Computational properties
    unsigned short      collision_type;
    unsigned short      collision_mask;
    
    void                *user_data;
    
} DSSMSimMass;


DSSMSimMass *dsmsMassNew(const float m, const float r);

#endif