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
    const vec3 lightPosition = vec3(0., 0., -3.);
    vec4 ambientColour = vec4(0.2, 0.2, 0.2, 1.0);
    vec4 diffuseColour = vec4(0.6, 0.6, 0.6, 1.0);

    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));

    colourVarying = diffuseColour * nDotVP + ambientColour;

    tcVarying_0 = (textureMatrix * tc_0).st;

    gl_Position = projectionMatrix * modelViewMatrix * position;
}

#elif defined(COMPILE_FRAGMENT_SHADER)

#pragma mark Fragment Shader

uniform sampler2D   texture_0;
uniform sampler2D   texture_1;

uniform mat4        colourMatrix;

void main(void) {

    vec4 texel0 = texture2D(texture_0, tcVarying_0);
    vec4 texel1 = texture2D(texture_1, tcVarying_0);

    gl_FragColor = colourMatrix * colourVarying * mix(texel0, texel1, texel1.a);
}

#endif