//
//  DSParticleSystem.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSParticleSystem.h"
#import "DSTime.h"
#import "DSShader.h"
#import "DSDrawContext.h"


@implementation DSParticleSystem

- (id)initWithNozzle:(NSObject <DSNozzle> *)noz maxParticles:(unsigned long)mp {
	
	if ((self = [super init])) {
		
		_mode = GL_DYNAMIC_DRAW;
		
		// General initialisation to safe values
		maxParticles = mp;
		releaseRate = 1;
		releaseInterval = 1;
		
		// Nozzle
		nozzle = noz;

        // Allocate some memory
		points = malloc(mp * sizeof(DSParticleDrawInfo));
		pool = malloc(mp * sizeof(DSParticle));
	}
	
	return self;
}

- (void)dealloc {

	free(pool);
	free(points);
}

- (void)fire { releaseTicker += releaseInterval; }

#pragma mark Initialisation

- (void)describeVerticesInContext:(DSDrawContext *)context {

    int            stride = sizeof(DSParticleDrawInfo);

    // VAO vertex position (always at location 0)
    GLint attributeLocation = [context.shader getAttributeLocation:@"position"];
    glEnableVertexAttribArray(attributeLocation);
    glVertexAttribPointer(attributeLocation, 3, GL_FLOAT, GL_FALSE, stride, 0);

    // VAO vertex colour
    attributeLocation = [context.shader getAttributeLocation:@"colour"];
    if (attributeLocation > 0) {
        glEnableVertexAttribArray(attributeLocation);
        glVertexAttribPointer(attributeLocation, 4, GL_UNSIGNED_BYTE, GL_TRUE, stride, glVBOBufferOffset(12));
    }
}

#pragma mark Drawing

- (void)drawVerticesInContext:(DSDrawContext *)context {

    // Draw the triangles (not indexed)
	glDrawArrays(GL_POINTS, 0, particleDrawCount);
}

#pragma mark Buffering

- (long)vertexBufferSize {
	
	return particleDrawCount * sizeof(DSParticleDrawInfo);
}

- (void)fillVertexBuffer:(void *)vboBuffer {
	
	memcpy(vboBuffer, points, particleDrawCount * sizeof(DSParticleDrawInfo));
}

#pragma mark Engine context

- (void)interpolate:(float)alpha {
	
	DSParticleDrawInfo	*d = points;
	
	particleDrawCount = 0;
	
	for (DSParticle *p = live; p; p = p->next) {
		
		d->pos = GLKVector3Add(p->pos, GLKVector3MultiplyScalar(p->vel, alpha));

		float pDecay = (p->energy - alpha * p->decay);
		
		d->a = (pDecay > 0.0f) ? pDecay * 255 : 0;
		d->r = p->r;
		d->g = p->g;
		d->b = p->b;
		
		d++;
		particleDrawCount++;
	}
}

- (void)sync {
	
	// Update live particles
	for (DSParticle **liveParticles = &live; *liveParticles;) {
		
		DSParticle	*particle = *liveParticles;
		
		// Particle decay
		particle->energy -= particle->decay;
		
		// If the particle's life is over, put it on the free list
		if (particle->energy <= 0.0f) {
			
			*liveParticles = particle->next;
			particle->next = dead;
			dead = particle;

			particleCount--;
			
		} else {
			
			// Update the particle. Euler integration will do here: nothing fancy needed.
			particle->pos = GLKVector3Add(particle->pos, particle->vel);
			particle->vel = GLKVector3Add(particle->vel, particle->acc);
			
			// Move on to the next particle
			liveParticles = &particle->next;
		}
	}
	
	// Check if it's time to release a new batch of particles
	if (++releaseTicker >= releaseInterval) {
		
		releaseTicker -= releaseInterval;
		
		// Release new particles
		for (unsigned i = 0; i < releaseRate; i++) {
			
			DSParticle		*newParticle;
			
			if (dead) {
				
				// Recycle a free particle if there's one available
				newParticle = dead;
				dead = newParticle->next;
				
			} else {
				
				// Check there are some particles left in the pool
				if (particlePoolCount == maxParticles) break;
				
				// Grab a new particle from the pool if there aren't any more free
				newParticle = &pool[particlePoolCount++];
			}
			
			// Set up the new particle
			[nozzle setupParticle:newParticle];
			
			// Place the new particle in the active list
			newParticle->next = live;
			live = newParticle;
			
			particleCount++;
		}
	}
}

#pragma mark Properties

@synthesize releaseRate;
@synthesize releaseInterval;

@end


#pragma mark - Nozzles

@implementation DSLinearNozzle

