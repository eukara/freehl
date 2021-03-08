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

/*QUAKED weapon_egon (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_egon.mdl"

HALF-LIFE (1998) ENTITY

Egon/Gluon-Gun Weapon

*/

#ifdef CLIENT
var float TRAIL_EGONBEAM;

#define FXGAUSS_BEAMCOLOR [1,0.5,0]
class FXEgon:CBaseFX
{
	int m_iBeams;
	vector m_vecStart;
	vector m_vecAngle;

	void(void) FXEgon;
	virtual void(void) Draw;
};

void
FXEgon::Animate_Next(void)
{
	frame++;

	if (frame == 11)
		frame = 0;

	nextthink = time + 0.1f;
}

void
FXEgon::Draw(void)
{
	player pl = (player)self;
	int iLoop = 6;
	vector src, endpos;
	vector gunpos = gettaginfo(pSeat->m_eViewModel, 33);

	if (alpha <= 0.0f) {
		modelindex = 0;
		return;
	}

	src = gettaginfo(pSeat->m_eViewModel, 0);
	makevectors(input_angles);
	endpos = src + v_forward * 1024;
	traceline(src, endpos, FALSE, pl);

	dynamiclight_add(trace_endpos + v_forward * -16, 128, [0.5, 0.5, 1.0]);
	trailparticles(TRAIL_EGONBEAM, pl, gunpos, trace_endpos);
	setorigin(this, trace_endpos + v_forward * -16);

	setmodel(this, "sprites/xspark1.spr");
	effects = EF_ADDITIVE;
}

void
FXEgon::FXEgon(void)
{
	CBaseFX::CBaseFX();
	think = Animate_Next;
	nextthink = time + 0.1f;
}
#endif

enum
{
	EGON_IDLE1,
	EGON_FIDGET1,
	EGON_ALTFIREON,
	EGON_ALTFIRECYCLE,
	EGON_ALTFIREOFF,
	EGON_FIRE1,
	EGON_FIRE2,
	EGON_FIRE3,
	EGON_FIRE4,
	EGON_DRAW,
	EGON_HOLSTER
};

void w_egon_precache(void)
{
#ifdef SERVER
	precache_sound("weapons/egon_windup2.wav");
	precache_sound("weapons/egon_run3.wav");
	precache_sound("weapons/egon_off1.wav");
	precache_model("models/w_egon.mdl");
#else
	TRAIL_EGONBEAM = particleeffectnum("weapon_egon.beam");
	precache_model("models/v_egon.mdl");
	precache_model("models/p_egon.mdl");
	precache_model("sprites/xspark1.spr");
#endif
}
void w_egon_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, pl.ammo_uranium, -1);
}
string w_egon_wmodel(void)
{
	return "models/w_egon.mdl";
}
string w_egon_pmodel(void)
{
	return "models/p_egon.mdl";
}
string w_egon_deathmsg(void)
{
	return "";
}

int w_egon_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (pl.ammo_uranium < MAX_A_URANIUM) {
		pl.ammo_uranium = bound(0, pl.ammo_uranium + 20, MAX_A_URANIUM);
	} else {
		return FALSE;
	}
#endif
	return TRUE;
}

void w_egon_draw(void)
{
	player pl = (player)self;
	pl.mode_tempstate = 0;

	/* link the FX class */
#ifdef CLIENT
	Weapons_SetModel("models/v_egon.mdl");
	Weapons_ViewAnimation(EGON_DRAW);

	entity eold = self;
	self = pSeat->m_pWeaponFX;
	spawnfunc_FXEgon();
	self = eold;
#endif
}

void w_egon_holster(void)
{
	Weapons_ViewAnimation(EGON_HOLSTER);
}

void w_egon_release(void);

void w_egon_primary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* Ammo check */
	if (pl.ammo_uranium <= 0) {
		w_egon_release();
		return;
	}

#ifdef CLIENT
	if (Weapons_GetAnimation() == EGON_IDLE1)
		Weapons_ViewAnimation(EGON_ALTFIREON);
	else if (Weapons_GetAnimation() == EGON_ALTFIREON)
		Weapons_ViewAnimation(EGON_ALTFIRECYCLE);

	FXEgon p = (FXEgon)pSeat->m_pWeaponFX;
	p.m_vecAngle = input_angles;
	p.m_vecStart = pl.origin + pl.view_ofs;
	p.alpha = 1.0f;
