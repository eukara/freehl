/*
 * Copyright (c) 2019-2024 Marco Cawthorne <marco@icculus.org>
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

var string g_damage_spr_t;
var string g_damage_spr_b;
var string g_damage_spr_l;
var string g_damage_spr_r;

var float autocvar_cg_damageFill = 0.25f;

void
Damage_Precache(void)
{
	g_damage_spr_t = spriteframe("sprites/640_pain.spr", 0, 0.0f);
	g_damage_spr_r = spriteframe("sprites/640_pain.spr", 1, 0.0f);
	g_damage_spr_b = spriteframe("sprites/640_pain.spr", 2, 0.0f);
	g_damage_spr_l = spriteframe("sprites/640_pain.spr", 3, 0.0f);
}



void HUD_DamageNotify_Check();
void
Damage_Draw(void)
{
	vector center;
	vector rel_pos;
	float fw, fw_alpha;
	float rt, rt_alpha;

	if (pSeat->m_flDamageAlpha <= 0.0) {
		return;
	}

	HUD_DamageNotify_Check();

	center = video_mins + (g_vidsize / 2);

	/* the pos relative to the player + view_dir determines which
	 * and how bright each indicator is drawn. so first get the relative
	 * position between us and the attacker, then calculate the strength
	 * of each direction based on a dotproduct tested against our
	 * camera direction.
	 */
	rel_pos = normalize(pSeat->m_vecDamagePos - getproperty(VF_ORIGIN));
	makevectors(getproperty(VF_CL_VIEWANGLES));
	fw = dotproduct(rel_pos, v_forward);
	rt = dotproduct(rel_pos, v_right);

	fw_alpha = fabs(fw) * pSeat->m_flDamageAlpha;
	if (fw > 0.25f) {
		drawpic(center + [-64,-102], g_damage_spr_t, 
			[128,48], [1,1,1], fw_alpha, DRAWFLAG_ADDITIVE);
	} else if (fw < -0.25f) {
		drawpic(center + [-64,70], g_damage_spr_b,
			[128,48], [1,1,1], fw_alpha, DRAWFLAG_ADDITIVE);
	}

	rt_alpha = fabs(rt) * pSeat->m_flDamageAlpha;
	if (rt > 0.25f) {
		drawpic(center + [70,-64], g_damage_spr_r,
			[48,128], [1,1,1], rt_alpha, DRAWFLAG_ADDITIVE);
	} else if (rt < -0.25f) {
		drawpic(center + [-102,-64], g_damage_spr_l,
			[48,128], [1,1,1], rt_alpha, DRAWFLAG_ADDITIVE);
	}

	if (autocvar_cg_damageFill > 0.0) {
		vector finalColor = [1,1,1];
		finalColor[1] = finalColor[2] = 1.0 - (pSeat->m_flDamageAlpha * autocvar_cg_damageFill);
		drawpic(video_mins, "fade_modulate", g_vidsize, finalColor, 1.0, DRAWFLAG_NORMAL);
	}

	pSeat->m_flDamageAlpha -= clframetime;
}
