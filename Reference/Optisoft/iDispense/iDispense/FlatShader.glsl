//
//  BlinnPerFragment.glsl
//  iDispense
//
//  Created by Richard Henry on 11/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#if defined(GL_ES)
precision highp float;
#endif

#if defined(COMPILE_VERTEX_SHADER)

#pragma mark Vertex Shader

attribute vec4 position;
attribute vec3 normal;
attribute vec4 tc_0;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 textureMatrix;
uniform mat3 normalMatrix;

void main(void) {

    // Per-fragment Flat shading
    gl_Position = projectionMatrix * modelViewMatrix * position;
}

#elif defined(COMPILE_FRAGMENT_SHADER)

#pragma mark Fragment Shader

uniform mat4        colourMatrix;

void main(void) {

    gl_FragColor = colourMatrix * vec4(1.);
}

#endif