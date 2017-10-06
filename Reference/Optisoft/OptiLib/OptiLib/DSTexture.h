//
//  DSTexture.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSRenderNode.h"


@interface DSTexture : NSObject

- (instancetype)initWithWidth:(GLsizei)width height:(GLsizei)height textureUnit:(GLenum)textureUnit options:(NSDictionary *)options;
- (instancetype)initWithImageFileName:(NSString *)imageFileName textureUnit:(GLenum)textureUnit options:(NSDictionary *)options;

@property(nonatomic, readonly) GLenum target;
@property(nonatomic, readonly) GLuint object;
@property(nonatomic) GLenum unit;

@end


@interface DSTextureBind : DSBinaryRenderNode

+ (instancetype)bindToTexture:(DSTexture *)texture name:(NSString *)name;

@property(nonatomic, strong) DSTexture *texture;
@property(nonatomic, copy)   NSString  *name;

@end