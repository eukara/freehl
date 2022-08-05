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

/*QUAKED weapon_gauss (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_gauss.mdl"

HALF-LIFE (1998) ENTITY

Gauss Weapon

*/

enum
{
	GAUSS_IDLE1,
	GAUSS_IDLE2,
	GAUSS_FIDGET,
	GAUSS_SPINUP,
	GAUSS_SPIN,
	GAUSS_FIRE1,
	GAUSS_FIRE2,
	GAUSS_HOLSTER,
	GAUSS_DRAW
};

void w_gauss_release(player pl);

void w_gauss_precache(void)
{
#ifdef SERVER
	precache_model("models/w_gauss.mdl");
	precache_model("sprites/yelflare1.spr");
	precache_model("sprites/xbeam1.spr");
	precache_sound("weapons/electro4.wav");
	precache_sound("weapons/electro5.wav");
	precache_sound("weapons/electro6.wav");
	precache_sound("weapons/gauss2.wav");
	Sound_Precache("weapon_gauss.empty");
#else
	precache_sound("ambience/pulsemachine.wav");
	precache_model("models/v_gauss.mdl");
	precache_model("models/p_gauss.mdl");
#endif
}
void w_gauss_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, pl.ammo_uranium, -1);
}
string w_gauss_wmodel(void)
{
	return "models/w_gauss.mdl";
}
string w_gauss_pmodel(player pl)
{
	return "models/p_gauss.mdl";
}
string w_gauss_deathmsg(void)
{
	return "";
}

int w_gauss_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (pl.ammo_uranium < MAX_A_URANIUM) {
		pl.ammo_uranium = bound(0, pl.ammo_uranium + 20, MAX_A_URANIUM);
	} else {
		if (!new)
			return (0);
	}
#endif
	return (1);
}

void w_gauss_draw(player pl)
{
	pl.mode_tempstate = 0;
	Weapons_SetModel("models/v_gauss.mdl");
	Weapons_ViewAnimation(pl, GAUSS_DRAW);
}

void w_gauss_holster(player pl)
{
	Weapons_ViewAnimation(pl, GAUSS_HOLSTER);
}

#ifdef SERVER
void w_gauss_fire(player pl, int one)
{
	int iLoop = 6;

	Weapons_MakeVectors(pl);
	vector src = Weapons_GetCameraPos(pl);
	vector endpos = src + v_forward * 1024;
	traceline(src, endpos, FALSE, pl);

	sound(pl, CHAN_WEAPON, "weapons/gauss2.wav", 1, ATTN_NORM);
	int iDamage = one ? 20 : 200;

	if (serverkeyfloat("*bspversion") == BSPVER_HL)
		if (getsurfacetexture(trace_ent, getsurfacenearpoint(trace_ent, trace_endpos)) == "sky") {
			return;
		}

	if (trace_ent.takedamage == DAMAGE_YES) {
		Damage_Apply(trace_ent, pl, iDamage, WEAPON_GAUSS, DMG_ELECTRO);
		sound(trace_ent, CHAN_ITEM, sprintf("weapons/electro%d.wav", random(0,3)+4), 1, ATTN_NORM);
	}

	if (one) {
		return;
	} else {
		/* Apply force */
		if (pl.flags & FL_ONGROUND) {
			pl.velocity += v_forward * -400;
		} else {
			pl.velocity += v_forward * -800;
		}
	}

	// reflection equation:
	vector dir = v_forward;
	while (iLoop > 0) {
		float n;
		vector r;
		n = -dotproduct(trace_plane_normal, dir);
		r = 2 * trace_plane_normal * n + dir;
		dir = r;
		src = trace_endpos + (dir * 1);
		endpos = trace_endpos + (dir * 8192);
		traceline(src, endpos, FALSE, pl);
		iLoop--;
		if (trace_ent.takedamage == DAMAGE_YES) {
			Damage_Apply(trace_ent, pl, iDamage, WEAPON_GAUSS, DMG_ELECTRO);
			sound(trace_ent, CHAN_ITEM, sprintf("weapons/electro%d.wav", random(0,3)+4), 1, ATTN_NORM);
		}
	}
}
#endif

void w_gauss_primary(player pl)
{
	if (pl.w_attack_next > 0.0)
		return;
	if (pl.gflags & GF_SEMI_TOGGLED)
		return;

	/* Ammo check */
	if ((pl.ammo_uranium < 2) || (pl.WaterLevel() >= WATERLEVEL_SUBMERGED)) {
#ifdef SERVER
		Sound_Play(pl, CHAN_WEAPON, "weapon_gauss.empty");
#endif
		pl.gflags |= GF_SEMI_TOGGLED;
		return;
	}

	Weapons_ViewAnimation(pl, GAUSS_FIRE2);
	Weapons_ViewPunchAngle(pl, [-2,0,0]);
#ifdef SERVER
	w_gauss_fire(pl, 1);
	FX_GaussBeam(Weapons_GetCameraPos(pl), input_angles, 0, pl);
#endif

	pl.ammo_uranium -= 2;

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CR_SHOOTGAUSS, 0.43f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOTGAUSS, 0.43f);

	pl.w_attack_next = 0.2f;
	pl.w_idle_next = 2.5f;
}

