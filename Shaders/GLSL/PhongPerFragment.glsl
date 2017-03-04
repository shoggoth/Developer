//
//  PhongPerFragment.glsl
//  iDispense
//
//  Created by Richard Henry on 11/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#if defined(GL_ES)
precision mediump float;
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

    // Per-fragment Phong lighting
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
uniform int         mode;

void main(void) {

    const vec3 lightPosition = vec3(0., 0., -3.);
    const vec4 ambientColour = vec4(0.2, 0.2, 0.2, 1.);
    const vec4 diffuseColour = vec4(0.6, 0.6, 0.6, 1.);
    const vec4 specularColour = vec4(1., 1., 1., 1.);

    vec3 normal = normalize(normalVarying);
    vec3 lightDirection = normalize(lightPosition - positionVarying);
    vec4 texel0 = texture2D(texture_0, tcVarying_0);
    vec4 texel1 = texture2D(texture_1, tcVarying_0);

    float lambertian = max(0., dot(lightDirection, normal));
    float specular = 0.;

    if (lambertian > 0.) {

        vec3    reflectDirection = reflect(-lightDirection, normal);
        vec3    viewDirection = normalize(-positionVarying);
        float   specularAngle = max(0., dot(reflectDirection, viewDirection));

        specular = pow(specularAngle, 4.0);
    }

    vec4 finalColour;

    if (mode == 0) finalColour = ambientColour + lambertian * diffuseColour + specular * specularColour;
    else if (mode == 1) finalColour = ambientColour;
    else if (mode == 2) finalColour = lambertian * diffuseColour;
    else if (mode == 3) finalColour = specular * specularColour;

    gl_FragColor = colourMatrix * finalColour * mix(texel0, texel1, texel1.a);
}

#endif