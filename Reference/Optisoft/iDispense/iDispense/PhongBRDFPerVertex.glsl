//
//  PhongBRDFPerVertex.glsl
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

uniform int mode;

void main(void) {

    // Per-vertex BRDF lighting
    const vec3 lightPosition = vec3(0., 0., -3.);
    const vec4 diffuseColour = vec4(0.6, 0.6, 0.6, 1.);
    const vec4 specularColour = vec4(1., 1., 1., 1.);

    vec3    eyeNormal = normalize(normalMatrix * normal);
    vec3    eyeVertexPosition = (modelViewMatrix * position).xyz;
    vec3    eyeLightDirection = normalize(lightPosition - eyeVertexPosition);

    float   lambertian = max(0., dot(eyeLightDirection, eyeNormal));
    float   specular = 0.;

    if (lambertian > 0.) {

        vec3    eyeReflectDirection = reflect(-eyeLightDirection, eyeNormal);
        float   specularAngle = max(0., dot(eyeReflectDirection, eyeViewDirection));
        vec3    eyeViewDirection = normalize(-eyeVertexPosition);

        specular = pow(specularAngle, 16.);
    }

    if (mode == 0) colourVarying = lambertian * diffuseColour + specular * specularColour;
    else if (mode == 1) colourVarying = lambertian * diffuseColour;
    else if (mode == 2) colourVarying = specular * specularColour;


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