//
//  dsisSpace.c
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//


#include "dsisSpace.h"
#include <stdlib.h>
#include <assert.h>
#include <stdio.h>


DSISSimSpace *dsisSpaceNew(const unsigned max_masses) {
    
    DSISSimSpace *space = malloc(sizeof(DSISSimSpace));
    assert(space);
    
    space->masses = calloc(max_masses, sizeof(DSISSimMass *));
    assert(space->masses);
    
    space->masses_end = &space->masses[max_masses];
    
    space->number_of_masses = 0;
    
    return space;
}

void dsisSpaceFree(DSISSimSpace * const space) {
    
    free(space->masses);
    
    free(space);
}

void dsisSpaceStep(DSISSimSpace * const space) {
    
    // Clear forces
    for (unsigned i = 0; i < space->number_of_masses; i++) {
        
        space->masses[i]->frc = (GLKVector2) { 0, 0 };
    }
    
    // Calculate mass effect
    for (unsigned i = 0; i < space->number_of_masses; i++) {
        
        DSISSimMass *mass_i = space->masses[i];
        
        for (unsigned j = i + 1; j < space->number_of_masses; j++) {
            
            DSISSimMass *mass_j = space->masses[j];
            
            float       mass_sum = mass_i->mass + mass_j->mass;
            GLKVector2  force_vector = GLKVector2Subtract(mass_i->pos, mass_j->pos);
            float       d = GLKVector2Length(force_vector);
            
            if (d > mass_i->radius + mass_j->radius) {
                
                force_vector = GLKVector2Normalize(force_vector);
                
                mass_i->frc = GLKVector2Add(mass_i->frc, GLKVector2MultiplyScalar(force_vector, -mass_sum * (1.0 / (d * d))));
                mass_j->frc = GLKVector2Add(mass_j->frc, GLKVector2MultiplyScalar(force_vector, mass_sum * (1.0 / (d * d))));
            }
        }
    }
}

void dsisSpaceAddMass(DSISSimSpace *space, DSISSimMass *mass) {
    
    for (DSISSimMass **p = space->masses; p < space->masses_end; p++) {
        
        assert(*p != mass);
        
        if (!*p) {
            
            *p = mass;
            space->number_of_masses++;
            
            // Initialise the mass' contents
            mass->pos = (GLKVector2) { 0, 0 };
            mass->frc = (GLKVector2) { 0, 0 };
            
            mass->mass = 1.0;
            mass->radius = 0.5;
            
            break;
        }
    }
}

void dsisSpaceRemMass(DSISSimSpace *space, DSISSimMass *mass) {
    
    int mass_found = 0;
    
    for (DSISSimMass **p = space->masses; p < space->masses_end; p++) {
        
        if (*p == mass) {
            
            // Remove the mass if we find it
            assert(!mass_found && space->number_of_masses > 0);
            
            *p = 0;
            space->number_of_masses--;
            mass_found = 1;
            
        } else if (mass_found) {
            
            // Compact the array
            *(p - 1) = *p;
            *p = 0;
        }
    }
    
    assert(mass_found);
}
