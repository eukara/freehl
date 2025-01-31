!!permu FOG
!!samps 1

#include "sys/fog.h"
#ifdef VERTEX_SHADER
attribute vec2 v_texcoord;
attribute vec4 v_colour;
varying vec2 tc;
varying vec4 vc;
void main ()
{
	tc = v_texcoord;
	vc = v_colour;
	gl_Position = ftetransform();
}
#endif

#ifdef FRAGMENT_SHADER
varying vec2 tc;
varying vec4 vc;
uniform vec4 e_colourident;
void main ()
{
	vec4 diffuse_f = texture2D(s_t0, tc);
	gl_FragColor = fog4additive(diffuse_f * vc * e_colourident);
}
#endif