void w_gauss_release(player pl)
{
	if (pl.w_idle_next > 0.0) {
		return;
	}

	/* Reset the pitch sound shift */
	pl.ammo_gauss_volume = 0;

	if (pl.mode_tempstate == 1) {
		pl.w_attack_next = 0.0f;
		pl.w_idle_next = 4.0f;
		w_gauss_primary(pl);
		pl.mode_tempstate = 0;
		return;
	} else if (pl.mode_tempstate == 2) {
		Weapons_ViewAnimation(pl, GAUSS_FIRE1);

		if (pl.flags & FL_CROUCHING)
			Animation_PlayerTop(pl, ANIM_CR_SHOOTGAUSS, 0.43f);
		else
			Animation_PlayerTop(pl, ANIM_SHOOTGAUSS, 0.43f);
	
		Weapons_ViewPunchAngle(pl, [-5,0,0]);
#ifdef SERVER
		w_gauss_fire(pl, 0);
		FX_GaussBeam(Weapons_GetCameraPos(pl), input_angles, 6, pl);
#endif
		pl.w_attack_next = 1.5f;
		pl.w_idle_next = 4.0f;
		pl.mode_tempstate = 0;
		return;
	}

	int r = floor(pseudorandom() * 3.0f);
	switch (r) {
	case 1:
		Weapons_ViewAnimation(pl, GAUSS_IDLE2);
		pl.w_idle_next = 4.0f;
		break;
#ifndef GEARBOX
	case 2:
		Weapons_ViewAnimation(pl, GAUSS_FIDGET);
		pl.w_idle_next = 3.0f;
		break;
#endif
	default:
		Weapons_ViewAnimation(pl, GAUSS_IDLE1);
		pl.w_idle_next = 4.0f;
		break;
	}
}

void w_gauss_secondary(player pl)
{
	if (pl.w_attack_next > 0.0)
		return;
	if (pl.gflags & GF_SEMI_TOGGLED)
		return;

	/* Ammo check */
	if ((pl.ammo_uranium <= 0) || (pl.WaterLevel() >= WATERLEVEL_SUBMERGED)) {
#ifdef SERVER
		Sound_Play(pl, CHAN_WEAPON, "weapon_gauss.empty");
#endif
		pl.gflags |= GF_SEMI_TOGGLED;
		return;
	}

	pl.w_attack_next = 0.1f;

	/* Ammo check */
	if (pl.ammo_uranium <= 0) {
		if (pl.mode_tempstate > 0) {
		w_gauss_release(pl);
		}
			return;
	}

	if (pl.ammo_gauss_volume < 10)
		pl.ammo_uranium--;

	/* Set pitch sound shift */
	pl.ammo_gauss_volume += 1;
	if (pl.ammo_gauss_volume > 100) {
		pl.ammo_gauss_volume = 100;
#ifdef SERVER
		Damage_Apply(pl, pl, 10, DMG_ELECTRO, WEAPON_GAUSS);
#endif
		pl.mode_tempstate = 0;
		pl.w_attack_next = 0.5f;
		pl.w_idle_next = 0.5f;
		pl.ammo_gauss_volume = 0;
		Weapons_ViewAnimation(pl, GAUSS_IDLE1);
	}

	if (pl.mode_tempstate == 1) {
		Weapons_ViewAnimation(pl, GAUSS_SPIN);
		pl.mode_tempstate = 2;
	} else if (!pl.mode_tempstate) {
		Weapons_ViewAnimation(pl, GAUSS_SPINUP);
		pl.mode_tempstate = 1;
	}
}

void w_gauss_crosshair(player pl)
{
#ifdef CLIENT
	vector cross_pos;
	vector aicon_pos;

	cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];
	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];

	drawsubpic(
		cross_pos,
		[24,24],
		g_cross_spr,
		[48/128,48/128],
		[0.1875, 0.1875],
		[1,1,1],
		1,
		DRAWFLAG_NORMAL
	);

	drawsubpic(
		aicon_pos,
		[24,24],
		g_hud7_spr,
		[0,96/128],
		[24/256,24/128],
		g_hud_color,
		pSeatLocal->m_flAmmo2Alpha,
		DRAWFLAG_ADDITIVE
	);

	HUD_DrawAmmo2();
#endif
}

float w_gauss_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? ANIM_CR_AIMGAUSS : ANIM_AIMGAUSS;
}

void w_gauss_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (pl.ammo_uranium == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud5_spr,
			[0,90/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			g_hud2_spr,
			[0,90/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_uranium, MAX_A_URANIUM, a);
#endif
}

int
w_gauss_isempty(player pl)
{

	if (pl.ammo_uranium <= 0)
		return 1;

	return 0;
}

weapontype_t
w_gauss_type(player pl)
{
	return WPNTYPE_RANGED;
}

weapon_t w_gauss =
{
	.name		= "gauss",
	.id		= ITEM_GAUSS,
	.slot		= 3,
	.slot_pos	= 1,
	.weight		= 20,
	.draw		= w_gauss_draw,
	.holster	= w_gauss_holster,
	.primary	= w_gauss_primary,
	.secondary	= w_gauss_secondary,
	.reload		= __NULL__,
	.release	= w_gauss_release,
	.postdraw	= w_gauss_crosshair,
	.precache	= w_gauss_precache,
	.pickup		= w_gauss_pickup,
	.updateammo	= w_gauss_updateammo,
	.wmodel		= w_gauss_wmodel,
	.pmodel		= w_gauss_pmodel,
	.deathmsg	= w_gauss_deathmsg,
	.aimanim	= w_gauss_aimanim,
	.isempty	= w_gauss_isempty,
	.type		= w_gauss_type,
	.hudpic		= w_gauss_hudpic
};

#ifdef SERVER
void weapon_gauss(void) {
	Weapons_InitItem(WEAPON_GAUSS);
}
#endif
