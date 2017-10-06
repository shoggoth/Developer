//
//  DSShader.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSRenderNode.h"


@interface DSShader : NSObject

// Designated initialisers
- (instancetype)initWithShaderFile:(NSString *)shaderName;
- (instancetype)initWithShaderFile:(NSString *)shaderName inBundle:(NSBundle *)bundle;

// Bind the shader into the current GL context
- (void)bind;
- (void)unbind;

// Access to attribute and uniform locations
- (int)getAttributeLocation:(const NSString *)attributeName;
- (int)getUniformLocation:(const NSString *)uniformName;

@end


@interface DSShaderBind : DSBinaryRenderNode

+ (instancetype)bindToShader:(DSShader *)shader;

@property(nonatomic, strong) DSShader *shader;

@end