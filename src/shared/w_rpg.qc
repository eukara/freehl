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

enum
{
	RPG_IDLE,
	RPG_FIDGET,
	RPG_RELOAD,
	RPG_FIRE2,
	RPG_HOLSTER1,
	RPG_DRAW1,
	RPG_HOLSTER2,
	RPG_DRAW_UL,
	RPG_IDLE_UL,
	RPG_FIDGET_UL,
};

void w_rpg_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_rpg.shoot");
	Sound_Precache("weapon_rpg.empty");
	precache_model("models/w_rpg.mdl");
	precache_model("models/rpgrocket.mdl");
	Sound_Precache("fx.explosion");
#else
	precache_model("models/v_rpg.mdl");
	precache_model("models/p_rpg.mdl");
	precache_model("sprites/laserdot.spr");
#endif
}

void w_rpg_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.rpg_mag, pl.ammo_rocket, -1);
}
string w_rpg_wmodel(void)
{
	return "models/w_rpg.mdl";
}
string w_rpg_pmodel(player pl)
{
	return "models/p_rpg.mdl";
}
string w_rpg_deathmsg(void)
{
	return "";
}

int w_rpg_pickup(player pl, int new, int startammo)
{
#ifdef SERVER
	int addAmmo = (startammo == -1) ? 2 : startammo;

	if (new) {
		if (addAmmo > 1) {
			pl.rpg_mag = 1;
			pl.ammo_rocket = bound(0, pl.ammo_rocket + 1, MAX_A_ROCKET);
		} else {
			pl.rpg_mag = addAmmo;
		}
		return (1);
	}

	if (pl.ammo_rocket < MAX_A_ROCKET) {
		pl.ammo_rocket = bound(0, pl.ammo_rocket + 2, MAX_A_ROCKET);
	} else {
		if (!new)
			return (0);
	}
#endif
	return (1);
}

void w_rpg_draw(player pl)
{
	Weapons_SetModel("models/v_rpg.mdl");
	Weapons_ViewAnimation(pl, RPG_DRAW1);
	pl.ammo_rpg_state = 1;
}

void w_rpg_holster(player pl)
{
	
}

void w_rpg_primary(player pl)
{
	if (pl.w_attack_next > 0.0)
		return;
	if (pl.gflags & GF_SEMI_TOGGLED)
		return;

	/* ammo check */
	if ((pl.rpg_mag <= 0i) ? true : false) {
#ifdef SERVER
		Sound_Play(pl, CHAN_AUTO, "weapon_rpg.empty");
#endif
		pl.gflags |= GF_SEMI_TOGGLED;
		return;
	}

	pl.rpg_mag--;

#ifdef SERVER
	if (pl.ammo_rpg_state > 0) {
		NSProjectile_SpawnDef("projectile_rocket_homing", pl);
	} else {
		NSProjectile_SpawnDef("projectile_rocket", pl);
	}

	Sound_Play(pl, CHAN_WEAPON, "weapon_rpg.shoot");
#endif

	Weapons_ViewAnimation(pl, RPG_FIRE2);
	Weapons_ViewPunchAngle(pl, [-10,0,0]);

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CR_SHOOTRPG, 0.43f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOTRPG, 0.43f);

	pl.w_attack_next = 
	pl.w_idle_next = 2.5f;
}

void w_rpg_reload(player pl)
{
	if (pl.w_attack_next > 0) {
		return;
	}

	/* Ammo check */
	if (pl.rpg_mag >= 1) {
		return;
	}
	if (pl.ammo_rocket <= 0) {
		return;
	}

	Weapons_ViewAnimation(pl, RPG_RELOAD);

	/* Audio-Visual Bit */
#ifdef SERVER
	static void w_rpg_reload_done(void) {
		player pl = (player)self;
		Weapons_ReloadWeapon(pl, player::rpg_mag, player::ammo_rocket, 1);
	}

	pl.think = w_rpg_reload_done;
	pl.nextthink = time + 2.15f;
#endif

	pl.w_attack_next = 2.25f;
	pl.w_idle_next = 10.0f;
}

