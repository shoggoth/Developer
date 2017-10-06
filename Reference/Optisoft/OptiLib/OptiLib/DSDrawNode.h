//
//  DSDrawNode.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSDrawContext.h"
#import "DSTransform.h"


//
//  interface DSDrawNode
//
//  Base scene graph draw node. Has one child and one group attachment.
//  The child is drawn first and the group after.
//  This base node can be used to alter the order of drawing in the scene graph.
//  
//  Note that the properties retain their children and siblings (group) so be
//  careful to avoid circular references if using a graph rather than just a simple tree.
//

@interface DSDrawNode : NSObject <DSDrawable> {
    
    NSObject <DSDrawable>   *child;
    NSObject <DSDrawable>   *group;
}

@property(retain, nonatomic) NSObject <DSDrawable> *child;
@property(retain, nonatomic) NSObject <DSDrawable> *group;

@end


//
//  interface DSTransformNode
//
//  Applies the specified transformation to the child.
//  After the child is drawn, the previous transform is restored and the group is drawn.
//  The transform specified here and the previous transform are multiplied together.
//

@interface DSTransformNode : DSDrawNode {
    
    DSTransform             *transform;
    float                   cullRadius;
}

@property(retain, nonatomic) DSTransform *transform;
@property(assign, nonatomic) float cullRadius;

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

@interface DSDrawArrayNode : NSObject <DSDrawable> {
    
    NSMutableArray          *drawArray;
}

- (void)addDrawable:(NSObject <DSDrawable> *)d;
- (void)remDrawable:(NSObject <DSDrawable> *)d;

@end


//
//  interface DSMultiDrawNode
//
//  Draws the child multiple times at the specified transforms.
//

@interface DSMultiDrawNode : DSDrawNode <DSTransformStore> {
    
    NSMutableArray          *transformArray;
}

@end
