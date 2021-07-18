#version 120
varying vec2 TexCoords;
uniform sampler2D colortex0;
uniform sampler2D colortex2;
uniform sampler2D colortex5;
uniform sampler2D depthtex1;
uniform sampler2D depthtex0;
uniform sampler2D shadowcolor0;
#define viewOutput colortex0 //[colortex0  colortex5 colortex2 shadowcolor0]

void main() {
    // Sample and apply gamma correction
    vec3 color = pow(texture2D(viewOutput, TexCoords).rgb, vec3(1.0 / 2.2));
    gl_FragColor = vec4(color, 1.0);
}