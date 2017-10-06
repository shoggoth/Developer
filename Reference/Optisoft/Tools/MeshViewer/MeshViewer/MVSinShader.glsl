//
//  MVSinShader.glsl
//  iDispense
//
//  Created by Richard Henry on 11/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#if defined(GL_ES)
precision mediump float;
#endif

varying vec4 colourVarying;
varying vec2 tcVarying_0;

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

    // Per-vertex diffuse only lighting
    vec3 eyeNormal = normalize(normalMatrix * normal);
    const vec3 lightPosition = vec3(0., 0., 1.);
    vec4 ambientColour = vec4(0.2, 0.2, 0.2, 1.0);
    vec4 diffuseColour = vec4(0.6, 0.6, 0.6, 1.0);

    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));

    colourVarying = diffuseColour * nDotVP + ambientColour;

    tcVarying_0 = (textureMatrix * tc_0).st;

    gl_Position = projectionMatrix * modelViewMatrix * position;
}

#elif defined(COMPILE_FRAGMENT_SHADER)

#define M_PI 3.1415926535897932384626433832795
#define M_2_PI 6.2831853071795864769252867665590

#pragma mark Fragment Shader

uniform sampler2D   texture_0;
uniform sampler2D   texture_1;

uniform mat4        colourMatrix;

uniform float time;

void main(void) {

    vec2 tc = vec2(tcVarying_0.s + sin((time + tcVarying_0.t) * M_2_PI) * 0.5, tcVarying_0.t);
    vec4 texel0 = texture2D(texture_0, tc);
    vec4 texel1 = texture2D(texture_1, tc);

    gl_FragColor = colourMatrix * colourVarying * mix(texel0, texel1, texel1.a);
}

#endif