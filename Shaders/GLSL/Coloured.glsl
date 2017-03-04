//
//  DiffusePerVertex.glsl
//  iDispense
//
//  Created by Richard Henry on 11/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#if defined(GL_ES)
precision highp float;
#endif

varying vec4 colourVarying;

#if defined(COMPILE_VERTEX_SHADER)

#pragma mark Vertex Shader

attribute vec4 position;
attribute vec4 colour;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

void main(void) {

    colourVarying = colour;

    gl_Position = projectionMatrix * modelViewMatrix * position;
}

#elif defined(COMPILE_FRAGMENT_SHADER)

#pragma mark Fragment Shader

uniform mat4        colourMatrix;

void main(void) {

    gl_FragColor = colourMatrix * colourVarying;
}

#endif