#else
	Weapons_MakeVectors();
	vector src = Weapons_GetCameraPos();
	vector endpos = src + v_forward * 1024;
	traceline(src, endpos, FALSE, pl);
	Damage_Radius(trace_endpos, pl, 14, 64, TRUE, DMG_ELECTRO);
#endif

	pl.ammo_uranium--;

	if (pl.mode_tempstate == 0) {
#ifdef SERVER
		sound(pl, CHAN_WEAPON, "weapons/egon_windup2.wav", 1, ATTN_NORM, 100, 0);
#endif
		pl.mode_tempstate = 1;
		Weapons_ViewPunchAngle([-5,0,0]);
		pl.w_idle_next = 3.0f;
	} else if not (pl.w_idle_next > 0.0f) {
		/* wait 3 seconds (idle next) */
		if (pl.mode_tempstate == 1) {
#ifdef SERVER
			sound(pl, CHAN_WEAPON, "weapons/egon_run3.wav", 1, ATTN_NORM, 100);
#endif
			pl.mode_tempstate = 2;
		}
		pl.w_idle_next = 3.0f;
	}

	pl.w_attack_next = 0.2f;
}

void w_egon_reload(void)
{
	
}

void w_egon_release(void)
{
	player pl = (player)self;

#ifdef CLIENT
	FXEgon p = (FXEgon)pSeat->m_pWeaponFX;
	p.m_vecAngle = input_angles;
	p.m_vecStart = pl.origin + pl.view_ofs;
	p.alpha = 0.0f;
#endif	

	if (pl.mode_tempstate != 0) {
#ifdef SERVER
		sound(pl, CHAN_WEAPON, "weapons/egon_off1.wav", 1, ATTN_NORM, 100, 0);
#endif
		pl.mode_tempstate = 0;
		Weapons_ViewPunchAngle([-2,0,0]);
	}

#ifndef SERVER
	if (Weapons_GetAnimation() == EGON_ALTFIRECYCLE) {
		Weapons_ViewAnimation(EGON_ALTFIREOFF);
		pl.w_idle_next = 1.0f;
	} else {
		if (pl.w_idle_next > 0.0f) {
			return;
		}
		int r = (float)input_sequence % 3;
		if (r == 1) {
			Weapons_ViewAnimation(EGON_FIDGET1);
			pl.w_idle_next = 2.666667f;
		} else {
			Weapons_ViewAnimation(EGON_IDLE1);
			pl.w_idle_next = 2.0f;
		}
	}
#endif
}
void w_egon_crosshair(void)
{
#ifdef CLIENT
	static vector cross_pos;
	cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];
	drawsubpic(cross_pos, [24,24], g_cross_spr, [72/128,48/128], [0.1875, 0.1875], [1,1,1], 1, DRAWFLAG_NORMAL);
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [0,96/128], [24/256, 24/128], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

float w_egon_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMEGON : ANIM_AIMEGON;
}

void w_egon_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;
	vector hud_col;

	if (pl.ammo_uranium == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	if (selected) {
		drawsubpic(pos, [170,45], g_hud5_spr, [0,135/256], [170/256,45/256], hud_col, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], g_hud2_spr, [0,135/256], [170/256,45/256], hud_col, a, DRAWFLAG_ADDITIVE);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_uranium, MAX_A_URANIUM, a);
#endif
}

weapon_t w_egon =
{
	.name		= "egon",
	.id		= ITEM_EGON,
	.slot		= 3,
	.slot_pos	= 2,
	.draw		= w_egon_draw,
	.holster	= w_egon_holster,
	.primary	= w_egon_primary,
	.secondary	= w_egon_release,
	.reload		= w_egon_reload,
	.release	= w_egon_release,
	.crosshair	= w_egon_crosshair,
	.precache	= w_egon_precache,
	.pickup		= w_egon_pickup,
	.updateammo	= w_egon_updateammo,
	.wmodel		= w_egon_wmodel,
	.pmodel		= w_egon_pmodel,
	.deathmsg	= w_egon_deathmsg,
	.aimanim	= w_egon_aimanim,
	.hudpic		= w_egon_hudpic
};

#ifdef SERVER
void weapon_egon(void) {
	Weapons_InitItem(WEAPON_EGON);
}
#endif
