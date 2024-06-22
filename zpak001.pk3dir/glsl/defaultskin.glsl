!!ver 130
!!permu FRAMEBLEND
!!permu SKELETAL
!!permu UPPERLOWER
!!permu FOG
!!samps diffuse reflectcube upper lower
!!cvardf gl_affinemodels=0
!!cvardf gl_ldr=1
!!cvardf gl_halflambert=1
!!cvardf gl_mono=0
!!cvardf gl_kdither=0
!!cvardf gl_stipplealpha=0

!!permu FAKESHADOWS
!!cvardf r_glsl_pcf
!!samps =FAKESHADOWS shadowmap

!!cvardf r_skipDiffuse

#include "sys/defs.h"
#include "sys/fog.h"

#if gl_affinemodels == 1
	#define affine noperspective
#else
	#define affine
#endif

#ifdef REFLECTCUBE
varying vec3 eyevector;
varying mat3 invsurface;
#endif

#ifdef FAKESHADOWS
	varying vec4 vtexprojcoord;
#endif

affine varying vec2 tex_c;
varying vec3 light;

#ifdef VERTEX_SHADER
	#include "sys/skeletal.h"

	float lambert( vec3 normal, vec3 dir ) {
		return dot( normal, dir );
	}
	float halflambert( vec3 normal, vec3 dir ) {
		return ( dot( normal, dir ) * 0.5 ) + 0.5;
	}

#ifdef CHROME
	/* Rotate Light Vector */
	vec3 rlv(vec3 axis, vec3 origin, vec3 lightpoint)
	{
		vec3 offs;
		vec3 result;
		offs[0] = lightpoint[0] - origin[0];
		offs[1] = lightpoint[1] - origin[1];
		offs[2] = lightpoint[2] - origin[2];
		result[0] = dot(offs[0], axis[0]);
		result[1] = dot(offs[1], axis[1]);
		result[2] = dot(offs[2], axis[2]);
		return result;
	}
