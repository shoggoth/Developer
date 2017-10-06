//
//  DSShader.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSShader.h"

// Shader support functions
static BOOL checkProgrammeLinked(GLuint shaderObject);          // Check that the specified programme linked correctly
static BOOL checkShaderCompiled(GLuint shaderObject);           // Check that the specified shader compiled correctly
static void showInfoLog(GLuint shaderObject);

#if defined(DEBUG)
static void dumpShaderSource(GLuint shaderObject);
#endif

#pragma mark - Shader

@implementation DSShader {

    NSString                    *shaderSource;                  // The GLSL source for the shader (unified)
    NSStringEncoding            encoding;                       // Shader encoding
    NSMutableDictionary         *cacheDictionary;               // Caching attribute and uniform dictionary;
    
    GLuint                      glProgObject;                   // The programme object
}

- (instancetype)initWithShaderFile:(NSString *)shaderName {
    
    return [self initWithShaderFile:shaderName inBundle:[NSBundle mainBundle]];
}

- (instancetype)initWithShaderFile:(NSString *)shaderName inBundle:(NSBundle *)bundle {
    
    if ((self = [super init])) {
        
        // Caching attribute dictionary
        cacheDictionary = [NSMutableDictionary new];
        assert(cacheDictionary);
        
        // Load vertex and fragment shader
        NSString *filePath = [bundle pathForResource:shaderName ofType:@"glsl"];
        
        shaderSource = [NSString stringWithContentsOfFile:filePath usedEncoding:&encoding error:NULL];
        assert(shaderSource);
    }
    
    // Construct the shader from the source file we just loaded
    [self compileAndLinkUnifiedShader];
    
    return self;
}

- (void)dealloc {
    
    if (glProgObject) glDeleteProgram(glProgObject);
}

#pragma mark Shader activation

- (void)bind { glUseProgram(glProgObject); }

- (void)unbind { glUseProgram(0); }

#pragma mark Attribute and uniform handling

- (GLint)getAttributeLocation:(const NSString *)attributeName {
    
    GLint       attributeLocation;
    NSNumber    *attribLocationNumber = [cacheDictionary objectForKey:attributeName];
    
    // Have we cached attribute location number in the dictionary already?
    if (attribLocationNumber) attributeLocation = [attribLocationNumber intValue];
    
    // No, so look it up and cache it
    else {
        
        attributeLocation = glGetAttribLocation(glProgObject, [attributeName cStringUsingEncoding:NSUTF8StringEncoding]);
        
        [cacheDictionary setObject:[NSNumber numberWithInt:attributeLocation] forKey:attributeName];
        
#if defined(DEBUG)
        if (attributeLocation == -1) NSLog( @"DSShader WARNING: No such attribute named \"%@\"", attributeName);
#endif
    }
    
    return attributeLocation;
}

- (GLint)getUniformLocation:(const NSString *)uniformName {
    
    GLint       uniformLocation;
    NSNumber    *uniformLocationNumber = [cacheDictionary objectForKey:uniformName];
    
    // Have we cached uniform location number in the dictionary already?
    if (uniformLocationNumber) uniformLocation = [uniformLocationNumber intValue];
    
    // No, so look it up and cache it
    else {
        
        uniformLocation = glGetUniformLocation(glProgObject, [uniformName cStringUsingEncoding:NSUTF8StringEncoding]);
        
        [cacheDictionary setObject:[NSNumber numberWithInt:uniformLocation] forKey:uniformName];
        
#if defined(DEBUG)
        if (uniformLocation == -1) NSLog( @"DSShader WARNING: No such uniform named \"%@\"", uniformName);
#endif
    }
    
    return uniformLocation;
}

#pragma mark Shader construction

