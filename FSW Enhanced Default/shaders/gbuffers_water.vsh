#version 460 compatibility

out vec2 textureCoordinates;
out vec2 lightmapCoordinates;
out vec4 glColor;
out vec3 N;
attribute vec3 mc_Entity;
out vec3 blockID;
varying vec4 Color;
varying vec2 TexCoords;

uniform mat4 gbufferModelViewInverse;

void main() {
  blockID = mc_Entity.xyz;
  TexCoords = gl_MultiTexCoord0.st;
  Color = gl_Color;
  gl_Position         = ftransform();
  textureCoordinates  = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  lightmapCoordinates = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
  glColor             = gl_Color;
  N                   = mat3(gbufferModelViewInverse) * normalize(gl_NormalMatrix * gl_Normal);
}
