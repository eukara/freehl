/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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
	int s = (float)getproperty(VF_ACTIVESEAT);
	pViewBob = &g_viewBobVars[s];

	float var_bob;
	float var_cycle;
	float var_up;

	var_bob = autocvar_v_bob;
	var_cycle = autocvar_v_bobcycle;
	var_up = autocvar_v_bobup;

	pViewBob->m_flBobTime += clframetime;
	pViewBob->m_flBobCycle = pViewBob->m_flBobTime - (int)(pViewBob->m_flBobTime / var_cycle) * var_cycle;
	pViewBob->m_flBobCycle /= var_cycle;

	if (pViewBob->m_flBobCycle < var_up) {
		pViewBob->m_flBobCycle = MATH_PI * pViewBob->m_flBobCycle / var_up;
	} else {
		pViewBob->m_flBobCycle = MATH_PI + MATH_PI * (pViewBob->m_flBobCycle - var_up)/(1.0 - var_up);
	}

	vecVel = pSeat->m_vecPredictedVelocity;
	vecVel[2] = 0;
	pViewBob->m_flSpeed = vlen(vecVel);

	flBob = pViewBob->m_flSpeed * var_bob;
	flBob = flBob * 0.3 + flBob * 0.7 * sin(pViewBob->m_flBobCycle);
	pViewBob->m_flBob = bound(-7, flBob, 4);

	/* make sure it's adjusted for scale */
	pViewBob->m_flBob *= autocvar_r_viewmodelscale;
}

void
Viewmodel_ApplyBob(entity gun)
{
	// Give the gun a tilt effect like in old HL/CS versions
	if (autocvar(v_bobclassic, 1, "Viewmodel bob classic tilt switch") == 1) {
		gun.angles[2] = -pViewBob->m_flBob;
	}

	gun.origin += [0,0,-1] + (v_forward * (pViewBob->m_flBob * 0.4))
		+ (v_forward * autocvar_v_gunofs[0])
		+ (v_right * autocvar_v_gunofs[1])
		+ (v_up * autocvar_v_gunofs[2]);
}
