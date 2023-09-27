/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

void
ClientGame_PreDraw(void) 
{

}

void
ClientGame_PostDraw(void)
{
	if (pSeatLocal->m_flTitleAlpha > 0.0) {
		vector title1Pos = g_hudmins + (g_hudres / 2) + [-238,-15];
		vector title2Pos = g_hudmins + (g_hudres / 2) + [18,-15];
		float titleAlpha = pSeatLocal->m_flTitleAlpha;

		if (titleAlpha > 3.0)
			titleAlpha = 4.0 - titleAlpha;

		if (titleAlpha > 1.0)
			titleAlpha = 1.0f;

		drawsubpic(
			title1Pos,
			[256, 30],
			g_hud4_spr,
			[0, 226/256],
			[1, 30/256],
			[1,1,1] * titleAlpha,
			1.0,
			DRAWFLAG_ADDITIVE
		);

		drawsubpic(
			title2Pos,
			[220, 30],
			g_hud5_spr,
			[0, 226/256],
			[220/256, 30/256],
			[1,1,1] * titleAlpha,
			1.0f,
			DRAWFLAG_ADDITIVE
		);

		pSeatLocal->m_flTitleAlpha -= frametime;
	}
}
