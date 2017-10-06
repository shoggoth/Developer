//
//  DSParticleSystem.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSVertexBuffer.h"


//
//  struct DSParticleDrawInfo
//
//  Point sprite draw info for vertex source
//

typedef struct {
    
    GLKVector3          pos;
    unsigned char       r, g, b, a;
    
} DSParticleDrawInfo;

//
//  struct DSParticle
//
//  Particle properties in the system slist
//

typedef struct DSParticle {
    
    float               energy;
    float               decay;
    
    GLKVector3          pos;
    GLKVector3          vel;
    GLKVector3          acc;
    
    unsigned char       r, g, b;
    
    struct DSParticle   *next;
    
} DSParticle;


//
//  interface DSParticleSystem
//
//  Particle system with a single nozzle
//

@protocol DSNozzle;

@interface DSParticleSystem : NSObject <DSVertexSource> {

    // Particle control
    NSObject <DSNozzle>         *nozzle;
    
@private
    // Release parameters
    unsigned long               releaseRate;
    unsigned long               releaseInterval;
    
    // Internal state
    unsigned long               maxParticles;
    unsigned long               particleCount;
    unsigned long               particlePoolCount;
    int                         particleDrawCount;
    
    // Release timing
    unsigned long               releaseTicker;
    
    // Particle slists
    DSParticleDrawInfo          *points;                    // Pool of all particles that will be drawn at render time
    DSParticle                  *pool;                      // Pool of all particles available in the system. We'd like to avoid memory allocations except at initialisation time
    DSParticle                  *dead;                      // Slist of dead particles waiting for their turn to be recycled.
    DSParticle                  *live;                      // Slist of living particles.
}

- (id)initWithNozzle:(NSObject <DSNozzle> *)nozzle maxParticles:(unsigned long)maxParticles;

- (void)fire;

// Engine context
- (void)sync;
- (void)interpolate:(float)alpha;

// Particle control
@property(nonatomic) unsigned long releaseRate;
@property(nonatomic) unsigned long releaseInterval;

// Mesh specification
@property(nonatomic) unsigned mode;
@property(nonatomic, readonly) long vertexBufferSize;

@end


//
//  protocol DSNozzle
//
//  Set up a new particle
//


@protocol DSNozzle <NSObject>

- (void)setupParticle:(DSParticle *)newParticle;

@end


//
//  interface DSLinearNozzle
//
//  This nozzle ejects particles in a linear manner
//

@interface DSLinearNozzle : NSObject <DSNozzle> {
    
    GLKVector3                  ejectPos;
    GLKVector3                  ejectVel;
    GLKVector3                  ejectAcc;
    
    GLfloat                     decay;
}

@property(nonatomic) GLKVector3 ejectPos;
@property(nonatomic) GLKVector3 ejectVel;
@property(nonatomic) GLKVector3 ejectAcc;

@property(nonatomic) GLfloat decay;

@end


//
//  interface DSSpreadNozzle
//
//  This nozzle ejects particles in a linear manner with random spread
//

@interface DSSpreadNozzle : DSLinearNozzle

@property(nonatomic) GLfloat spread;

@end


//
//  interface DSSphereNozzle
//
//  This nozzle ejects particles in a spherical pattern
//

@interface DSSphereNozzle : NSObject <DSNozzle> {
    
    unsigned                    lats, divs;
    float                       vel, acc;
    
@private
    unsigned                    sphereIndex;
}

// Sphere latitude sections and division sections
@property(nonatomic) unsigned lats;
@property(nonatomic) unsigned divs;

// Sphere particle acceleration and initial velocity
@property(nonatomic) float vel;
@property(nonatomic) float acc;

@end


//
//  interface DSSquareNozzle
//
//  This nozzle ejects particles in a spherical pattern
//

@interface DSSquareNozzle : NSObject <DSNozzle> {
    
@private
    float                       size;
}

// Sphere latitude sections and division sections
@property(nonatomic) float size;

@end

//
//  interface DSRadialNozzle
//
//  This nozzle ejects particles in a spherical pattern
//

@interface DSRadialNozzle : NSObject <DSNozzle>

@end
