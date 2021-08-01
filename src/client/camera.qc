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

struct
{
	float m_flSpeed;
	float m_flFracSin;
	float m_flTime;
	float m_flMove;
	float m_flDelta;
	int m_iCycle;
} g_camBobVars[4], *pCamBob;

/* tilts the camera for a head-bob like effect when moving */
void
Camera_RunBob(__inout vector camera_angle)
{
	if (!autocvar(v_cambob, 0, "Enables bobbing effect for the first-person camera"))
		return;

	int s = (float)getproperty(VF_ACTIVESEAT);
	pCamBob = &g_camBobVars[s];

	/* we don't really care about the vertical velocity */
	vector speed = pSeat->m_vecPredictedVelocity;
	speed[2] = 0.0f;
	pCamBob->m_flSpeed = vlen(speed);

	/* don't bother on low speeds */
	if ( pCamBob->m_flSpeed < 5.0f ) {
		pCamBob->m_flMove = 0.0f;
		pCamBob->m_flTime = 0.0f; /* progress has halted, start anew */
		return;
	} else if (pSeat->m_ePlayer.flags & FL_ONGROUND) {
		pCamBob->m_flMove = clframetime * (pCamBob->m_flSpeed * 0.01);
	}

	pCamBob->m_flTime = (pCamBob->m_flTime += pCamBob->m_flMove);
	pCamBob->m_flFracSin = fabs(sin(pCamBob->m_flTime * M_PI));
	pCamBob->m_iCycle = (int)pCamBob->m_flTime;
	pCamBob->m_flDelta = (pCamBob->m_flFracSin * 0.0025f) * pCamBob->m_flSpeed;

	camera_angle[0] += pCamBob->m_flDelta;

	if (pCamBob->m_iCycle & 1) {
		pCamBob->m_flDelta = -pCamBob->m_flDelta;
	}

	camera_angle[2] += pCamBob->m_flDelta;
}

/* applies a tilt to the camera for when we're strafing left to right */
void
Camera_StrafeRoll(__inout vector camera_angle)
{
	if (!autocvar(v_camroll, 1, "Enables strafe-roll for the first-person camera"))
		return;

	float roll;
	makevectors(camera_angle);

	roll = dotproduct(pSeat->m_vecPredictedVelocity, v_right);
	roll *= 0.015f;

	camera_angle[2] += roll;
}
