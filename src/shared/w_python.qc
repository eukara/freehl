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

/*QUAKED weapon_357 (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_357.mdl"

HALF-LIFE (1998) ENTITY

357/Python Weapon
Same as weapon_python

*/

/*QUAKED weapon_python (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_357.mdl"

HALF-LIFE (1998) ENTITY

357/Python Weapon
Same as weapon_357

*/

enum
{
	PYTHON_IDLE1,
	PYTHON_FIDGET,
	PYTHON_FIRE1,
	PYTHON_RELOAD,
	PYTHON_HOLSTER,
	PYTHON_DRAW,
	PYTHON_IDLE2,
	PYTHON_IDLE3
};

void
w_python_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_357.shoot");
	Sound_Precache("weapon_357.reload");
	precache_model("models/w_357.mdl");
#else
	precache_model("models/v_357.mdl");
	precache_model("models/p_357.mdl");
#endif
}

int
w_python_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		pl.python_mag = 6;
	} else {
		if (pl.ammo_357 < MAX_A_357) {
			pl.ammo_357 = bound(0, pl.ammo_357 + 6, MAX_A_357);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_python_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.python_mag, pl.ammo_357, -1);
}

string
w_python_wmodel(void)
{
	return "models/w_357.mdl";
}

string
w_python_pmodel(void)
{
	return "models/p_357.mdl";
}

string
w_python_deathmsg(void)
{
	return "";
}

void
w_python_draw(void)
{
#ifdef CLIENT
	Weapons_SetModel("models/v_357.mdl");

	/* singleplayer doesn't do scope */
	if (cvar("sv_playerslots") == 1) {
		Weapons_SetGeomset("geomset 4 1\n");
	} else {
		Weapons_SetGeomset("geomset 4 2\n");
	}
	Weapons_ViewAnimation(PYTHON_DRAW);
#endif
}

void
w_python_holster(void)
{
#ifdef CLIENT
	Weapons_ViewAnimation(PYTHON_HOLSTER);
#endif
}

void
w_python_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* Ammo check */
	if (pl.python_mag <= 0) {
		return;
	}

	pl.python_mag--;

	/* Actual firing */
#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_SMALL);
	Weapons_ViewPunchAngle([-10,0,0]);
	Weapons_ViewAnimation(PYTHON_FIRE1);
#else
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, Skill_GetValue("plr_357_bullet", 40), [0.008, 0.008], WEAPON_PYTHON);
	Sound_Play(pl, CHAN_WEAPON, "weapon_357.shoot");
#endif

	pl.w_attack_next = 0.75f;
	pl.w_idle_next = 10.0f;
}

void
w_python_secondary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* singleplayer doesn't do scope */
	if (cvar("sv_playerslots") == 1) {
		return;
	}

	/* Simple toggle of fovs */
	if (pl.viewzoom == 1.0f) {
		pl.viewzoom = 0.5f;
	} else {
		pl.viewzoom = 1.0f;
	}

	pl.w_attack_next = 0.25f;
}

void
w_python_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* Ammo check */
	if (pl.python_mag >= 6) {
		return;
	}
	if (pl.ammo_357 <= 0) {
		return;
	}

	/* Audio-Visual bit */
#ifdef CLIENT
	Weapons_ViewAnimation(PYTHON_RELOAD);
#else
	Sound_Play(pl, CHAN_WEAPON, "weapon_357.reload");
	Weapons_ReloadWeapon(pl, player::python_mag, player::ammo_357, 6);
#endif

	pl.w_attack_next = 3.25f;
	pl.w_idle_next = 10.0f;
}

void
w_python_release(void)
{
	player pl = (player)self;

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.python_mag == 0 && pl.ammo_357 > 0) {
		Weapons_Reload();
		return;
	}

	if (pl.w_idle_next > 0.0) {
		return;
	}

	int r = (float)input_sequence % 4;

	switch (r) {
	case 1:
		Weapons_ViewAnimation(PYTHON_IDLE1);
		pl.w_idle_next = 2.33f;
		break;
	case 2:
		Weapons_ViewAnimation(PYTHON_FIDGET);
		pl.w_idle_next = 5.66f;
		break;
	case 3:
		Weapons_ViewAnimation(PYTHON_IDLE2);
		pl.w_idle_next = 2.0f;
		break;
	default:
		Weapons_ViewAnimation(PYTHON_IDLE3);
		pl.w_idle_next = 2.93f;
		break;
	}
}

void
w_python_crosshair(void)
{
#ifdef CLIENT
	vector cross_pos;
	vector aicon_pos;

	cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];
	drawsubpic(
		cross_pos,
		[24,24],
		g_cross_spr,
		[48/128,0],
		[0.1875, 0.1875],
		[1,1,1],
		1,
		DRAWFLAG_NORMAL
	);

	HUD_DrawAmmo1();
	HUD_DrawAmmo2();

	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(
		aicon_pos,
		[24,24],
		g_hud7_spr,
		[24/256,72/128],
		[24/256, 24/128],
		g_hud_color,
		pSeat->m_flAmmo2Alpha,
		DRAWFLAG_ADDITIVE
	);
#endif
}

float
w_python_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMPYTHON : ANIM_AIMPYTHON;
}

void
w_python_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;
	vector hud_col;

	if (pl.python_mag == 0 && pl.ammo_357 == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud4_spr,
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
			g_hud1_spr,
			[0,90/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_357, MAX_A_357, a);
#endif
}

weapon_t w_python =
{
	.name		= "357",
	.id		= ITEM_PYTHON,
	.slot		= 1,
	.slot_pos	= 1,
	.draw		= w_python_draw,
	.holster	= w_python_holster,
	.primary	= w_python_primary,
	.secondary	= w_python_secondary,
	.reload		= w_python_reload,
	.release	= w_python_release,
	.crosshair	= w_python_crosshair,
	.precache	= w_python_precache,
	.pickup		= w_python_pickup,
	.updateammo	= w_python_updateammo,
	.wmodel		= w_python_wmodel,
	.pmodel		= w_python_pmodel,
	.deathmsg	= w_python_deathmsg,
	.aimanim	= w_python_aimanim,
	.hudpic		= w_python_hudpic
};

/* pickups */
#ifdef SERVER
void
weapon_357(void)
{
	Weapons_InitItem(WEAPON_PYTHON);
}

void
weapon_python(void)
{
	Weapons_InitItem(WEAPON_PYTHON);
}
#endif
