//
// Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

!!samps screen=0
!!ver 120

#include "sys/defs.h"
varying vec2 texcoord;

#ifdef VERTEX_SHADER
void main()
{
	texcoord = v_texcoord.xy;
	texcoord.y = 1.0 - texcoord.y;
	gl_Position = ftetransform();
}
#endif

#ifdef FRAGMENT_SHADER
// accentuate the gritty lighting
vec3 p_gamma(vec3 col)
{
	float gamma = 0.85f;
	col.r = pow(col.r, 1.0 / gamma);
	col.g = pow(col.g, 1.0 / gamma);
	col.b = pow(col.b, 1.0 / gamma); 
	return col;
}

void main(void)
{
	vec2 pos = vec2(gl_FragCoord.x, gl_FragCoord.y);
	vec3 col = texture2D(s_screen, texcoord).rgb;

	// mess with gamma
	col = p_gamma(col);

	// 16-bit ify
	col.rgb = floor(col.rgb * vec3(32,64,32))/vec3(32,64,32);

	gl_FragColor = vec4(col, 1.0);
}
#endif
