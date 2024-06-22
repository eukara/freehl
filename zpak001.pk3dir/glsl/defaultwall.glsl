!!ver 130
!!permu LIGHTSTYLED
!!permu FOG
!!samps diffuse reflectcube normalmap

!!permu FAKESHADOWS
!!cvardf r_glsl_pcf
!!samps =FAKESHADOWS shadowmap

!!samps lightmap
!!samps =LIGHTSTYLED lightmap1 lightmap2 lightmap3
!!cvardf gl_mono
!!cvardf gl_kdither
!!cvardf gl_stipplealpha
!!cvardf gl_ldr

!!cvardf r_skipDiffuse
!!cvardf r_skipLightmap

#include "sys/defs.h"
#include "sys/fog.h"

varying vec2 tex_c;

varying vec2 lm0;
#ifdef LIGHTSTYLED
varying vec2 lm1, lm2, lm3;
#endif

#ifdef REFLECTCUBE
varying vec3 eyevector;
varying mat3 invsurface;
#endif

#ifdef FAKESHADOWS
	varying vec4 vtexprojcoord;
#endif

#ifdef VERTEX_SHADER
	void lightmapped_init(void)
	{
		lm0 = v_lmcoord;
		#ifdef LIGHTSTYLED
		lm1 = v_lmcoord2;
		lm2 = v_lmcoord3;
		lm3 = v_lmcoord4;
		#endif
	}

	void main ()
	{
		lightmapped_init();
		tex_c = v_texcoord;
		gl_Position = ftetransform();

		/* HACK: func_conveyor needs us to scroll this surface! */
		if (e_glowmod.g == 0.5)
			tex_c[0] += (e_time * (e_glowmod.b * 1024.0)) * -0.01;

#ifdef REFLECTCUBE
		invsurface[0] = v_svector;
		invsurface[1] = v_tvector;
		invsurface[2] = v_normal;
		vec3 eyeminusvertex = e_eyepos - v_position.xyz;
		eyevector.x = dot( eyeminusvertex, v_svector.xyz );
		eyevector.y = dot( eyeminusvertex, v_tvector.xyz );
		eyevector.z = dot( eyeminusvertex, v_normal.xyz );
#endif
	}
#endif

#ifdef FRAGMENT_SHADER
	#include "sys/pcf.h"

#if r_skipLightmap==0
	vec3 lightmap_fragment(void)
	{
		vec3 lightmaps;

#ifdef LIGHTSTYLED
		lightmaps  = texture2D(s_lightmap0, lm0).rgb * e_lmscale[0].rgb;
		lightmaps += texture2D(s_lightmap1, lm1).rgb * e_lmscale[1].rgb;
		lightmaps += texture2D(s_lightmap2, lm2).rgb * e_lmscale[2].rgb;
		lightmaps += texture2D(s_lightmap3, lm3).rgb * e_lmscale[3].rgb;
#else
		lightmaps  = texture2D(s_lightmap, lm0).rgb * e_lmscale.rgb;
#endif
		if (gl_ldr == 1.0) {

			if (lightmaps.r > 1.5)
				lightmaps.r = 1.5;
			if (lightmaps.g > 1.5)
				lightmaps.g = 1.5;
			if (lightmaps.b > 1.5)
				lightmaps.b = 1.5;

			lightmaps.rgb * 0.5;
			lightmaps.rgb = floor(lightmaps.rgb * vec3(32,64,32))/vec3(32,64,32);
			lightmaps.rgb * 2.0;
		}

		return lightmaps;
	}
#else
	vec3 lightmap_fragment(void)
	{
		return vec3(1.0,1.0,1.0);
	}
#endif

	vec4 kernel_dither(sampler2D targ, vec2 texc)
	{
		int x = int(mod(gl_FragCoord.x, 2.0));
		int y = int(mod(gl_FragCoord.y, 2.0));
		int index = x + y * 2;
		vec2 coord_ofs;
		vec2 size;

		size.x = 1.0 / textureSize(targ, 0).x;
		size.y = 1.0 / textureSize(targ, 0).y;

		if (index == 0)
			coord_ofs = vec2(0.25, 0.0);
		else if (index == 1)
			coord_ofs = vec2(0.50, 0.75);
		else if (index == 2)
			coord_ofs = vec2(0.75, 0.50);
		else if (index == 3)
			coord_ofs = vec2(0.00, 0.25);

		return texture2D(targ, texc + coord_ofs * size);
	}

	void main ( void )
	{
		vec4 diffuse_f;

#if r_skipDiffuse==1
		diffuse_f = vec4(1.0,1.0,1.0,1.0);
#else
	#if gl_kdither==1
		diffuse_f = kernel_dither(s_diffuse, tex_c);
	#else
		diffuse_f = texture2D(s_diffuse, tex_c);
	#endif
#endif

/* get the alphatesting out of the way first */
#ifdef MASK
		/* HACK: terrible hack, CSQC sets this to mark surface as an entity
		   only entities are alphatested - ever */
		if (e_glowmod.r == 0.5)
		if (diffuse_f.a < 0.6) {
			discard;
		}
#endif
		/* lighting */
		//diffuse_f.rgb = vec3(1,1,1);
		diffuse_f.rgb *= lightmap_fragment();

#ifdef REFLECTCUBE
	#ifdef BUMP
		#ifndef FLATTENNORM
			vec3 normal_f = normalize(texture2D(s_normalmap, tex_c).rgb - 0.5);
		#else
			// For very flat surfaces and gentle surface distortions, the 8-bit precision per channel in the normalmap
			// can be insufficient. This is a hack to instead have very wobbly normalmaps that make use of the 8 bits
			// and then scale the wobblyness back once in the floating-point domain.
			vec3 normal_f = texture2D(s_normalmap, tex_c).rgb - 0.5;
			normal_f.x *= 0.0625;
			normal_f.y *= 0.0625;
			normal_f = normalize(normal_f);
		#endif
	#else
			vec3 normal_f = vec3(0, 0, 1);
	#endif
		vec3 cube_c;

		cube_c = reflect( normalize(-eyevector), normal_f);
		cube_c = cube_c.x * invsurface[0] + cube_c.y * invsurface[1] + cube_c.z * invsurface[2];
		cube_c = ( m_model * vec4(cube_c.xyz, 0.0)).xyz;
		diffuse_f.rgb = mix( textureCube(s_reflectcube, cube_c ).rgb, diffuse_f.rgb, diffuse_f.a);
#endif

		diffuse_f *= e_colourident;

	#if gl_stipplealpha==1
		float alpha = e_colourident.a;
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
	#endif

	#if gl_mono==1
		float bw = (diffuse_f.r + diffuse_f.g + diffuse_f.b) / 3.0;
		diffuse_f.rgb = vec3(bw, bw, bw);
	#endif

	#ifdef FAKESHADOWS
		diffuse_f.rgb *= ShadowmapFilter(s_shadowmap, vtexprojcoord);
	#endif

		gl_FragColor = fog4(diffuse_f);
		
	}
#endif
