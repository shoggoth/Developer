//
//  DSColour.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

@import GLKit;


//
//  interface DSColour
//
//  Describes a transformation in colour space.
//
//  This node depends on the current draw context's colour matrix.
//  Functionality may not be present in some versions of the GL.
//

@interface DSColour : NSObject {

    GLKVector4      colour;
}

- (instancetype)initWithColourVector:(GLKVector4)colour;

@property(nonatomic) GLKVector4 colour;

@end


//
//  protocol DSColourStore
//
//  Classes adopting this protocol must provide a mechanism
//  for adding to and removing transforms from an internal store.
//

@protocol DSColourStore <NSObject>

- (void)addColour:(DSColour *)colour;
- (void)remColour:(DSColour *)colour;

@end

// Convenience colour definitions
extern GLKVector4 DSClearColour;
extern GLKVector4 DSBlackColour;
extern GLKVector4 DSWhiteColour;


// Convenience colour conversion functions
extern GLKVector3 DSConvertHSLToRGB(const GLKVector3 hsl);
extern GLKVector3 DSConvertRGBToHSL(const GLKVector3 rgb);