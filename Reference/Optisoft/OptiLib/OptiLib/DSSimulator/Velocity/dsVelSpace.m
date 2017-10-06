//
//  dsVelSpace.c
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//


#include "dsVelSpace.h"
#include <stdlib.h>
#include <assert.h>
#include <stdio.h>


DSVelSimSpace *dsVelSpaceNew(const unsigned max_objects) {
    
    DSVelSimSpace *space = malloc(sizeof(DSVelSimSpace));
    assert(space);
    
    space->objects = calloc(max_objects, sizeof(DSVelSimObject *));
    assert(space->objects);
    
    space->objects_end = &space->objects[max_objects];
    
    space->number_of_objects = 0;
    
    return space;
}

void dsVelSpaceFree(DSVelSimSpace * const space) {
    
    free(space->objects);
    
    free(space);
}

void dsVelSpaceStep(DSVelSimSpace * const space) {
    
    // Calculate vel effect
    for (unsigned i = 0; i < space->number_of_objects; i++) {
        
        DSVelSimObject *object_i = space->objects[i];
        
        for (unsigned j = i + 1; j < space->number_of_objects; j++) {
            
            DSVelSimObject *object_j = space->objects[j];
            
            float       object_sum = object_i->vel.x + object_j->vel.x; //RJH TODO: fix this, is just fixed compilation error
            GLKVector2  force_vector = GLKVector2Subtract(object_i->pos, object_j->pos);
            float       d = GLKVector2Length(force_vector);
            
            if (d > object_i->radius + object_j->radius) {
                
                force_vector = GLKVector2Normalize(force_vector);
                
                object_i->vel = GLKVector2Add(object_i->vel, GLKVector2MultiplyScalar(force_vector, -object_sum * (1.0 / (d * d))));
                object_j->vel = GLKVector2Add(object_j->vel, GLKVector2MultiplyScalar(force_vector, object_sum * (1.0 / (d * d))));
            }
        }
    }
}

void dsVelSpaceAddObject(DSVelSimSpace *space, DSVelSimObject *object) {
    
    for (DSVelSimObject **p = space->objects; p < space->objects_end; p++) {
        
        assert(*p != object);
        
        if (!*p) {
            
            *p = object;
            space->number_of_objects++;
            
            // Initialise the object's contents
            object->pos = (GLKVector2) { 0, 0 };
            object->vel = (GLKVector2) { 0, 0 };
            
            object->radius = 0.5;
            
            break;
        }
    }
}

void dsVelSpaceRemObject(DSVelSimSpace *space, DSVelSimObject *object) {
    
    int object_found = 0;
    
    for (DSVelSimObject **p = space->objects; p < space->objects_end; p++) {
        
        if (*p == object) {
            
            // Remove the object if we find it
            assert(!object_found && space->number_of_objects > 0);
            
            *p = 0;
            space->number_of_objects--;
            object_found = 1;
            
        } else if (object_found) {
            
            // Compact the array
            *(p - 1) = *p;
            *p = 0;
        }
    }
    
    assert(object_found);
}
