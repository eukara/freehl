!!ver 100-450
!!samps 1

varying vec2 tc;
varying vec4 vc;

#ifdef VERTEX_SHADER
attribute vec2 v_texcoord;
attribute vec4 v_colour;
void main ()
{
	tc = v_texcoord;
	vc = v_colour;
	gl_Position = ftetransform();
}
#endif

#ifdef FRAGMENT_SHADER
void main ()
{
	vec4 f = vc;
#ifdef PREMUL
	f.rgb *= f.a;
#endif
	f *= texture2D(s_t0, tc);

	gl_FragColor = f;
}
#endif
