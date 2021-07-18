#version 120

varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec4 Color;

#define WAVING		//enable waving block

const float PI = 3.1415927;

varying vec4 color;
varying vec2 lmcoord;
varying float mat;
varying vec2 texcoord;
varying vec4 vtexcoordam; // .st for add, .pq for mul
varying vec4 vtexcoord;

varying vec3 tangent;
varying vec3 normal;
varying vec3 binormal;
varying vec3 viewVector;
varying float dist;
varying float islava;

attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;

uniform vec3 cameraPosition;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform int worldTime;
uniform float frameTimeCounter;
uniform float rainStrength;
uniform vec3 moonPosition;

float pi2wt = PI*2*(frameTimeCounter*20);

vec3 calcWave(in vec3 pos, in float fm, in float mm, in float ma, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5) {
    vec3 ret;
    float magnitude,d0,d1,d2,d3;
    magnitude = sin(pi2wt*fm + pos.x*0.5 + pos.z*0.5 + pos.y*0.5) * mm + ma;
    d0 = sin(pi2wt*f0);
    d1 = sin(pi2wt*f1);
    d2 = sin(pi2wt*f2);
    ret.x = sin(pi2wt*f3 + d0 + d1 - pos.x + pos.z + pos.y) * magnitude;
    ret.z = sin(pi2wt*f4 + d1 + d2 + pos.x - pos.z + pos.y) * magnitude;
	ret.y = sin(pi2wt*f5 + d2 + d0 + pos.z + pos.y - pos.y) * magnitude;
    return ret;
}

vec3 calcMove(in vec3 pos, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5, in vec3 amp1, in vec3 amp2) {
    vec3 move1 = calcWave(pos      , 0.0027, 0.0400, 0.0400, 0.0127, 0.0089, 0.0114, 0.0063, 0.0224, 0.0015) * amp1;
	vec3 move2 = calcWave(pos+move1, 0.0348, 0.0400, 0.0400, f0, f1, f2, f3, f4, f5) * amp2;
    return move1+move2;
}

vec3 calcWaterMove(in vec3 pos)
{
	float fy = fract(pos.y + 0.001);
	if (fy > 0.002)
	{
		float wave = 0.05 * sin(2*PI/4*frameTimeCounter + 2*PI*2/16*pos.x + 2*PI*5/16*pos.z)
				   + 0.05 * sin(2*PI/3*frameTimeCounter - 2*PI*3/16*pos.x + 2*PI*4/16*pos.z);
		return vec3(0, clamp(wave, -fy, 1.0-fy), 0);
	}
	else
	{
		return vec3(0);
	}
}

