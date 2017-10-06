//
//  DSGenerator.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSGenerator.h"
#import "DSEngine.h"
#import "DSFactory.h"
#import "DSActor.h"


@implementation DSActorGenerator {

    DSFactory           *factory;
}

- (instancetype)init {

    if ((self = [super init])) {

        factory = [DSFactory new];
    }

    return self;
}

#pragma mark Generation

- (id)generateActorWithClassName:(NSString *)actorName setupBlock:(void(^)(id <DSActor>))setupBlock {

    // Get the factory to give us a new or recycled actor of the specified class
    NSObject <DSActor> *actor = [factory supplyObjectOfClassNamed:actorName];

    // Check the new actor (debug)
    assert([[actor class] conformsToProtocol:@protocol(DSActor)]);

    // Inform the delegate a new actor has been generated
    [_delegate generator:self didGenerateActor:actor];

    // Activate the new actor
    [self activateActor:actor];

    // Call the Actor's setup block
    if (setupBlock) setupBlock(actor);

    return actor;
}

#pragma mark Actor control

- (void)activateActor:(NSObject <DSActor> *)actor {

    // Add actor to the engine context
    [self.context addEngineNode:actor];

    actor.active = YES;

    // Inform the delegate a new actor has been generated (optional)
    if ([_delegate respondsToSelector:@selector(generator:didActivateActor:)]) [_delegate generator:self didActivateActor:actor];
}

- (void)deactivateActor:(NSObject <DSActor> *)actor {

    // Inform the delegate an actor is about to be deactivated (optional)
    if ([_delegate respondsToSelector:@selector(generator:willDeactivateActor:)]) [_delegate generator:self willDeactivateActor:actor];

    // Remove actor from the engine context
    [self.context removeEngineNode:actor];

    // Recycle the actor for later re-use
    [factory recycle:actor];

    // Inform the delegate an actor has been recycled
    [_delegate generator:self didRecycleActor:actor];
}

- (void)markAllActorsAsInactive {

    // Set active state on all actors to be NO so that they're deactivated next update
    [factory enumerateActiveObjectsUsingBlock:^(id <DSActor> actor, BOOL *stop) { actor.active = NO; }];
}

- (void)deactivateAllActors {

    // Set active state on all actors to be NO so that they're deactivated next update
    [factory enumerateActiveObjectsUsingBlock:^(id <DSActor> actor, BOOL *stop) { [self deactivateActor:actor]; }];
}

#pragma mark Periodic

- (void)tick {

    [factory enumerateActiveObjectsUsingBlock:^(id <DSActor> actor, BOOL *stop) {

        // Recycle all actors that are no longer marked as active
        if (!actor.active) [self deactivateActor:actor];
    }];
}

#pragma mark DSEngineNode conformance

- (void)willAddToEngineContext:(DSEngineContext *)ctx {

    _context = ctx;
}

- (void)willRemoveFromEngineContext:(DSEngineContext *)ctx {

    // Check that we aren't trying to remove this generator from a different context.
    assert(_context = ctx);

    [self deactivateAllActors];

    _context = nil;
}

@end

/*

#pragma mark Activation and deactivation

- (void)activateActor:(NSObject <DSActor> *)actor inEngineContext:(DSEngineContext *)context {
    
    // Add actor to the engine context
    [context addEngineObject:actor];
    
    // Add actor to the transform store if needed
    if (transformStore) {
        
        if ([actor respondsToSelector:@selector(insertIntoTransformStore:)]) {
            
            [actor performSelector:@selector(insertIntoTransformStore:) withObject:transformStore];
        }
    }
    
    actor.active = YES;
    
    // Inform the delegate a new actor has been generated (optional)
    if ([delegate respondsToSelector:@selector(generator:didActivateActor:)]) [delegate generator:self didActivateActor:actor];
}

- (void)deactivateActor:(NSObject <DSActor> *)actor inEngineContext:(DSEngineContext *)context {
    
    // Inform the delegate an actor is about to be deactivated (optional)
    if ([delegate respondsToSelector:@selector(generator:willDeactivateActor:)]) [delegate generator:self willDeactivateActor:actor];
    
    // Remove actor from the transform store if needed
    if (transformStore) {
        
        if ([actor respondsToSelector:@selector(removeFromTransformStore:)]) {
            
            [actor performSelector:@selector(removeFromTransformStore:) withObject:transformStore];
        }
    }
    
    // Remove actor from the engine context
    [context removeEngineObject:actor];
    
    actor.active = NO;
    
    // Recycle the actor for later re-use
    [factory recycle:actor];
    
    // Inform the delegate an actor has been recycled
    [delegate generator:self didRecycleActor:actor];
}

*/
