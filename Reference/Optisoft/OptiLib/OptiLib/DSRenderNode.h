//
//  DSRenderNode.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSDrawContext.h"
#import "DSTransform.h"


//
//  interface DSRenderNode
//
//  Renders the scene that is set as its property.
//  Drawing of the scene can be turned on or off.
//  This base node can be used to alter the order of drawing in the scene graph.
//
//  Note that the properties retain their children (scene) and siblings (chain) so be
//  careful to avoid circular references if using a graph rather than just a simple tree.
//

@interface DSRenderNode : NSObject <DSDrawable> {

    // Subclasses will undoubtedly want to use these directly
    NSObject <DSDrawable> *scene;
}

- (instancetype)initWithScene:(NSObject <DSDrawable> *)scene;

@property(nonatomic, strong) NSObject <DSDrawable> *scene;

@property(nonatomic) BOOL on;

@end


//
//  interface DSBinaryRenderNode
//
//  Binary tree style scene graph draw node. Has one scene and one chain attachment.
//  The scene is drawn first and the chain after.
//  This base node can be used to alter the order of drawing in the scene graph.
//
//  Note that the properties retain their children (scene) and siblings (chain) so be
//  careful to avoid circular references if using a graph rather than just a simple tree.
//

@interface DSBinaryRenderNode : NSObject <DSDrawable> {

    // Subclasses will undoubtedly want to use these directly
    NSObject <DSDrawable> *scene;
    NSObject <DSDrawable> *chain;
}

- (instancetype)initWithScene:(NSObject <DSDrawable> *)scene chain:(NSObject <DSDrawable> *)chain;

@property(nonatomic, strong) NSObject <DSDrawable> *scene;
@property(nonatomic, strong) NSObject <DSDrawable> *chain;

@end


//
//  interface DSProgrammableRenderNode
//
//  Base scene graph draw node. Has one scene and one chain attachment.
//

@interface DSProgrammableRenderNode : NSObject <DSDrawable>

@property(nonatomic, copy) void (^drawBlock)(DSDrawContext *context);

@end


//
//  interface DSTransformNode
//
//  Applies the specified transformation to the child.
//  After the child is drawn, the previous transform is restored and the group is drawn.
//  The transform specified here and the previous transform are multiplied together.
//

@interface DSTransformNode : DSBinaryRenderNode

- (instancetype)initWithTransform:(DSTransform *)transform;

@property(nonatomic, strong) DSTransform *transform;
@property(nonatomic) float cullRadius;

@end


//
//  interface DSDrawArrayNode
//
//  Convenience container for grouping drawn objects.
//
//  This node just performs an iteration of the objects it contains.
//  Contained objects must adopt the DSDrawable protocol. The intent is just to save stack
//  space for objects that need to be drawn but don't need dependencies.
//

@interface DSDrawArrayNode : NSObject <DSDrawable>

- (void)addDrawable:(NSObject <DSDrawable> *)d;
- (void)remDrawable:(NSObject <DSDrawable> *)d;


@end


//
//  interface DSMultiDrawNode
//
//  Draws the child multiple times at the specified transforms.
//

@interface DSMultiDrawNode : DSBinaryRenderNode <DSTransformStore> {

    NSMutableArray          *transformArray;
}

@end
