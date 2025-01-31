!!ver 130
!!permu FOG
!!samps reflectcube
!!cvardf gl_mono=0

#include "sys/defs.h"
#include "sys/fog.h"

varying vec3 pos;
#ifdef VERTEX_SHADER
void main ()
{
	pos = v_position.xyz - e_eyepos;
	pos.y = -pos.y;
	gl_Position = ftetransform();
}
#endif
#ifdef FRAGMENT_SHADER
void main ()
{
	vec4 skybox = textureCube(s_reflectcube, pos);

	if (gl_mono == 1.0) {
		float bw = (skybox.r + skybox.g + skybox.b) / 3.0;
		skybox.rgb = vec3(bw, bw, bw) * 1.5;
	}

	gl_FragColor = vec4(fog3(skybox.rgb), 1.0);
}
#endif
