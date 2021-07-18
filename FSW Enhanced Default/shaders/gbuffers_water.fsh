#version 460 compatibility

in vec2 textureCoordinates;
in vec2 lightmapCoordinates;
in vec4 glColor;
in vec3 N;
in vec3 blockID;
varying vec4 Color;
varying vec2 TexCoords;


uniform sampler2D texture;
uniform sampler2D lightmap;

/* DRAWBUFFERS:05 */
void main() {
  vec4 Albedo = texture2D(texture, TexCoords) * Color;
  if(abs(blockID.x - 20) < 0.001){
    gl_FragData[0] = vec4(Albedo);
    gl_FragData[1] = vec4(20 / 255.0);
  }else{
    gl_FragData[0] = vec4(Albedo);
    gl_FragData[1] = vec4(1.0);
  }
}