#endif

	vec3 VectorIRotate( vec3 inPos, mat3x4 xform )
	{
		vec3 outPos;
		outPos.x = inPos.x*xform[0][0] + inPos.y*xform[1][0] + inPos.z*xform[2][0];
		outPos.y = inPos.x*xform[0][1] + inPos.y*xform[1][1] + inPos.z*xform[2][1];
		outPos.z = inPos.x*xform[0][2] + inPos.y*xform[1][2] + inPos.z*xform[2][2];
		return outPos;
	}

	vec3 VectorTransform( vec3 inPos, mat3x4 xform )
	{
		vec3 outPos;
		outPos.x = dot( inPos, xform[0].xyz ) + xform[0][3];
		outPos.y = dot( inPos, xform[1].xyz ) + xform[1][3];
		outPos.z = dot( inPos, xform[2].xyz ) + xform[2][3];
		return outPos;
	}

	void main ()
	{
		vec3 n, s, t, w;
		gl_Position = skeletaltransform_wnst(w,n,s,t);
		tex_c = v_texcoord;

	#if gl_halflambert==1
		light = e_light_ambient + (e_light_mul * halflambert(n, e_light_dir));
	#else
		light = e_light_ambient + (e_light_mul * lambert(n, e_light_dir));
	#endif

		light *= e_lmscale.r;

		if (gl_ldr == 1.0) {
			if (light.r > 1.5)
				light.r = 1.5;
			if (light.g > 1.5)
				light.g = 1.5;
			if (light.b > 1.5)
				light.b = 1.5;

			light.rgb * 0.5;
			light.rgb = floor(light.rgb * vec3(32,64,32))/vec3(32,64,32);
			light.rgb * 2.0;
			light.rgb *= 0.75;
		}

#ifdef CHROME
	#ifndef SKELETAL
		vec3 rorg = rlv(vec3(0,0,0), w, e_light_dir);
		vec3 viewc = normalize(rorg - w);
		float d = dot(n, viewc);
		vec3 reflected;
		reflected.x = n.x * 2.0 * d - viewc.x;
		reflected.y = n.y * 2.0 * d - viewc.y;
		reflected.z = n.z * 2.0 * d - viewc.z;
		tex_c.x = 0.5 + reflected.y * 0.5;
		tex_c.y = 0.5 - reflected.z * 0.5;
	#else
		/* code contributed by Slartibarty */
		vec3 tmp = e_eyepos * -1.0f;

		int boneid = int(v_bone.r);
		tmp.x += m_bones_mat3x4[boneid][0][3];
		tmp.y += m_bones_mat3x4[boneid][1][3];
		tmp.z += m_bones_mat3x4[boneid][2][3];

		tmp = normalize( tmp );
		vec3 chromeUp = normalize( cross( tmp, vec3( m_modelview[0][0], m_modelview[1][0], m_modelview[2][0] ) ) );
		vec3 chromeRight = normalize( cross( chromeUp, tmp ) );

		chromeUp = VectorIRotate( chromeUp, m_bones_mat3x4[boneid] );
		chromeRight = VectorIRotate( chromeRight, m_bones_mat3x4[boneid] );

		float na;

		// calc s coord
		na = dot( v_normal, chromeRight );
		tex_c.x = ( na + 1.0 ) * 0.5;

		// calc t coord
		na = dot( v_normal, chromeUp );
		tex_c.y = ( na + 1.0 ) * 0.5;
	#endif
#endif
	
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

	vec3 hsv2rgb(float h, float s, float v)
	{
		int i;
		float f,p,q,t;
		vec3 col = vec3(0,0,0);

		h = max(0.0, min(360.0, h));
		s = max(0.0, min(100.0, s));
		v = max(0.0, min(100.0, v));

		s /= 100;
		v /= 100;

		if (s == 0) {
			col.x= col.y = col.z = int(v*255);
			return col / 255.0;
		}

		h /= 60;
		i = int(floor(h));
		f = h - i;
		p = v * (1 - s);
		q = v * (1 - s * f);
		t = v * (1 - s * (1 - f));

		switch (i) {
		case 0:
			col[0] = int(255*v);
			col[1] = int(255*t);
			col[2] = int(255*p);
			break;
		case 1:
			col[0] = int(255*q);
			col[1] = int(255*v);
			col[2] = int(255*p);
			break;
		case 2:
			col[0] = int(255*p);
			col[1] = int(255*v);
			col[2] = int(255*t);
			break;
		case 3:
			col[0] = int(255*p);
			col[1] = int(255*q);
			col[2] = int(255*v);
			break;
		case 4:
			col[0] = int(255*t);
			col[1] = int(255*p);
			col[2] = int(255*v);
			break;
		default:
			col[0] = int(255*v);
			col[1] = int(255*p);
			col[2] = int(255*q);
		}
		return col / 255.0;
	}

	void main ()
	{
		vec4 diffuse_f;

#if r_skipDiffuse==1
		diffuse_f = vec4(1.0, 1.0, 1.0, 1.0);
#else
	#if gl_kdither==1
		diffuse_f = kernel_dither(s_diffuse, tex_c);
	#else
		diffuse_f = texture2D(s_diffuse, tex_c);
	#endif
#endif

	#ifdef UPPER
		vec4 uc = texture2D(s_upper, tex_c);

		if (e_colourident.z == 2.0) {
			vec3 topcolor = hsv2rgb(e_colourident.x * 360, 100, 100);
			diffuse_f.rgb += uc.rgb*topcolor*uc.a;
		} else {
			diffuse_f.rgb += uc.rgb*e_uppercolour*uc.a;
		}
	#endif

	#ifdef LOWER
		vec4 lc = texture2D(s_lower, tex_c);

		if (e_colourident.z == 2.0) {
			vec3 bottomcolor = hsv2rgb(e_colourident.y * 360, 100, 100);
			diffuse_f.rgb += lc.rgb*bottomcolor*lc.a;
		} else {
			diffuse_f.rgb += lc.rgb*e_lowercolour*lc.a;
		}
	#endif

		diffuse_f.rgb *= light;

#ifdef REFLECTCUBE
		vec3 cube_c;
		vec4 out_f = vec4( 1.0, 1.0, 1.0, 1.0 );

		cube_c = reflect( normalize( -eyevector ), vec3( 0, 0, 1 ) );
		cube_c = cube_c.x * invsurface[0] + cube_c.y * invsurface[1] + cube_c.z * invsurface[2];
		cube_c = ( m_model * vec4( cube_c.xyz, 0.0 ) ).xyz;
		out_f.rgb = mix( textureCube( s_reflectcube, cube_c ).rgb, diffuse_f.rgb, diffuse_f.a );
		diffuse_f = out_f;
#endif

	if (e_colourident.z != 2.0) {
		diffuse_f *= e_colourident;
	}

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
