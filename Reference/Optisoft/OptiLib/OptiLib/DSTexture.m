//
//  DSTexture.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSTexture.h"


#pragma mark Texture

@implementation DSTexture

- (instancetype)initWithWidth:(GLsizei)width height:(GLsizei)height textureUnit:(GLenum)textureUnit options:(NSDictionary *)options {

    if ((self = [super init])) {

        // Create the texture object
        glGenTextures(1, &_object);

        // Set up object internals
        _target = GL_TEXTURE_2D;
        _unit = textureUnit;

        const GLint     levelOfDetail = 0;
        const GLint     border = 0;
        GLvoid          *pixels;

        // Generate pixels if we have been supplied with a pixel generation function.
        void (^pixelProc)(GLsizei w, GLsizei h, GLvoid *pixels) = [options valueForKey:@"kDSTextureFillSetupBlock"];
        if (pixelProc) {

            pixels = malloc(width * height * 4);
            if (pixels) pixelProc(width, height, pixels);

        } else pixels = 0;

        // Assign an empty image to the texture
        glActiveTexture(GL_TEXTURE0 + textureUnit);
        glBindTexture(_target, _object);

        // Optional texture setup block or defaults
        [self applyTextureOptions:options];

        // Create the texture
        glTexImage2D(_target, levelOfDetail, GL_RGBA, width, height, border, GL_RGBA, GL_UNSIGNED_BYTE, pixels);

        // Label it for debugging
#if defined (DEBUG)
        char string[255];
        snprintf(string, 255, "o%d u%d Proc %d x %d", _object, textureUnit, width, height);
        glLabelObjectEXT(GL_TEXTURE, _object, 0, string);
#endif
        // Reset texture state
        glBindTexture(GL_TEXTURE_2D, 0);
        glActiveTexture(GL_TEXTURE0);
        
        if (pixels) free(pixels);
    }
    
    return self;
}

- (instancetype)initWithImageFileName:(NSString *)imageFileName textureUnit:(GLenum)textureUnit options:(NSDictionary *)options {

    if ((self = [super init])) {

        NSError         *err;

        // Load the specified image file into the texture unit we selected.
        glActiveTexture(GL_TEXTURE0 + textureUnit);

        GLKTextureInfo *texture = [GLKTextureLoader textureWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageFileName ofType:nil] options:@{ GLKTextureLoaderOriginBottomLeft : @YES } error:&err];
        glBindTexture(GL_TEXTURE_2D, texture.name);

        // Apply texturing options
        if (options && texture.name) {

            [self applyTextureOptions:options];
        }

        // Label it for debugging
#if defined (DEBUG)
        char string[255];
        snprintf(string, 255, "o%d u%d File %s", _object, textureUnit, [imageFileName cStringUsingEncoding:NSUTF8StringEncoding]);
        glLabelObjectEXT(GL_TEXTURE, _object, 0, string);
#endif
        // Reset texture state
        glBindTexture(GL_TEXTURE_2D, 0);
        glActiveTexture(GL_TEXTURE0);

        // Set up object internals
        _target = GL_TEXTURE_2D;
        _object = texture.name;
        _unit = textureUnit;
    }

    return self;
}

- (void)dealloc {

    glDeleteTextures(1, &_object);
}

#pragma mark Setup

- (void)applyTextureOptions:(NSDictionary *)options {

    // Optional texture setup block or defaults
    void (^textureSetupProc)() = [options valueForKey:@"kDSTextureParamSetupBlock"];
    if (textureSetupProc) textureSetupProc();

    else {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    }

}
@end

#pragma mark - Texture bind

@implementation DSTextureBind

+ (instancetype)bindToTexture:(DSTexture *)texture name:(NSString *)name {

    DSTextureBind *bind = [DSTextureBind new];

    bind.texture = texture;
    bind.name = name;

    return bind;
}

#pragma mark Drawing

- (void)drawInContext:(DSDrawContext *)context {

    if (self.scene) {

        // Exisiting texture in draw context GET!
        DSTexture *previousTexture = [context textureWithName:_name];

        // Bind the texture for drawing
        if (previousTexture != _texture) [context bindTexture:_texture toName:_name];

        [self.scene drawInContext:context];

        // Rebind the old Texture
        if (previousTexture && previousTexture != _texture) [context bindTexture:previousTexture toName:_name];
        else [context unbindTextureWithName:_name];
    }

    [self.chain drawInContext:context];
}

@end