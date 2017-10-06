//
//  DSActor.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSTransform.h"


//
//  protocol DSActor
//
//  This protocol describes the most basic type of actor.
//  
//  It has no positional data, it just exists as an entity in itself. All actors
//  must adopt this protocol and signify if they are active or not using the 'active'
//  property. This is mainly for use with factory objects which will recycle inactive
//  actor objects for later use as they are required.
//

@protocol DSActor <NSObject>

@property(nonatomic, assign) BOOL active;

@end


//
//  protocol DSTransformActor
//
//  This protocol describes an actor that has a position in some arbitrary space.
//  
//  The 'transform' property specifies this position and may be any of the subclasses
//  of DSTransform. This transform is usually used by a transform draw node (or one
//  of its subclasses) to draw the actor's avatar at some position.
//

@class DSTransform;

@protocol DSTransformActor <DSActor>

@property(nonatomic, readonly) DSTransform *transform;

- (void)insertIntoTransformStore:(id <DSTransformStore>) transformStore;
- (void)removeFromTransformStore:(id <DSTransformStore>) transformStore;

@end


//
//  protocol DSDynamicActor
//
//  This protocol describes an actor that is positional and can be moved around.
//  
//  Actors adopting this protocol usually get their dynamics from a simulator. The
//  simulator is usually some subclass of DSSimulator.
//  
//  The actor's 'sync' method should synchronise the actor's representation in the 
//  simulation with the transform it presents via the exposed DSTransform. It's also
//  the responsibility of actors adopting this protocol to provide appropriate instructions
//  to the simulator when asked to move or face towards some vector direction.
//  
//  Be aware of concurrency issues when setting movement parameters. It may be best to store
//  a pair of local vectors within the actor object that can be used to affect dynamics at
//  'sync' time.
//

@protocol DSDynamicActor <DSTransformActor>

- (void)moveTowards:(GLKVector3)destination;
- (void)faceTowards:(GLKVector3)destination;

- (void)sync;

@end


//
//  protocol DSSpriteActor
//
//  This protocol describes a 'sprite' actor.
//  
//  Although intended for use with sprites, there is no reason why objects adopting this 
//  protocol couldn't be used for other operations which require a pair of transformations.
//  
//  Usually, the 'frameTransform' property will describe a transformation in texture space
//  so that animating sprites can be produced. In our OpenGL implementation of sprites, a mesh
//  (possibly just a 1 * 1 mesh or quad) with texture coordinates. See 'Sprite.h' for sprite
//  animation possibilities.
//

@protocol DSSpriteActor <DSTransformActor>

@property(nonatomic, readonly) DSTransform *frameTransform;

@end
