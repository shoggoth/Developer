//
//  DSColour.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSColour.h"
#import "DSDrawContext.h"

GLKVector4 DSClearColour = { 0.0, 0.0, 0.0, 0.0 };
GLKVector4 DSBlackColour = { 0.0, 0.0, 0.0, 1.0 };
GLKVector4 DSWhiteColour = { 1.0, 1.0, 1.0, 1.0 };

GLKVector4 DSReferenceColour = { 0.2, 0.4, 0.8, 1.0 };


#pragma mark Colour object

@implementation DSColour

@synthesize colour;

- (instancetype)initWithColourVector:(GLKVector4)c {
    
    if ((self = [super init])) {
        
        // Object initialisation
        colour = c;
    }
    
    return self;
}

- (instancetype)init {
    
    return [self initWithColourVector:DSReferenceColour];
}

@end

#pragma mark Colour conversion

static void HSL2RGB(float h, float s, float l, float* outR, float* outG, float* outB);
static void RGB2HSL(float r, float g, float b, float* outH, float* outS, float* outL);

GLKVector3 DSConvertHSLToRGB(const GLKVector3 hsl) {

    GLKVector3 rgb;

    HSL2RGB(hsl.x, hsl.y, hsl.z, &rgb.r, &rgb.g, &rgb.b);

    return rgb;
}

GLKVector3 DSConvertRGBToHSL(const GLKVector3 rgb) {

    GLKVector3 hsl;

    RGB2HSL(rgb.r, rgb.g, rgb.b, &hsl.x, &hsl.y, &hsl.z);

    return hsl;
}

static void HSL2RGB(float h, float s, float l, float* outR, float* outG, float* outB) {

	float			temp1,
    temp2;
	float			temp[3];
	int				i;

	// Check for saturation. If there isn't any just return the luminance value for each, which results in gray.
	if (s == 0.0) {
		if (outR)
			*outR = l;
		if (outG)
			*outG = l;
		if (outB)
			*outB = l;
		return;
	}

	// Test for luminance and compute temporary values based on luminance and saturation
	if (l < 0.5)
		temp2 = l * (1.0 + s);
	else
		temp2 = l + s - l * s;
    temp1 = 2.0 * l - temp2;

	// Compute intermediate values based on hue
	temp[0] = h + 1.0 / 3.0;
	temp[1] = h;
	temp[2] = h - 1.0 / 3.0;

	for (i = 0; i < 3; ++i) {

		// Adjust the range
		if (temp[i] < 0.0)
			temp[i] += 1.0;
		if (temp[i] > 1.0)
			temp[i] -= 1.0;


		if (6.0 * temp[i] < 1.0)
			temp[i] = temp1 + (temp2 - temp1) * 6.0 * temp[i];
		else {
			if (2.0 * temp[i] < 1.0)
				temp[i] = temp2;
			else {
				if (3.0 * temp[i] < 2.0)
					temp[i] = temp1 + (temp2 - temp1) * ((2.0 / 3.0) - temp[i]) * 6.0;
				else
					temp[i] = temp1;
			}
		}
	}

	// Assign temporary values to R, G, B
	if (outR)
		*outR = temp[0];
	if (outG)
		*outG = temp[1];
	if (outB)
		*outB = temp[2];
}


static void RGB2HSL(float r, float g, float b, float* outH, float* outS, float* outL) {

    r = r/255.0f;
    g = g/255.0f;
    b = b/255.0f;


    float h,s, l, v, m, vm, r2, g2, b2;

    h = 0;
    s = 0;

    v = MAX(r, g);
    v = MAX(v, b);
    m = MIN(r, g);
    m = MIN(m, b);

    l = (m+v)/2.0f;

    if (l <= 0.0){
        if (outH)
			*outH = h;
		if (outS)
			*outS = s;
		if (outL)
			*outL = l;
        return;
    }

    vm = v - m;
    s = vm;

    if (s > 0.0f){
        s/= (l <= 0.5f) ? (v + m) : (2.0 - v - m);
    }else{
        if (outH)
			*outH = h;
		if (outS)
			*outS = s;
		if (outL)
			*outL = l;
        return;
    }

    r2 = (v - r)/vm;
    g2 = (v - g)/vm;
    b2 = (v - b)/vm;

    if (r == v){
        h = (g == m ? 5.0f + b2 : 1.0f - g2);
    }else if (g == v){
        h = (b == m ? 1.0f + r2 : 3.0 - b2);
    }else{
        h = (r == m ? 3.0f + g2 : 5.0f - r2);
    }
    
    h/=6.0f;
    
    if (outH)
        *outH = h;
    if (outS)
        *outS = s;
    if (outL)
        *outL = l;
    
}