- (void)compileAndLinkUnifiedShader {
    
    static const char *vertShaderConditional = "#define COMPILE_VERTEX_SHADER\n";
    static const char *fragShaderConditional = "#define COMPILE_FRAGMENT_SHADER\n";
    
    // Create shaders
    GLuint vertShaderObject = glCreateShader(GL_VERTEX_SHADER);
    GLuint fragShaderObject = glCreateShader(GL_FRAGMENT_SHADER);
    assert(vertShaderObject && fragShaderObject);
    
    // This is a unified shader so we use conditional compilation
    char const *compileParams[3];
    compileParams[0] = "#version 100\n";
    compileParams[2] = (GLchar *)[shaderSource cStringUsingEncoding:encoding];
    
    // Set up source for vertex shader
    compileParams[1] = vertShaderConditional;
    glShaderSource(vertShaderObject, 3, compileParams, NULL);
    
    // Set up source for fragment shader
    compileParams[1] = fragShaderConditional;
    glShaderSource(fragShaderObject, 3, compileParams, NULL);
    
    // Compile shaders
    glCompileShader(vertShaderObject);
    if (checkShaderCompiled(vertShaderObject)) {
        
        glCompileShader(fragShaderObject);
        if (checkShaderCompiled(fragShaderObject)) {
            
            // Create a programme object
            glProgObject = glCreateProgram();
            assert(glProgObject);
            
            // Attach the shaders
            glAttachShader(glProgObject, vertShaderObject);
            glDeleteShader(vertShaderObject);
            glAttachShader(glProgObject, fragShaderObject);
            glDeleteShader(fragShaderObject);
            
            // Bind attribute locations (needs to be done prior to linking)
            glBindAttribLocation(glProgObject, 0, "position");
            
            // Link the shader objects to the programme
            glLinkProgram(glProgObject);
            BOOL linkOK = checkProgrammeLinked(glProgObject);
            assert(linkOK);
        }
    }
    
    shaderSource = nil;
}

@end

#pragma mark - Shader check and debug

#if defined(DEBUG)

static void dumpShaderSource(GLuint shaderObject) {
    
    
    GLint length;
    
    glGetShaderiv(shaderObject, GL_SHADER_SOURCE_LENGTH, &length);
    
    char *source = malloc(length);
    
    glGetShaderSource(shaderObject, length, NULL, source);
    NSLog(@"Shader source:\n%s\n", source);
    free(source);
    
}
#endif

static BOOL checkShaderCompiled(GLuint shaderObject) {
    
    GLint status;
    
    glGetShaderiv(shaderObject, GL_COMPILE_STATUS, &status);
    
    if (!status) showInfoLog(shaderObject);
    
    return status;
}

static BOOL checkProgrammeLinked(GLuint shaderObject) {
    
    GLint status;
    
    glGetProgramiv(shaderObject, GL_LINK_STATUS, &status);
    
    if (!status) showInfoLog(shaderObject);
    
    return status;
}

static void showInfoLog(GLuint shaderObject) {
    
#if defined(DEBUG)
    
    GLint infoLogLength = 0;
    
    glGetShaderiv(shaderObject, GL_INFO_LOG_LENGTH, &infoLogLength);
    
    if (infoLogLength > 0) {
        
        GLchar *infoLog = (GLchar *)malloc(infoLogLength);
        
        if (infoLog) {
            
            glGetShaderInfoLog(shaderObject, infoLogLength, &infoLogLength, infoLog);
            NSLog(@"DSShader compile log:\n%s\n", infoLog);
            free(infoLog);
            
            dumpShaderSource(shaderObject);
        }
    }
#endif
}

#pragma mark - Shader bind

@implementation DSShaderBind

+ (instancetype)bindToShader:(DSShader *)shader {

    DSShaderBind *bind = [DSShaderBind new];

    bind.shader = shader;

    return bind;
}

#pragma mark Drawing

- (void)drawInContext:(DSDrawContext *)context {

    if (self.scene) {

        // Exisiting shader in draw context GET!
        DSShader *previousShader = context.shader;

        // Bind the shader for drawing
        if (previousShader != _shader) context.shader = _shader;

        [self.scene drawInContext:context];

        // Rebind the old Shader
        if (previousShader && previousShader != _shader) context.shader = previousShader;
    }
    
    [self.chain drawInContext:context];
}

@end