void main() {
    // Transform the vertex
    gl_Position = ftransform();
    // Assign values to varying variables
    TexCoords = gl_MultiTexCoord0.st;
    // Use the texture matrix instead of dividing by 15 to maintain compatiblity for each version of Minecraft
    LightmapCoords = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.st;
    // Transform them into the [0, 1] range
    LightmapCoords = (LightmapCoords * 36.05f / 32.0f) - (1.05f / 32.0f);
    Normal = gl_NormalMatrix * gl_Normal;
    Color = gl_Color;
    	vec2 texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).st;
	vec2 midcoord = (gl_TextureMatrix[0] *  mc_midTexCoord).st;
	vec2 texcoordminusmid = texcoord-midcoord;
	vtexcoordam.pq  = abs(texcoordminusmid)*2;
	vtexcoordam.st  = min(texcoord,midcoord-texcoordminusmid);
	vtexcoord.st    = sign(texcoordminusmid)*0.5+0.5;
	mat = 0.9f;
	float istopv = 0.0;

    // if (moonPosition > vec3(0, 0, 0)){
        
    // }

	if (gl_MultiTexCoord0.t < mc_midTexCoord.t) istopv = 1.0;
	/* un-rotate */
	vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
	vec3 worldpos = position.xyz + cameraPosition;

	#ifdef WAVING
	if ( mc_Entity.x == 18.0 || mc_Entity.x == 161.0 || mc_Entity.x == 194.0 || mc_Entity.x == 195.0 || mc_Entity.x == 209.0 || mc_Entity.x == 210.0 || mc_Entity.x == 211.0 || mc_Entity.x == 212.0
	 || mc_Entity.x == 248.0 || mc_Entity.x == 249.0 || mc_Entity.x == 190.0)
			position.xyz += calcMove(worldpos.xyz, 0.0040, 0.0064, 0.0043, 0.0035, 0.0037, 0.0041, vec3(1.0,0.2,1.0), vec3(0.5,0.1,0.5)*rainStrength*3);

	if ( mc_Entity.x == 106.0 || mc_Entity.x == 184.0 || mc_Entity.x == 181.0 || mc_Entity.x == 182.0 || mc_Entity.x == 183.0 || mc_Entity.x == 185.0 || mc_Entity.x == 196.0)
			position.xyz += calcMove(worldpos.xyz, 0.0040, 0.0064, 0.0043, 0.0035, 0.0037, 0.0041, vec3(1.0,0.2,1.0), vec3(0.5,0.1,0.5)*rainStrength*5);

	if ( mc_Entity.x == 175.0 )
			position.xyz += calcMove(worldpos.xyz, 0.0041, 0.0070, 0.0044, 0.0038, 0.0063, 0.0000, vec3(0.1,0.0,0.1), vec3(0.1,0.0,0.1)*rainStrength*7);
	if (istopv > 0.9) {
	if ( mc_Entity.x == 31.0 || mc_Entity.x == 187 || mc_Entity.x == 178 || mc_Entity.x == 191 || mc_Entity.x == 6.0 || mc_Entity.x == 214.0 || mc_Entity.x == 215.0)
			position.xyz += calcMove(worldpos.xyz, 0.0041, 0.0070, 0.0044, 0.0038, 0.0063, 0.0000, vec3(0.8,0.0,0.8), vec3(0.4,0.0,0.4)*rainStrength*7);

	if (mc_Entity.x == 37.0 || mc_Entity.x == 38.0 || mc_Entity.x == 176 || mc_Entity.x == 177.0 || mc_Entity.x == 178.0)
			position.xyz += calcMove(worldpos.xyz, 0.0041, 0.005, 0.0044, 0.0038, 0.0240, 0.0000, vec3(0.8,0.0,0.8), vec3(0.4,0.0,0.4)*rainStrength*5);

	if ( mc_Entity.x == 59.0)
			position.xyz += calcMove(worldpos.xyz, 0.0041, 0.0070, 0.0044, 0.0038, 0.0240, 0.0000, vec3(0.8,0.0,0.8), vec3(0.4,0.0,0.4)*rainStrength*5);

	if ( mc_Entity.x == 51.0)
			position.xyz += calcMove(worldpos.xyz, 0.0105, 0.0096, 0.0087, 0.0063, 0.0097, 0.0156, vec3(1.2,0.4,1.2), vec3(0.8,0.8,0.8)*rainStrength*5);

	}

	if ( mc_Entity.x == 10.0 || mc_Entity.x == 11.0 ) {
			mat = 0.4;
			position.xyz += calcWaterMove(worldpos.xyz) * 0.25;
			}

	if ( mc_Entity.x == 111.0 || mc_Entity.x == 186) {
			position.xyz += calcWaterMove(worldpos.xyz) * 1.0;
			mat = 0.4;
			}
	#endif

	if (mc_Entity.x == 106.0 || mc_Entity.x == 31.0 || mc_Entity.x == 37.0 || mc_Entity.x == 38.0 || mc_Entity.x == 59.0 || mc_Entity.x == 30.0
	|| mc_Entity.x == 175.0	|| mc_Entity.x == 115.0 || mc_Entity.x == 32.0)
	mat = 1.0;
	
	if (mc_Entity.x == 50.0 || mc_Entity.x == 62.0 || mc_Entity.x == 76.0 || mc_Entity.x == 91.0 || mc_Entity.x == 89.0 || mc_Entity.x == 124.0 || mc_Entity.x == 138.0) mat = 0.6;
	/* re-rotate */
	
	/* projectify */
	gl_Position = gl_ProjectionMatrix * gbufferModelView * position;
	
	color = gl_Color;

	if ( mc_Entity.x == 10.0 || mc_Entity.x == 11.0 ) color = color*1.8;
	if ( mc_Entity.x == 51.0 ) color = color*1.8;

	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	
	 tangent = vec3(0.0);
	 binormal = vec3(0.0);
	 normal = normalize(gl_NormalMatrix * gl_Normal);
	 
	if (gl_Normal.y > 0.5) {
		//  0.0,  1.0,  0.0
		tangent.xyz  = normalize(gl_NormalMatrix * vec3( 1.0,  0.0,  0.0));
		binormal.xyz = normalize(gl_NormalMatrix * vec3( 0.0,  0.0,  1.0));
	} else if (gl_Normal.x > 0.5) {
		//  1.0,  0.0,  0.0
		tangent.xyz  = normalize(gl_NormalMatrix * vec3( 0.0,  0.0, -1.0));
		binormal.xyz = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
	} else if (gl_Normal.x < -0.5) {
		// -1.0,  0.0,  0.0
		tangent.xyz  = normalize(gl_NormalMatrix * vec3( 0.0,  0.0,  1.0));
		binormal.xyz = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
	} else if (gl_Normal.z > 0.5) {
		//  0.0,  0.0,  1.0
		tangent.xyz  = normalize(gl_NormalMatrix * vec3( 1.0,  0.0,  0.0));
		binormal.xyz = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
	} else if (gl_Normal.z < -0.5) {
		//  0.0,  0.0, -1.0
		tangent.xyz  = normalize(gl_NormalMatrix * vec3(-1.0,  0.0,  0.0));
		binormal.xyz = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
	} else if (gl_Normal.y < -0.5) {
		//  0.0, -1.0,  0.0
		tangent.xyz  = normalize(gl_NormalMatrix * vec3( 1.0,  0.0,  0.0));
		binormal.xyz = normalize(gl_NormalMatrix * vec3( 0.0,  0.0,  1.0));
	}

mat3 tbnMatrix = mat3(tangent.x, binormal.x, normal.x,
								  tangent.y, binormal.y, normal.y,
						     	  tangent.z, binormal.z, normal.z);
	
	
	viewVector = ( gl_ModelViewMatrix * gl_Vertex).xyz;
	
	viewVector = normalize(tbnMatrix * viewVector);
	
	
	dist = 0.0;
	dist = length(gl_ModelViewMatrix * gl_Vertex);
}