- (id)init {
	
	if ((self = [super init])) {
		
		ejectPos = (GLKVector3) { 0.0f, 0.0f, 0.0f };
		ejectVel = (GLKVector3) { 0.0f, 0.0f, 0.0f };
		ejectAcc = (GLKVector3) { 0.0f, 0.0f, 0.0f };
		
		decay = 0.01f;
	}
	
	return self;
}

- (void)setupParticle:(DSParticle *)newParticle {
	
	newParticle->pos = ejectPos;
	newParticle->vel = ejectVel;
	newParticle->acc = ejectAcc;
	
	newParticle->energy = 1.0f;
	newParticle->decay =  decay;
	
	newParticle->r = rand() % 255;
	newParticle->g = rand() % 255;
	newParticle->b = rand() % 255;
}

@synthesize ejectPos;
@synthesize ejectVel;
@synthesize ejectAcc;

@synthesize decay;

@end


@implementation DSSpreadNozzle

- (id)init {
	
	if ((self = [super init])) {
		
		_spread = 0.0f;
	}
	
	return self;
}

- (void)setupParticle:(DSParticle *)newParticle {
	
	newParticle->pos = ejectPos;
	newParticle->vel = ejectVel;
	newParticle->acc = ejectAcc;
	
	newParticle->energy = 1.0f;
	newParticle->decay =  decay;
	
	newParticle->r = rand() % 255;
	newParticle->g = rand() % 255;
	newParticle->b = rand() % 255;
	
	newParticle->vel = GLKVector3Add(newParticle->vel, GLKVector3MultiplyScalar(GLKVector3Normalize((GLKVector3) { ((rand() % 2000) - 1000) * 0.001f, ((rand() % 2000) - 1000) * 0.001f, ((rand() % 2000) - 1000) * 0.001f}), _spread));
}

@end


@implementation DSSphereNozzle

- (id)init {
	
	if ((self = [super init])) {
		
		lats = divs = 1;
		sphereIndex = 0;
	}
	
	return self;
}

- (void)setupParticle:(DSParticle *)newParticle {
	
	float size = 1.0f;
	
	if (!sphereIndex) {
		
		newParticle->pos = (GLKVector3) { 0.0f, size, 0.0f };
	
	} else if (sphereIndex == lats * divs + 1) {
		
		newParticle->pos = (GLKVector3) { 0.0f, -size, 0.0f };
	
	} else {
		
		float latSpacing = (2 * size) / (lats + 1);
		float latPosition = size - latSpacing;
		float divSpacing = M_PI * 2.0f / divs;
		
		unsigned y = (sphereIndex - 1) / divs;
		unsigned x = (sphereIndex - 1) % divs;
		
		latPosition -= y * latSpacing;
		float radius = sqrtf(size * size - latPosition * latPosition); // XZ plane radius
		float divAngle = x * divSpacing;
		
		newParticle->pos = (GLKVector3) { radius * sinf(divAngle), latPosition, radius * cosf(divAngle)};
	}
	
	sphereIndex = ++sphereIndex % (lats * divs + 2);
	
	newParticle->energy = 1.0f;
	newParticle->decay =  0.01f;
	
	newParticle->r = 255;
	newParticle->g = 255;
	newParticle->b = 255;

	newParticle->acc = GLKVector3MultiplyScalar(GLKVector3Normalize(newParticle->pos), acc);
	newParticle->vel = GLKVector3MultiplyScalar(GLKVector3Normalize(newParticle->pos), vel);
}

@synthesize lats;
@synthesize divs;

@synthesize vel;
@synthesize acc;

@end


@implementation DSSquareNozzle

- (id)init {
	
	if ((self = [super init])) {
		
		size = 1.0f;
	}
	
	return self;
}

- (void)setupParticle:(DSParticle *)newParticle {
	
    float px = ((rand() % 1024) - 512) / 512.0f * size;
    float py = ((rand() % 1024) - 512) / 512.0f * size;
    
    float vz = (rand() % 512) / 512.0f;
    
	newParticle->pos = (GLKVector3) { px, py, 0.0f };
	newParticle->vel = (GLKVector3) { 0.0f, 0.0f, vz };
	newParticle->acc = (GLKVector3) { 0.0f, 0.0f, 0.0f };
	
	newParticle->energy = 1.0f;
	newParticle->decay =  0.01f;
	
	newParticle->r = rand() % 255;
	newParticle->g = rand() % 255;
	newParticle->b = rand() % 255;
}

@synthesize size;

@end


@implementation DSRadialNozzle

- (void)setupParticle:(DSParticle *)newParticle {
    
}

@end
