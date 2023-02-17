/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

/* very primitive bobbing code, similar to Quake. Some ideas:
   - allow for a second bob that runs at a separate cycle speed
	- second bob could be applied to the side, would give a Doom III/HL2/TS
	  like viewmodel bob that people may like
*/

var float autocvar_v_bob = 0.01;
var float autocvar_v_bobcycle = 0.8;
var float autocvar_v_bobup = 0.5;

struct
{
	float m_flBobTime;
	float m_flBob;
	float m_flBobCycle;
	float m_flSpeed;
} g_viewBobVars[4], *pViewBob;

/* bob vars are calculated separately from application, so that if there's
 * more than one viewmodel we won't affect the speed of the bob by running
 * the math too many times */
void
Viewmodel_CalcBob(void)
{
	vector vecVel;
	float flBob;
	int iCycle;
	int s = (float)getproperty(VF_ACTIVESEAT);
	pViewBob = &g_viewBobVars[s];

	float var_bob;
	float var_cycle;
	float var_up;

	var_bob = autocvar_v_bob;
	var_cycle = autocvar_v_bobcycle;
	var_up = autocvar_v_bobup;

	/* how many cycles have we done in total */
	iCycle = (pViewBob->m_flBobTime / var_cycle);

	/* increment the input value for our cycle */
	pViewBob->m_flBobTime += frametime;

	/* calculate the point in the cycle based on the input time */
	pViewBob->m_flBobCycle = pViewBob->m_flBobTime - (iCycle * var_cycle);
	pViewBob->m_flBobCycle /= var_cycle;

	/* prepare for our cycle value to be placed into sin() to get the wave motion */
	pViewBob->m_flBobCycle = MATH_PI * (pViewBob->m_flBobCycle / var_up);

	/* we based the speed on the clients movement speed, but ignore any height/jump velocity */
	vecVel = pSeat->m_vecPredictedVelocity;
	vecVel[2] = 0;

	pViewBob->m_flSpeed = vlen(vecVel);

	/* bob equals speed times strength times cycle */
	flBob = ((pViewBob->m_flSpeed * var_bob) * sin(pViewBob->m_flBobCycle));

	/* clamp between -8 and 4 units */
	pViewBob->m_flBob = bound(-8, flBob, 4);

	/* make sure it's adjusted for scale */
	pViewBob->m_flBob *= autocvar_cg_viewmodelScale;
}

float
Viewmodel_GetBob(void)
{
	int s = (float)getproperty(VF_ACTIVESEAT);
	pViewBob = &g_viewBobVars[s];
	return pViewBob->m_flBob;
}

void
Viewmodel_ApplyBob(entity gun)
{
	int s = (float)getproperty(VF_ACTIVESEAT);
	pViewBob = &g_viewBobVars[s];

	// Give the gun a tilt effect like in old HL/CS versions
	if (autocvar(v_bobclassic, 1, "Viewmodel bob classic tilt switch") == 1) {
		gun.angles[2] = -pViewBob->m_flBob;
	}

	/* apply the gun offset based on our bob */
	gun.origin += [0,0,-1] + (v_forward * (pViewBob->m_flBob * 0.4))
		+ (v_forward * autocvar_cg_viewmodelOffset[0])
		+ (v_right * autocvar_cg_viewmodelOffset[1])
		+ (v_up * autocvar_cg_viewmodelOffset[2]);
}
