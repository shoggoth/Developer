//
//  DSGenerator.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSActor.h"


//
//  protocol DSActorGeneratorDelegate
//
//  Delegate for the actor generator object.
//

@class DSActorGenerator;

@protocol DSActorGeneratorDelegate <NSObject>

- (void)generator:(DSActorGenerator *)generator didGenerateActor:(id)actor;
- (void)generator:(DSActorGenerator *)generator didRecycleActor:(id)actor;

@optional
- (void)generator:(DSActorGenerator *)generator didActivateActor:(id)actor;
- (void)generator:(DSActorGenerator *)generator willDeactivateActor:(id)actor;

@end


//
//  interface DSActorGenerator
//
//  Generates an object of any class which adopts the DSActor protocol.
//
//  A DSActorFactory object is used to factor and recycle actor objects. When the
//  generator is released, the contents of the factory will also be released (and
//  removed from the engine context to which they belong).
//
//  As actors become active, they'll be added to their owning game state and as they
//  deactivate, they'll be removed. On receiving a tick message, the generator will
//  check which of the generated actors have become inactive and remove them from the
//  owning engine context.
//

@class DSEngineContext;

@interface DSActorGenerator : NSObject

@property(nonatomic, readonly) DSEngineContext *context;
@property(nonatomic, weak) NSObject <DSActorGeneratorDelegate> *delegate;

- (id)generateActorWithClassName:(NSString *)actorName setupBlock:(void(^)(id <DSActor>))setupBlock;

@end


//
//  interface DSActorGenerator
//
//  Generates an object of any class which adopts the DSActor protocol.
//

@interface DSActorTransformerDelegate : NSObject

@end
/*
#import "DSEngine.h"



@class DSActorGenerator;

@protocol DSActorGeneratorDelegate <NSObject>

- (void)generator:(DSActorGenerator *)generator didGenerateActor:(id)actor;
- (void)generator:(DSActorGenerator *)generator didRecycleActor:(id)actor;

@optional
- (void)generator:(DSActorGenerator *)generator didActivateActor:(id)actor;
- (void)generator:(DSActorGenerator *)generator willDeactivateActor:(id)actor;

@end

//
//  interface DSActorGenerator
//
//  Generates an object of any class which adopts the DSActor protocol.
//  
//  A DSActorFactory object is used to factor and recycle actor objects. When the
//  generator is released, the contents of the factory will also be released (and
//  removed from the engine context to which they belong).
//  
//  As actors become active, they'll be added to their owning game state and as they
//  deactivate, they'll be removed. On receiving a tick message, the generator will
//  check which of the generated actors have become inactive and remove them from the
//  owning engine context.
//

@protocol DSTransformStore;

@class DSActorFactory;

@interface DSActorGenerator : NSObject {

@private
    DSActorFactory                          *factory;
    NSMutableArray                          *activationArray;
    
    // Properties
    NSObject <DSTransformStore>             *transformStore;
    NSObject <DSActorGeneratorDelegate>     *delegate;
}


- (id)generateActorWithClass:(NSString *)actorName addToContext:(DSEngineContext *)context;

- (void)deactivateAllActors;

@property(nonatomic, strong) NSObject <DSTransformStore> *transformStore;
@property(nonatomic) NSObject <DSActorGeneratorDelegate> *delegate;

@end
 
 
 */
