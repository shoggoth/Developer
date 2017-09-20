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

void main( void ) {

    const float factor = 1024.;

    gl_FragColor = vec4(gl_FragCoord.x / factor, gl_FragCoord.y / factor, 0.0, 1.);
    gl_FragColor = vec4(tcVarying_0.s, tcVarying_0.t, 0.0, 1.);
}

#endif