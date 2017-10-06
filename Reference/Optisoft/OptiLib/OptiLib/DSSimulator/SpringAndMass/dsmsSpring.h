//
//  dsmsSpring.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//


#ifndef DS_MS_SPRING_H
#define DS_MS_SPRING_H

#include "dsmsMass.h"

typedef struct {
    
    DSSMSimMass         *mass1, *mass2;
    float               k;
    float               l;
    float               f;
    
} DSSMSimSpring;

#endif