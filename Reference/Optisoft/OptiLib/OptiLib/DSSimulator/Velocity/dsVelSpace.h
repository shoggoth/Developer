//
//  dsVelSpace.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//


#ifndef DS_VEL_SPACE_H
#define DS_VEL_SPACE_H

#include <GLKit/GLKMath.h>


typedef struct {
    
    GLKVector2          pos;
    GLKVector2          vel;
    
    float               radius;
    
} DSVelSimObject;


typedef struct {

    unsigned            number_of_objects;
    
    DSVelSimObject      **objects, **objects_end;
    
} DSVelSimSpace;


DSVelSimSpace *dsVelSpaceNew(const unsigned max_objects);
void dsVelSpaceFree(DSVelSimSpace * const space);

void dsVelSpaceStep(DSVelSimSpace * const space);

void dsVelSpaceAddObject(DSVelSimSpace *space, DSVelSimObject *object);
void dsVelSpaceRemObject(DSVelSimSpace *space, DSVelSimObject *object);

#endif