//
//  MVScreenShader.glsl
//  iDispense
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

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 textureMatrix;
uniform mat3 normalMatrix;

void main(void) {
    
    tcVarying_0 = (textureMatrix * position).xy * 0.5 + 0.5;
    
    gl_Position = projectionMatrix * modelViewMatrix * position;
}

#elif defined(COMPILE_FRAGMENT_SHADER)

#pragma mark Fragment Shader

uniform sampler2D   texture_0;

uniform mat4        colourMatrix;

uniform float time;

void main(void) {
    
    vec4 texel0 = texture2D(texture_0, tcVarying_0);
    
    gl_FragColor = colourMatrix * texel0;
}

#endif