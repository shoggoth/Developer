//
//  DSView.h
//  Dogstar Engine 2011 (Unified)
//
//  Created by Richard Henry on 16/09/2011.
//  Copyright (c) 2011 Dogstar Diversions. All rights reserved.
//


//
//  DSView protocol
//
//  TODO: document this
//

@protocol DSDrawable;
@protocol DSViewDelegate;

@class DSDrawContext;

@protocol DSView

// Rendering control
- (void)render:(CADisplayLink *)link;

// Required properties
@property(nonatomic, readonly) DSDrawContext *context;
@property(nonatomic, weak) IBOutlet NSObject <DSViewDelegate> *delegate;

@end


//
//  DSView interface
//
//  Standard Dogstar view for OpenGL ES rendering (multi-version)
//  Creates a DSESDrawContext context for rendering OpenGL ES and uses Displaylink to refresh
//

@interface DSView : UIView <DSView>

@property(nonatomic) BOOL depthBuffer;

@end


//
//  DSViewDelegate protocol
//
//  TODO: document this
//

@protocol DSViewDelegate

// Rendering control
- (void)view:(DSView *)view willPrepareDrawContext:(DSDrawContext *)drawContext;
- (BOOL)view:(DSView *)view didPrepareDrawContext:(DSDrawContext *)drawContext;

// Rendering
- (void)view:(DSView *)view willRenderToContext:(DSDrawContext *)drawContext;

@end
