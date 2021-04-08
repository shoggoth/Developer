
void main() {

#define iterations 256
    
    vec2 position = v_tex_coord;                // Gets the location of the current pixel in the intervals [0..1] [0..1]
    vec3 color = vec3();                        // Initialize color to black
    
    vec2 z = position;                          // z.x is the real component z.y is the imaginary component
    
    
    // Rescale the position to the intervals [-2,1] [-1,1]
    z *= vec2(3.0, 2.0);
    z -= vec2(2.0, 1.0);
    
    vec2 c = z;
    
    float it = 0.0;
    for (int i = 0; i < iterations; ++i) {
        
        // zn = zn-1 ^ 2 + c
        // (x + yi) ^ 2 = x ^ 2 - y ^ 2 + 2xyi
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y);
        z += c;
        
        if (dot(z,z) > 4.0) break;              // dot(z,z) == length(z) ^ 2 only faster to compute
        
        it += 1.0;
    }
    
    if (it < float(iterations)) {
        
        color.r = sin(it / 3.0);
        color.g = cos(it / 6.0);
        color.b = cos(it / 12.0 + 3.14 / 4.0);
    }
    
    gl_FragColor = vec4(color,1.0);
}
