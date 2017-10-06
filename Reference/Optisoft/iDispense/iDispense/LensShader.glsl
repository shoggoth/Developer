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

varying vec3 normalVarying;
varying vec3 positionVarying;
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

    // Per-fragment Blinn-Phong lighting
    normalVarying = normalize(normalMatrix * normal);
    positionVarying = (modelViewMatrix * position).xyz;
    tcVarying_0 = (textureMatrix * tc_0).st;

    gl_Position = projectionMatrix * modelViewMatrix * position;
}

#elif defined(COMPILE_FRAGMENT_SHADER)

#pragma mark Fragment Shader

uniform sampler2D   texture_0;
uniform sampler2D   texture_1;

uniform mat4        colourMatrix;

void main(void) {

    const vec3 lightPosition = vec3(5., 2., 2.5);
    const vec4 ambientColour = vec4(0.2, 0.2, 0.3, 1.);
    const vec4 diffuseColour = vec4(0.7, 0.7, 0.9, 1.);
    const vec4 specularColour = vec4(0.9, 0.9, 1., 1.);

    vec3 normal = normalize(normalVarying);
    vec3 lightDirection = normalize(lightPosition - positionVarying);
    vec4 texel0 = texture2D(texture_0, tcVarying_0);
    vec4 texel1 = texture2D(texture_1, tcVarying_0);

    float lambertian = max(0., dot(lightDirection, normal));
    float specular = 0.;

    if (lambertian > 0.) {

        vec3    viewDirection = normalize(-positionVarying);
        vec3    halfVector = normalize(lightDirection + viewDirection);
        float   specularAngle = max(0., dot(halfVector, normal));

        specular = pow(specularAngle, 64.0);
    }

    vec4 finalColour = ambientColour + lambertian * diffuseColour + specular * specularColour;

    gl_FragColor = colourMatrix * finalColour * mix(texel0, texel1, texel1.a);
}

#endif