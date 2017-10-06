//
//  dsmsSpace.c
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//


#include "dsmsSpace.h"
#include <stdlib.h>
#include <assert.h>
#include <stdio.h>


static inline float DS2DVectorLengthSquared(const GLKVector2 v) {

    return GLKVector2DotProduct(v, v);
}

static void dsmsCalculateSpringForces(DSSMSimSpace *space) {

    // Calculate spring forces
    for (unsigned i = 0; i < space->number_of_springs; i++) {
        
        DSSMSimSpring *spring = space->springs[i];
        assert(spring);
        
        DSSMSimMass *mass1 = spring->mass1, *mass2 = spring->mass2;
        assert(mass1 && mass2);
        
        if (mass1 && mass2) {
            
            GLKVector2 d = GLKVector2Subtract(mass1->pos, mass2->pos);
            float    l = GLKVector2Length(d);
            
            if (l) {
                
                // Calculate spring force
                GLKVector2 forceVector = GLKVector2MultiplyScalar(GLKVector2MultiplyScalar(d, -1.0 / l), (l - spring->l) * spring->k);
                
                // Subtract spring friction
                forceVector = GLKVector2Add(forceVector, GLKVector2MultiplyScalar(GLKVector2Subtract(mass1->vel, mass2->vel), -spring->f));
                
                mass1->frc = GLKVector2Add(mass1->frc, forceVector);
                mass2->frc = GLKVector2Subtract(mass2->frc, forceVector);
            }
        }
    }
}

static int collision_sort_x_space_compare(const void *e1, const void *e2) {

    const DSSMSimMass *mass1 = *(const DSSMSimMass * const *)e1;
    const DSSMSimMass *mass2 = *(const DSSMSimMass * const *)e2;
    const float m1min = mass1->pos.x - mass1->radius;
    const float m2min = mass2->pos.x - mass2->radius;

    if (m1min == m2min) return 0;

    return (m1min > m2min) ? 1 : -1;
}

static void dsmsResolveObjectToObjectCollisions(DSSMSimSpace *space) {

    // Partition in x space
    qsort(space->masses, space->number_of_masses, sizeof(DSSMSimMass *), collision_sort_x_space_compare);
    
    // Detect and resolve object - object collisions
    for (unsigned i = 0; i < space->number_of_masses; i++) {
        
        DSSMSimMass *mass_i = space->masses[i];
        
        for (unsigned j = i + 1; j < space->number_of_masses; j++) {
            
            DSSMSimMass *mass_j = space->masses[j];
            
            // Collision mask reject
            if (!(mass_i->collision_mask & mass_j->collision_type)) break;
            
            // Partition reject
            if (mass_i->pos.x + mass_i->radius < mass_j->pos.x - mass_j->radius) break;
            
            GLKVector2  collide_normal = GLKVector2Subtract(mass_j->pos, mass_i->pos);
            float     d_squared = DS2DVectorLengthSquared(collide_normal);
            float     radius_sum = mass_i->radius + mass_j->radius;
            
            // Compare distances squared
            if (d_squared < radius_sum * radius_sum) {
                
                // Mass - mass collision callback
                if (!space->mass_collision_callback || space->mass_collision_callback(mass_i, mass_j)) {
                    
                    float     l = DS2DVectorLengthSquared(collide_normal);
                    
                    if (l) {
                        
                        float     e = mass_i->e + mass_j->e;
                        float     inverse_mass_sum = 1.0 / mass_i->mass + 1.0 / mass_j->mass;
                        GLKVector2  relative_velocity = GLKVector2MultiplyScalar(GLKVector2Subtract(mass_j->vel, mass_i->vel), e);
                        
                        // Calculate impulse
                        collide_normal = GLKVector2Normalize(collide_normal);
                        float impulse = GLKVector2DotProduct(relative_velocity, collide_normal) / inverse_mass_sum;
                        
                        if (impulse < 0) {
                            
                            // Calculate exit velocities
                            mass_i->vel = GLKVector2Add(mass_i->vel, GLKVector2MultiplyScalar(collide_normal, impulse / mass_i->mass));
                            mass_j->vel = GLKVector2Add(mass_j->vel, GLKVector2MultiplyScalar(collide_normal, -impulse / mass_j->mass));
                            
                        } else {
                            
                            // Calculate separation forces
                            mass_i->frc = GLKVector2Add(mass_i->frc, GLKVector2MultiplyScalar(collide_normal, -space->separation_force));
                            mass_j->frc = GLKVector2Add(mass_j->frc, GLKVector2MultiplyScalar(collide_normal, space->separation_force));
                            
                        }
                    }
                }
            }
        }
    }
}

static void dsmsResolveObjectToPlaneCollisions(DSSMSimSpace *space) {

    // Detect and resolve object - plane collisions
    for (unsigned i = 0; i < space->number_of_masses; i++) {
        
        DSSMSimMass *mass = space->masses[i];
        
        if (!mass) continue;
        
        for (unsigned j = 0; j < space->number_of_planes; j++) {
            
            DSSMSimPlane *plane = space->planes[j];
            float      d = plane->d + GLKVector2DotProduct(mass->pos, plane->normal);
            
            if (d < mass->radius) {
                
                float e = 1.0 + mass->e;
                float impulse = GLKVector2DotProduct(mass->vel, plane->normal) * e;
                
                if (impulse < 0)
                    mass->vel = GLKVector2Add(mass->vel, GLKVector2MultiplyScalar(plane->normal, -impulse));
            }
        }
    }
}

