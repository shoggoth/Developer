//
//  Red.glsl
//  LensView
//
//  Created by Richard Henry on 11/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#if defined(GL_ES)
precision mediump float;
#endif

varying vec2 tcVarying_0;

#if defined(COMPILE_VERTEX_SHADER)

#pragma mark Vertex Shader

attribute vec4 position;
attribute vec3 normal;
attribute vec2 tc_0;

uniform mat4 modelViewProjectionMatrix;

void main(void) {

    gl_Position = modelViewProjectionMatrix * position;
    tcVarying_0 = tc_0;
}

#elif defined(COMPILE_FRAGMENT_SHADER)

#pragma mark Fragment Shader

uniform float time;
//uniform vec2 mouse;
//uniform vec2 resolution;

#define SIN_ITER 4

float f(vec3 p) {

	p.x += time;
	for (int i=0;i<SIN_ITER;i++)
	{
		p = sin(p*0.91+0.17+cos(time*0.123)*0.1);
	}
	return length(p) - 1.0/float(SIN_ITER);
}

void main( void ) {

    vec2 resolution = vec2(0.25);
	vec2 pos = (tcVarying_0.xy) / max(resolution.x, resolution.y);

	vec3 p = vec3(pos, -2.0);
	for (int i=0;i<8;i++)
	{
		p += f(p)*vec3(pos, 0.5+sin(time*0.1));
	}

	gl_FragColor = vec4(1.-abs(p-4.*vec3(pos, 1.))/5., 1.);
}

#endif