void w_rpg_release(player pl)
{
	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.rpg_mag == 0 && pl.ammo_rocket > 0) {
		Weapons_Reload(pl);
		return;
	}

	if (pl.w_idle_next > 0.0) {
		return;
	}

	int r = floor(pseudorandom() * 3.0f);

	if (pl.rpg_mag > 0) {
		if (r == 1) {
			Weapons_ViewAnimation(pl, RPG_FIDGET);
		} else {
			Weapons_ViewAnimation(pl, RPG_IDLE);
		}
	} else {
		if (r == 1) {
			Weapons_ViewAnimation(pl, RPG_FIDGET_UL);
		} else {
			Weapons_ViewAnimation(pl, RPG_IDLE_UL);
		}
	}
}

void w_rpg_secondary(player pl)
{

	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* toggle laser */
	pl.ammo_rpg_state = 1 - pl.ammo_rpg_state;

	pl.w_attack_next = 0.25f;
	w_rpg_release(pl);
}

float w_rpg_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? ANIM_CR_AIMRPG : ANIM_AIMRPG;
}

void w_rpg_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (pl.rpg_mag == 0 && pl.ammo_rocket == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	if (selected) {
		drawsubpic(pos, [170,45], g_hud5_spr, [0,45/256], [170/256,45/256], hud_col, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], g_hud2_spr, [0,45/256], [170/256,45/256], hud_col, a, DRAWFLAG_ADDITIVE);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_rocket, MAX_A_ROCKET, a);
#endif
}

void w_rpg_hud(player pl)
{
#ifdef CLIENT
	vector laser_pos;
	vector aicon_pos;

	/* crosshair/laser */
	if (pl.ammo_rpg_state == 1) {
		float lerp;
		vector jitter = [0.0f, 0.0f, 0.0f];
		Weapons_MakeVectors(pl);
		vector src = pl.origin + pl.view_ofs;
		traceline(src, src + (v_forward * 256), FALSE, pl);
		lerp = Math_Lerp(18,6, trace_fraction);
		jitter[0] = (random(0,2) - 2) * (1 - trace_fraction);
		jitter[1] = (random(0,2) - 2) * (1 - trace_fraction);
		laser_pos = g_hudmins + (g_hudres / 2) + ([-lerp,-lerp] / 2);

		drawsubpic(
			laser_pos + jitter,
			[lerp,lerp],
			g_laser_spr,
			[0,0],
			[1.0, 1.0],
			[1,1,1],
			1.0f,
			DRAWFLAG_ADDITIVE
		);

		Cross_DrawSub(g_cross_spr, [24,24], [24/128,48/128], [0.1875, 0.1875]);
	} else {
		Cross_DrawSub(g_cross_spr, [24,24], [24/128,48/128], [0.1875, 0.1875]);
	}

	/* ammo counters */
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();

	/* ammo icon */
	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(
		aicon_pos,
		[24,24],
		"sprites/640hud7.spr_0.tga",
		[120/256,72/128],
		[24/256, 24/128],
		g_hud_color,
		pSeatLocal->m_flAmmo2Alpha,
		DRAWFLAG_ADDITIVE
	);
#endif
}

int
w_rpg_isempty(player pl)
{

	if (pl.rpg_mag <= 0 && pl.ammo_rocket <= 0)
		return 1;

	return 0;
}

weapontype_t
w_rpg_type(player pl)
{
	return WPNTYPE_RANGED;
}

weapon_t w_rpg =
{
	.name		= "rpg_rocket",
	.id			= ITEM_RPG,
	.slot		= 3,
	.slot_pos	= 0,
	.weight		= 20,
	.draw		= w_rpg_draw,
	.holster	= w_rpg_holster,
	.primary	= w_rpg_primary,
	.secondary	= w_rpg_secondary,
	.reload		= w_rpg_reload,
	.release	= w_rpg_release,
	.postdraw	= w_rpg_hud,
	.precache	= w_rpg_precache,
	.pickup		= w_rpg_pickup,
	.updateammo	= w_rpg_updateammo,
	.wmodel		= w_rpg_wmodel,
	.pmodel		= w_rpg_pmodel,
	.deathmsg	= w_rpg_deathmsg,
	.aimanim	= w_rpg_aimanim,
	.isempty	= w_rpg_isempty,
	.type		= w_rpg_type,
	.hudpic		= w_rpg_hudpic
};