#pragma mark Space management

DSSMSimSpace *dsmsSpaceNew(const unsigned max_masses, const unsigned max_springs, const unsigned max_planes) {

    DSSMSimSpace *space = malloc(sizeof(DSSMSimSpace));
    assert(space);

    space->friction = 0.04;
    space->v_factor = 0.02;
    space->a_factor = 0.0004;
    space->separation_force = 1.0;

    space->masses = calloc(max_masses, sizeof(DSSMSimMass *));
    space->springs = calloc(max_springs, sizeof(DSSMSimSpring *));
    space->planes = calloc(max_planes, sizeof(DSSMSimPlane *));
    assert(space->masses && space->springs && space->planes);

    space->masses_end = &space->masses[max_masses];
    space->springs_end = &space->springs[max_springs];
    space->planes_end = &space->planes[max_planes];

    space->number_of_masses = 0;
    space->number_of_springs = 0;
    space->number_of_planes = 0;

    space->mass_collision_callback = 0;

    return space;
}

void dsmsSpaceFree(DSSMSimSpace * const space) {

    free(space->masses);
    free(space->springs);
    free(space->planes);

    free(space);
}

#pragma mark Simulation step

void dsmsSpaceStep(DSSMSimSpace * const space) {
    
    dsmsCalculateSpringForces(space);
    
    dsmsResolveObjectToObjectCollisions(space);
    
    // Calculate mass effect
    for (DSSMSimMass **p = space->masses; p < space->masses_end; p++) {
        
        DSSMSimMass *mass = *p;
        
        if (mass) {
            
            assert(mass->mass > 0.0);
            
            float massTimesFriction = mass->mass * space->friction;
            
            // a' = f / m
            mass->acc = GLKVector2MultiplyScalar(GLKVector2Subtract(mass->frc, GLKVector2MultiplyScalar(mass->vel, massTimesFriction)), 1.0 / mass->mass);
            // s' = ut + 0.5at^2
            mass->pos = GLKVector2Add(mass->pos, GLKVector2Add(GLKVector2MultiplyScalar(mass->vel, space->v_factor), GLKVector2MultiplyScalar(mass->acc, space->a_factor)));
            // v' = v + a
            mass->vel = GLKVector2Add(mass->vel, mass->acc);
            
        } else break;
    }
    
    dsmsResolveObjectToPlaneCollisions(space);
}

#pragma mark Mass management

void dsmsSpaceAddMass(DSSMSimSpace *space, DSSMSimMass *mass) {
    
    for (DSSMSimMass **p = space->masses; p < space->masses_end; p++) {
        
        assert(*p != mass);
        
        if (!*p) {
            
            *p = mass;
            space->number_of_masses++;
            
            // Initialise the mass' contents
            mass->pos = (GLKVector2) { 0, 0 };
            mass->vel = (GLKVector2) { 0, 0 };
            mass->acc = (GLKVector2) { 0, 0 };
            mass->frc = (GLKVector2) { 0, 0 };
            
            mass->e = 1.0;
            mass->mass = 1.0;
            mass->radius = 0.5;
            
            mass->collision_mask = 0;
            mass->collision_type = 0;
            
            mass->user_data = 0;
            
            break;
        }
    }
}

void dsmsSpaceRemMass(DSSMSimSpace *space, DSSMSimMass *mass) {
    
    int mass_found = 0;
    
    for (DSSMSimMass **p = space->masses; p < space->masses_end; p++) {
        
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

#pragma mark Spring management

void dsmsSpaceAddSpring(DSSMSimSpace *space, DSSMSimSpring *spring) {
    
    for (DSSMSimSpring **p = space->springs; p < space->springs_end; p++) {
        
        assert(*p != spring);
        
        if (!*p) {
            
            *p = spring;
            space->number_of_springs++;
            
            spring->k = 1.0;
            spring->l = 1.0;
            spring->f = 0.0;
            spring->mass1 = 0;
            spring->mass2 = 0;
            
            break;
        }
    }
}

void dsmsSpaceRemSpring(DSSMSimSpace *space, DSSMSimSpring *spring) {
    
    int spring_found = 0;
    
    for (DSSMSimSpring **s = space->springs; s < space->springs_end; s++) {
        
        if (*s == spring) {
            
            // Remove the spring if we find it
            assert(!spring_found && space->number_of_springs > 0);
            
            *s = 0;
            space->number_of_springs--;
            spring_found = 1;
            
        } else if (spring_found) {
            
            // Compact the array
            *(s - 1) = *s;
            *s = 0;
        }
    }
    
    assert(spring_found);
}

#pragma mark Plane management

void dsmsSpaceAddPlane(DSSMSimSpace *space, DSSMSimPlane *plane) {
    
    for (DSSMSimPlane **p = space->planes; p < space->planes_end; p++) {
        
        assert(*p != plane);
        
        if (!*p) {
            
            *p = plane;
            space->number_of_planes++;
            break;
        }
    }
}

void dsmsSpaceRemPlane(DSSMSimSpace *space, DSSMSimPlane *plane) {
    
    int plane_found = 0;
    
    for (DSSMSimPlane **p = space->planes; p < space->planes_end; p++) {
        
        if (*p == plane) {
            
            // Remove the plane if we find it
            assert(!plane_found);
            
            *p = 0;
            space->number_of_planes--;
            plane_found = 1;
            
        } else if (plane_found) {
            
            // Compact the array
            *(p - 1) = *p;
            *p = 0;
        }
    }
    
    assert(plane_found);
}
