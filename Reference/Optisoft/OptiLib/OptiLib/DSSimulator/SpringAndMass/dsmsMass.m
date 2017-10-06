//
//  dsmsMass.c
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#include "dsmsMass.h"
#include <stdlib.h>
#include <assert.h>


DSSMSimMass *dsmsMassNew(const float m, const float r) {

    DSSMSimMass *newMass = calloc(1, sizeof(DSSMSimMass));
    assert(newMass);
    
    newMass->mass = m;
    newMass->radius = r;
    
    return newMass;
}
