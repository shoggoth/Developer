//
//  DSRenderNode.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSRenderNode.h"
#import "DSMaths.h"


#pragma mark Render node

@implementation DSRenderNode

@synthesize scene;

- (instancetype)initWithScene:(NSObject <DSDrawable> *)s {

    if ((self = [self init])) {

        // Just set the members
        self.scene = s;
        self.on = (s != nil);
    }

    return self;
}

- (void)dealloc {

    // Clear this node's dependants further down the scene graph.
    self.scene = nil;
}

#pragma mark Drawing

- (void)drawInContext:(DSDrawContext *)context {

    // Just draw the scene if this node is turned on.
    if (self.on) [scene drawInContext:context];
}

@end

#pragma mark - Binary render node

@implementation DSBinaryRenderNode

@synthesize scene;
@synthesize chain;

- (instancetype)initWithScene:(NSObject <DSDrawable> *)s chain:(NSObject <DSDrawable> *)c {

    if ((self = [self init])) {

        // Just set the members
        self.scene = s;
        self.chain = c;
    }

    return self;
}

- (void)dealloc {

    // Clear this node's dependants further down the scene graph.
    self.scene = nil;
    self.chain = nil;
}

#pragma mark Drawing

- (void)drawInContext:(DSDrawContext *)context {

    // Just draw the scene and the chain sequentially
    [scene drawInContext:context];
    [chain drawInContext:context];
}

@end

#pragma mark - Programmable node

@implementation DSProgrammableRenderNode

- (void)drawInContext:(DSDrawContext *)context {

    // Programable rendering
    if (self.drawBlock) self.drawBlock(context);
}

- (void)dealloc {

    self.drawBlock = nil;
}

@end

#pragma mark - Transformation node

@implementation DSTransformNode

- (instancetype)initWithTransform:(DSTransform *)transform {

    if ((self = [super init])) {

        // Initialisation
        self.transform = transform;
    }

    return self;
}

- (void)dealloc {

    self.transform = nil;
}

#pragma mark Drawing functions

- (void)drawInContext:(DSDrawContext *)context {

    if (scene) {

        // Get the context's current transform
        GLKMatrix4 oldTransform = context.transformMatrix;

        // Get this node's transform
        GLKMatrix4 ourTransform = _transform.transformMatrix;

        // Check if this transform needs to be culled
        if (!context.frustumCulling || _cullRadius == 0.0 || [context frustumContainsSphereAtPos:DSMatrix4GetTranslate(ourTransform) radius:_cullRadius]) {

            // Multiply by our node's transform
            context.transformMatrix = GLKMatrix4Multiply(oldTransform, ourTransform);

            // Draw the children of this node with the transform applied
            [scene drawInContext:context];

            // Restore the previous transform
            context.transformMatrix = oldTransform;
        }
    }

    // Draw the group (not affected by this transform)
    [chain drawInContext:context];
}

@end

#pragma mark - Multi-draw node

@implementation DSMultiDrawNode

- (instancetype)init {

    if ((self = [super init])) {

        transformArray = [NSMutableArray new];
        assert(transformArray);
    }

    return self;
}

- (void)dealloc {

    transformArray = nil;
}

#pragma mark Drawing functions

- (void)drawInContext:(DSDrawContext *)context {

    if (scene) {

        // Get the context's current transform
        GLKMatrix4 oldTransform = context.transformMatrix;

        for (DSTransform *transform in transformArray) {

            // Multiply by the new transform
            GLKMatrix4 newTransform = transform.transformMatrix;
            context.transformMatrix = GLKMatrix4Multiply(oldTransform, newTransform);

            // Draw the children of this node with the transform applied
            [scene drawInContext:context];
        }

        // Restore the previous transform
        context.transformMatrix = oldTransform;
    }

    // Draw the group (not affected by this transform)
    [chain drawInContext:context];
}

#pragma mark Transform storage

- (void)addTransform:(DSTransform *)d {

    [transformArray addObject:d];
}

- (void)remTransform:(DSTransform *)d {

    [transformArray removeObject:d];
}

#pragma mark Object description

- (NSString*)description {

    return [NSString stringWithFormat:@"<%@: 0x%x | array: %@>", [self class], (unsigned)self, transformArray];
}

@end

#pragma mark - Array draw node

@implementation DSDrawArrayNode {

    NSMutableArray          *drawArray;
}

- (instancetype)init {

    if ((self = [super init])) {

        drawArray = [NSMutableArray array];
        assert(drawArray);
    }

    return self;
}

- (void)dealloc {

    drawArray = nil;
}

#pragma mark Drawing functions

- (void)drawInContext:(DSDrawContext *)context {

    [drawArray makeObjectsPerformSelector:@selector(drawInContext:) withObject:context];
}

#pragma mark Drawable object storage

- (void)addDrawable:(NSObject <DSDrawable> *)d {

    [drawArray addObject:d];
}

- (void)remDrawable:(NSObject <DSDrawable> *)d {

    [drawArray removeObject:d];
}

#pragma mark Object description

- (NSString*)description {

    return [NSString stringWithFormat:@"<%@: 0x%x | array: %@>", [self class], (unsigned)self, drawArray];
}

@end
