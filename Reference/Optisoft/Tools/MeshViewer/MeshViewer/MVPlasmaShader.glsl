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

varying vec2 v_localPos;

#if defined(COMPILE_VERTEX_SHADER)

#pragma mark Vertex Shader

attribute vec4 position;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

void main(void) {

    // Position in local coordinates
    v_localPos = position.xy;

    gl_Position = projectionMatrix * modelViewMatrix * position;
}

#elif defined(COMPILE_FRAGMENT_SHADER)

#define M_PI 3.1415926535897932384626433832795
#define M_2_PI 6.2831853071795864769252867665590

#pragma mark Fragment Shader

uniform mat4        colourMatrix;

uniform float time;

void main(void) {
    
    // Scaling
    vec2 scale = vec2(9.);
    
    vec2 c = v_localPos * scale - scale / 2.;                   // vec2 c = v_coords * u_k - u_k/2.0;
    
    // Simple sin sum
    float v = sin(c.x + time);                                  // v += sin((c.x+u_time));
    v += sin((c.y + time) / 2.);                                // v += sin((c.y+u_time)/2.0);
    v += sin((c.x + c.y + time) / 2.);                          // v += sin((c.x+c.y+u_time)/2.0);
    
    // Circular
    c += scale / 2. * vec2(sin(time / 3.), cos(time / 2.));     // c += u_k/2.0 * vec2(sin(u_time/3.0), cos(u_time/2.0));
    v += sin(sqrt(c.x * c.x + c.y * c.y + 1.) + time);          // v += sin(sqrt(c.x*c.x+c.y*c.y+1.0)+u_time);
    
    v = v / 2.;
    vec3 colour = vec3(sin(M_2_PI * v), sin(M_PI * v), cos(M_PI * v));        // vec3 col = vec3(1, sin(PI*v), cos(PI*v));
    
    gl_FragColor = vec4(colour * 0.5 + 0.5, 1);                 // gl_FragColor = vec4(col*.5 + .5, 1);
    
    gl_FragColor = vec4(sin(v * M_PI), sin(v * M_PI + (2. * M_PI / 3.)), sin(v * M_PI + (4. * M_PI / 3.)), 1.);
}

//void iSortOfLikeTheSquaresThisOneMakes(void) {
//
//    // Temp stop complaints about texture bind
//    vec4 texel0 = texture2D(texture_0, vec2(0));
//
//    // Simple sin in x
//    float v = sin(localPos.x);
//
//    // Rotating sin
//    v += sin(10. * (localPos.x * sin(time * 0.5) + localPos.y * cos(time * 0.333)) + time);
//
//    // Circular
//    vec2 c = vec2(localPos.x + sin(time / 5.), localPos.y + cos(time / 3.));
//    v += sin(sqrt(100. * (c.x * c.x + c.y * c.y) + 1.) + time);
//
//    gl_FragColor = vec4(sin(v * M_PI), sin(v * M_PI + (2. * M_PI / 3.)), sin(v * M_PI + (4. * M_PI / 3.)), 1.);
//}

//void mainPoo(void) {
//    
//    float t = time * M_2_PI;
//    
//    vec2 pos = v_localPos * vec2(M_PI);
//    vec2 ccc = vec2(pos.x + 0.5 * sin(time * 5.), pos.y + 0.5 * cos(time * 3.));
//    vec3 col = vec3(0.);
//    
//    float v = sin(pos.x * 7. + t) * 0.5 + 0.5;
//    v += sin(10. * (pos.x * sin(time * 2.)) + (pos.y * cos(time * 3.)) + time) * 0.5 + 0.5;
//    v += sin(sqrt(100. * (ccc.x * ccc.x + ccc.y * ccc.y) + 1.) + time) * 0.5 + 0.5;
//    
//    col = vec3(sin(v * 3. * M_PI), sin(v * 5. * M_PI), sin(v * 7. * M_PI));
//    
//    gl_FragColor = colourMatrix * vec4(col, 1);
//}

#endif
