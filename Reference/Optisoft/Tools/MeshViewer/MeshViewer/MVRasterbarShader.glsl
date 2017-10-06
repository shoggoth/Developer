//
//  MVPlasmaShader.glsl
//  iDispense
//
//  Created by Richard Henry on 11/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#if defined(GL_ES)
precision mediump float;
#endif

varying vec4 localPos;

#if defined(COMPILE_VERTEX_SHADER)

#pragma mark Vertex Shader

attribute vec4 position;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

void main(void) {

    // Position in local coordinates
    localPos = position;

    gl_Position = projectionMatrix * modelViewMatrix * position;
}

#elif defined(COMPILE_FRAGMENT_SHADER)

#define M_PI 3.1415926535897932384626433832795
#define M_2_PI 6.2831853071795864769252867665590

#pragma mark Fragment Shader

uniform sampler2D   texture_0;

uniform mat4        colourMatrix;

uniform float time;

void main(void) {

    // Temp stop complaints about texture bind
    vec4 texel0 = texture2D(texture_0, vec2(0));

    // Simple sin in x
    float v = sin(localPos.x);

    // Rotating sin
    v += sin(10. * (localPos.x * sin(time * 0.5) + localPos.y * cos(time * 0.333)) + time);

    // Circular
    vec2 c = vec2(localPos.x + sin(time / 5.), localPos.y + cos(time / 3.));
    v += sin(sqrt(100. * (c.x * c.x + c.y * c.y) + 1.) + time);

    gl_FragColor = vec4(sin(v * M_PI), sin(v * M_PI + (2. * M_PI / 3.)), sin(v * M_PI + (2. * M_PI / 3.0)), 1.);
    //gl_FragColor = vec4(v);
}

#endif