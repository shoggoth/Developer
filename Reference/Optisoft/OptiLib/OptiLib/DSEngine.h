//
//  DSEngine.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSTime.h"
#import "DSRenderer.h"


//
//  interface DSEngineContext
//
//  An engine execution context
//

@protocol DSEngineNode;

@interface DSEngineContext : NSObject

// Node handling
- (void)addEngineNode:(id)node;
- (void)removeEngineNode:(id)node;

// Timing
@property(nonatomic, readonly) DSTime delta;    // Last delta time received from the engine.
@property(nonatomic, readonly) DSTime aTime;    // Accumulated engine deltas.

@end

//
//  interface DSEngine
//
//  An engine. Just needs a tick.
//

@protocol DSEngineDelegate;

@interface DSEngine : NSObject

// Engine timing
@property(nonatomic) DSTime simulatorTickRate;
@property(nonatomic) DSTime deltaClipTime;

// Current engine context and renderer
@property(nonatomic, strong) DSEngineContext *context;
@property(nonatomic, strong) id <DSRenderer> renderer;

// Delegate
@property(nonatomic, weak) id <DSEngineDelegate> delegate;

- (void)tick;

@end

//
//  DSEngineDelegate protocol
//
//  Minimal interface to the task the engine will run.
//

@protocol DSEngineDelegate <NSObject>

// Periodic update for this engine task
- (BOOL)engine:(DSEngine *)e willTickWithDelta:(DSTime)delta;
- (void)engine:(DSEngine *)e didTickWithDelta:(DSTime)delta;

@end

//
//  protocol DSEngineNode
//
//  TODO: document this
//

@class DSDrawContext;

@protocol DSEngineNode <NSObject>

@optional
// Notifications from the engine context
- (void)willAddToEngineContext:(DSEngineContext *)context;
- (void)didAddToEngineContext:(DSEngineContext *)context;

- (void)willRemoveFromEngineContext:(DSEngineContext *)context;
- (void)didRemoveFromEngineContext:(DSEngineContext *)context;

// Periodic
- (void)tick;
- (void)sync;
- (void)step;
- (void)interpolate:(float)alpha;

@end
