//
//  DSEngine.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSEngine.h"
#import "DSSimulator.h"

float oldPos, newPos, simPos;

@interface DSEngineContext ()

// Periodics
- (void)tick:(DSTime)delta;
- (void)sync;
- (void)simulate;
- (void)interpolate:(float)alpha;

@end

#pragma mark - Engine

@implementation DSEngine {

    // GCD private queues for update and simulation
    dispatch_queue_t        updateQueue;
    dispatch_queue_t        simulaQueue;

    // Timing and accumulators
    DSTime                  simulaTickAccumulator;
    DSTime                  simulatorBaseTime;
    DSTime                  interpolationTime;
}

- (instancetype)init {

    if ((self = [super init])) {

        // Property initialisation
        _deltaClipTime = 0.5 * kDSTimeToSeconds;

        // GCD update and simulation queues
        updateQueue = dispatch_queue_create("mobi.dogstar.update", NULL);
        simulaQueue = dispatch_queue_create("mobi.dogstar.simulate", NULL);

        _simulatorTickRate = 1 * kDSTimeToSeconds;

        [self reset];
    }

    return self;
}

- (void)dealloc {

    // Dispose of properties
    self.context  = nil;
    self.renderer = nil;

    // No longer need the queues
    updateQueue = nil;
    simulaQueue = nil;
}

#pragma mark Engine control

- (void)reset {

    // Reset timing to base configuration
    interpolationTime = kDSTimeZero;

    // Reset accumulators
    simulaTickAccumulator = _simulatorTickRate;
    simulatorBaseTime = -_simulatorTickRate;
}

#pragma mark Tick

- (void)tick {

    static DSTime   deltaBase;
    DSTime          timeNow = [DSTimer nanoTime];
    DSTime          delta = timeNow - deltaBase;

    // Handle delta clipping
    if (delta > _deltaClipTime) delta = _deltaClipTime;

    // Let the delegate know we're about to do the tick.
    if (!_delegate || [_delegate engine:self willTickWithDelta:delta]) {

        // Perform the engine tick
        [self tick:delta];

        // Let the delegate know that the engine has finished the tick.
        [_delegate engine:self didTickWithDelta:delta];
    }

    deltaBase = timeNow;
}

- (void)tick:(DSTime)delta {

    // Tick nodes in the context that need one
    [self.context tick:delta];

    // Sync and simulator tick (async)
    simulaTickAccumulator += delta;
    while (simulaTickAccumulator >= _simulatorTickRate) {

        simulaTickAccumulator -= _simulatorTickRate;
        simulatorBaseTime += _simulatorTickRate;

        // Sync operation dispatch (update queue)
        dispatch_async(updateQueue, ^{

            // Wait for the simulation queue to be empty
            dispatch_sync(simulaQueue, ^{});

            // Sync objects with their simulations
            [_context sync];

            // Do simulation asynchronously
            dispatch_async(simulaQueue, ^{ [_context simulate]; });
        });
    }

    // Prerender at this point (main thread)
    [_renderer prerender];

    // Interpolate operation dispatch (update queue)
    interpolationTime += delta;
    dispatch_sync(updateQueue, ^{

        // Interpolate all objects and signal that updates are finished
        [_context interpolate:(interpolationTime - simulatorBaseTime) / (double)_simulatorTickRate];
    });

    // Render at this point (main thread)
    [_renderer render];
}

@end

#pragma mark - Engine context

@implementation DSEngineContext {

    // Context content arrays
    NSMutableArray              *tick;
    NSMutableArray              *sync;
    NSMutableArray              *terp;
    NSMutableArray              *step;
}

- (instancetype)init {

    if ((self = [super init])) {

        // Array initialisation
        tick = [NSMutableArray array];
        sync = [NSMutableArray array];
        terp = [NSMutableArray array];
        step = [NSMutableArray array];
    }

    return self;
}

- (void)dealloc {

    // No longer need the arrays
    tick = nil;
    sync = nil;
    terp = nil;
    step = nil;
}

#pragma mark Context object handling

- (void)addEngineNode:(id <DSEngineNode>)node {

    // Pre-insert selector (if required)
    if ([node respondsToSelector:@selector(willAddToEngineContext:)])
        [node performSelector:@selector(willAddToEngineContext:) withObject:self];

    // Add to context arrays
    if ([node respondsToSelector:@selector(interpolate:)]) [terp addObject:node];
    if ([node respondsToSelector:@selector(tick)]) [tick addObject:node];
    if ([node respondsToSelector:@selector(sync)]) [sync addObject:node];
    if ([node respondsToSelector:@selector(step)]) [step addObject:node];

    // Give all simulators a chance to add this object
    for (DSSimulator *sim in step) [sim addSimulationNode:node];

    // Post-insert selector (if required)
    if ([node respondsToSelector:@selector(didAddToEngineContext:)])
        [node performSelector:@selector(didAddToEngineContext:) withObject:self];
}

- (void)removeEngineNode:(id <DSEngineNode>)node {

    // Pre-remove selector (if required)
    if ([node respondsToSelector:@selector(willRemoveFromEngineContext:)])
        [node performSelector:@selector(willRemoveFromEngineContext:) withObject:self];

    // Remove from context arrays
    if ([node respondsToSelector:@selector(interpolate:)]) [terp removeObject:node];
    if ([node respondsToSelector:@selector(tick)]) [tick removeObject:node];
    if ([node respondsToSelector:@selector(sync)]) [sync removeObject:node];
    if ([node respondsToSelector:@selector(step)]) [step removeObject:node];

    // Give all simulators a chance to remove this object
    for (DSSimulator *sim in step) [sim removeSimulationNode:node];

    // Post-remove selector (if required)
    if ([node respondsToSelector:@selector(didRemoveFromEngineContext:)])
        [node performSelector:@selector(didRemoveFromEngineContext:) withObject:self];
}

#pragma mark Periodics

- (void)tick:(DSTime)delta {

    // Update context timers so that they're in sync with the engine times.
    _delta = delta;
    _aTime += delta;

    // The tick is done sequentially. Also, use a copy of the tick array so that the objects can mutate it while they're ticking.
    for (id <DSEngineNode> node in [tick copy]) [node tick];
}

- (void)sync {

    // Dispatch sync operations in parallel to global queue
    dispatch_apply([sync count], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {

        [[sync objectAtIndex:i] sync];
    });
}

- (void)simulate {

    // Dispatch simulate operations in parallel to global queue
    dispatch_apply([step count], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {

        [[step objectAtIndex:i] step];
    });
}

- (void)interpolate:(float)alpha {

    // Dispatch interpolate operations in parallel to global queue
    dispatch_apply([terp count], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {

        [[terp objectAtIndex:i] interpolate:alpha];
    });
}

@end
