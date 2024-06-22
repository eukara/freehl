!!ver 100 450
!!permu FOG
!!samps diffuse lightmap
!!cvardf gl_mono=0
!!cvardf gl_stipplealpha=0
!!cvardf r_waterRipples=0

#include "sys/defs.h"
#include "sys/fog.h"

varying vec2 tc;

#ifdef LIT
varying vec2 lm0;
#endif

#ifdef VERTEX_SHADER
	void main ()
	{
		tc = v_texcoord.st;
	#ifdef FLOW
		tc.s += e_time * -0.5;
	#endif
	#ifdef LIT
		lm0 = v_lmcoord;
	#endif
		gl_Position = ftetransform();
	}
#endif

#ifdef FRAGMENT_SHADER
#ifndef ALPHA
	#define USEALPHA 1.0
#else
	#define USEALPHA float(ALPHA)
#endif



// Hash functions shamefully stolen from:
// https://www.shadertoy.com/view/4djSRW
#define HASHSCALE1 .1031
#define HASHSCALE3 vec3(.1031, .1030, .0973)

float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * HASHSCALE1);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

vec2 hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * HASHSCALE3);
    p3 += dot(p3, p3.yzx+19.19);
    return fract((p3.xx+p3.yz)*p3.zy);

}

	void main ()
	{
		vec2 ntc;
		ntc.s = tc.s + sin(tc.t+ e_time)*0.125;
		ntc.t = tc.t + sin(tc.s+ e_time)*0.125;
		vec4 diffuse_f = texture2D(s_diffuse, ntc);

		diffuse_f *= e_colourident;

		// awful stipple alpha code
		#if gl_stipplealpha==1
			float alpha = USEALPHA * e_colourident.a;
			int x = int(mod(gl_FragCoord.x, 2.0));
			int y = int(mod(gl_FragCoord.y, 2.0));

			if (alpha <= 0.0) {
					discard;
			} else if (alpha <= 0.25) {
				diffuse_f.a = 1.0;
				if (x + y == 2)
					discard;
				if (x + y == 1)
					discard;
			} else if (alpha <= 0.5) {
				diffuse_f.a = 1.0;
				if (x + y == 2)
					discard;
				if (x + y == 0)
					discard;
			} else if (alpha < 1.0) {
				diffuse_f.a = 1.0;
				if (x + y == 2)
					discard;
			}
		#else
	#ifdef LIT

		#define MAX_RADIUS 2

		#if r_waterRipples ==1
		float resolution = 5.0f;
		float riptime = e_time;
		vec2 uv = tc.xy * resolution;
		vec2 p0 = floor(uv);
		vec2 circles = vec2(0.);
		for (int j = -MAX_RADIUS; j <= MAX_RADIUS; ++j) {
			for (int i = -MAX_RADIUS; i <= MAX_RADIUS; ++i) {
				vec2 pi = p0 + vec2(i, j);
				#if DOUBLE_HASH
				vec2 hsh = hash22(pi);
				#else
				vec2 hsh = pi;
				#endif
				vec2 p = pi + hash22(hsh);

				float t = fract(0.3* riptime + hash12(hsh));
				vec2 v = p - uv;
				float d = length(v) - (float(MAX_RADIUS) + 1.)*t;

				float h = 1e-3;
				float d1 = d - h;
				float d2 = d + h;
				float p1 = sin(31.*d1) * smoothstep(-0.6, -0.3, d1) * smoothstep(0., -0.3, d1);
				float p2 = sin(31.*d2) * smoothstep(-0.6, -0.3, d2) * smoothstep(0., -0.3, d2);
				circles += .05 * normalize(v) * ((p2 - p1) / (2. * h) * (1. - t) * (1. - t));
			}
		}
		circles /= float((MAX_RADIUS*2+1)*(MAX_RADIUS*2+1));

		float intensity = mix(0.01, 0.15, smoothstep(0.1, 0.6, abs(fract(0.05* riptime + 0.5)*2.-1.)));
		vec3 n = vec3(circles, sqrt(1. - dot(circles, circles)));

		diffuse_f = texture2D(s_diffuse, tc + n.yz);
		#endif
		//diffuse_f.rgb += pow(clamp(dot(n, normalize(vec3(1., 0.7, 0.5))), 0., 1.), 6.);
		diffuse_f.rgb *= (texture2D(s_lightmap, lm0) * e_lmscale).rgb;
	#endif
		#endif

		#if gl_mono==1
			float bw = (diffuse_f.r + diffuse_f.g + diffuse_f.b) / 3.0;
			diffuse_f.rgb = vec3(bw, bw, bw);
		#endif

		gl_FragColor = fog4(diffuse_f);
	}
#endif
