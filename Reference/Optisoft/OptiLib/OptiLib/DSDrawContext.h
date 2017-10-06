//
//  DSDrawContext.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

@import GLKit;
@import OpenGLES;


//
//  interface DSDrawContext
//
//  Standard GL ES drawing context.
//

@class DSTexture;
@class DSShader;

typedef enum { kDSCullNoFaces, kDSCullBackFaces, kDSCullFrontFaces, kDSCullFrontAndBackFaces } DSCullType;

@interface DSDrawContext : NSObject

// Buffer attach
- (BOOL)attachToGLKView:(GLKView *)view;
- (BOOL)attachToCAEAGLLayer:(CAEAGLLayer *)layer depthBuffer:(BOOL)depthBuffer;

// Querying capabilities
- (BOOL)supportsExtension:(NSString *)extensionName;
- (void)dumpExtensions;

// Drawing operations
- (void)bind;
- (void)flush;
- (void)clearBuffers;

// Texturing
- (DSTexture *)textureWithName:(NSString *)textureName;

- (void)bindTexture:(DSTexture *)texture toName:(NSString *)textureName;
- (void)unbindTextureWithName:(NSString *)textureName;

// Frustum
- (void)recalculateViewFrustum;
- (BOOL)frustumContainsSphereAtPos:(GLKVector3)pos radius:(float)radius;

// Shader
@property(nonatomic, strong) DSShader *shader;

// Shader uniform control
@property(nonatomic) GLKMatrix4 colourMatrix;
@property(nonatomic) GLKMatrix3 normalMatrix;
@property(nonatomic) GLKMatrix4 textureMatrix;
@property(nonatomic) GLKMatrix4 transformMatrix;
@property(nonatomic) GLKMatrix4 projectionMatrix;

// Context information
@property(nonatomic, readonly) BOOL depthBuffer;
@property(nonatomic, readonly) float aspect;
@property(nonatomic, readonly) CGRect viewPortRect;

// Context control
@property(nonatomic) BOOL frustumCulling;
@property(nonatomic) BOOL depthTest;
@property(nonatomic) BOOL autoSetNormalMatrix;
@property(nonatomic) DSCullType culling;

@end


//
//  protocol DSDrawable
//
//  Protocol to be adopted by objects that want to do drawing
//

@protocol DSDrawable <NSObject>

- (void)drawInContext:(DSDrawContext *)context;

@end
