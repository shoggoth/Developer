//
//  DSRenderer.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSDrawContext.h"


//
//  interface DSRenderer
//
//  TODO: document this
//

@protocol DSRenderer <NSObject>

- (void)prerender;
- (void)render;

@property(nonatomic, strong) DSDrawContext *context;

@end


//
//  interface DSNodeRenderer
//
//  Base scene graph draw node. Has one scene and one chain attachment.
//  The scene is drawn first and the chain after.
//  This base node can be used to alter the order of drawing in the scene graph.
//
//  Note that the properties retain their children (scene) and siblings (chain) so be
//  careful to avoid circular references if using a graph rather than just a simple tree.
//

@interface DSNodeRenderer : NSObject <DSRenderer>

@property(nonatomic, strong) IBOutlet NSObject <DSDrawable> *scene;

@end


//
//  interface DSPingPongRenderer
//
//  Base scene graph draw node. Has one scene and one chain attachment.
//  The scene is drawn first and the chain after.
//  This base node can be used to alter the order of drawing in the scene graph.
//
//  Note that the properties retain their children (scene) and siblings (chain) so be
//  careful to avoid circular references if using a graph rather than just a simple tree.
//

@interface DSPingPongRenderer : NSObject <DSRenderer>

@property(nonatomic, strong) NSObject <DSDrawable> *scene;

@property(nonatomic, strong) NSObject <DSDrawable> *deform;
@property(nonatomic, strong) NSObject <DSDrawable> *screen;

- (void)createBuffersOfSize:(CGSize)textureSize;

@end
