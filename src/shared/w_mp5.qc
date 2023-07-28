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
	MP5_IDLE1,
	MP5_IDLE2,
	MP5_GRENADE,
	MP5_RELOAD,
	MP5_DRAW,
#ifdef GEARBOX
	MP5_DEPLOY, /* not sure what this is about */
#endif
	MP5_FIRE1,
	MP5_FIRE2,
	MP5_FIRE3
};

#ifdef CLIENT
void w_mp5_ejectshell(void)
{
	static void w_mp5_ejectshell_death(void) {
		remove(self);
	}
	static void w_mp5_ejectshell_touch(void) {
		if (other == world)
			Sound_Play(self, CHAN_BODY, "modelevent_shell.land");
	}
	entity eShell = spawn();
	setmodel(eShell, "models/shell.mdl");
	eShell.solid = SOLID_BBOX;
	eShell.movetype = MOVETYPE_BOUNCE;
	eShell.drawmask = MASK_ENGINE;
	eShell.angles = [pSeat->m_eViewModel.angles[0], pSeat->m_eViewModel.angles[1], 0];
	eShell.velocity = pSeat->m_vecPredictedVelocity;

	float r = random(0.0, 50.0);
	makevectors(pSeat->m_eViewModel.angles);
	eShell.velocity += (v_forward * 0);
	eShell.velocity += (v_right * 45);
	eShell.velocity += (v_up * (145 + r));
	eShell.touch = w_mp5_ejectshell_touch;

	eShell.avelocity = [0,45,900];
	eShell.think = w_mp5_ejectshell_death;
	eShell.nextthink = time + 2.5f;
	setsize(eShell, [0,0,0], [0,0,0]);
	setorigin(eShell, pSeat->m_eViewModel.origin + (v_forward * 30) + (v_right * 8) + (v_up * -15));
}
#endif

void
w_mp5_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_mp5.shoot");
	Sound_Precache("weapon_mp5.gl");
	Sound_Precache("weapon_mp5.empty");
	precache_model("models/w_9mmar.mdl");
	precache_model("models/grenade.mdl");
#else
	precache_model("models/v_9mmar.mdl");
	precache_model("models/p_9mmar.mdl");
	Sound_Precache("modelevent_shell.land");
#endif
}

int
w_mp5_pickup(player pl, int new, int startammo)
{
#ifdef SERVER
#ifdef GEARBOX
	int addAmmo = (startammo == -1) ? 50 : startammo;
#else
	int addAmmo = (startammo == -1) ? 25 : startammo;
#endif

	if (new) {
		pl.mp5_mag = addAmmo;
		return (1);
	}

	if (pl.ammo_9mm < MAX_A_9MM) {
		pl.ammo_9mm = bound(0, pl.ammo_9mm + addAmmo, MAX_A_9MM);
	} else {
		if (!new)
			return (0);
	}
#endif
	return (1);
}

void
w_mp5_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.mp5_mag, pl.ammo_9mm, pl.ammo_m203_grenade);
}

string
w_mp5_wmodel(void)
{
	return "models/w_9mmar.mdl";
}

string
w_mp5_pmodel(player pl)
{
	return "models/p_9mmar.mdl";
}

string
w_mp5_deathmsg(void)
{
	return "";
}

void
w_mp5_draw(player pl)
{
	Weapons_SetModel("models/v_9mmar.mdl");
	Weapons_ViewAnimation(pl, MP5_DRAW);
}

void
w_mp5_holster(player pl)
{
	Weapons_ViewAnimation(pl, MP5_DRAW);
}

void
w_mp5_primary(player pl)
{
	if (pl.w_attack_next > 0.0f)
		return;
	if (pl.gflags & GF_SEMI_TOGGLED)
		return;

	/* Ammo check */
	bool out_of_ammo = (pl.mp5_mag <= 0i) ? true : false;
	if (out_of_ammo || (pl.WaterLevel() >= WATERLEVEL_SUBMERGED)) {
#ifdef SERVER
		Sound_Play(pl, CHAN_AUTO, "weapon_mp5.empty");
#endif
		pl.gflags |= GF_SEMI_TOGGLED;
		return;
	}

	pl.mp5_mag--;

	/* Actual firing */
	int r = floor(pseudorandom() * 3.0f);
	switch (r) {
	case 1:
		Weapons_ViewAnimation(pl, MP5_FIRE1);
		break;
	case 2:
		Weapons_ViewAnimation(pl, MP5_FIRE2);
		break;
	default:
		Weapons_ViewAnimation(pl, MP5_FIRE3);
		break;
	}

	Weapons_ViewPunchAngle(pl, [-2,0,0]);

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);
	View_AddEvent(w_mp5_ejectshell, 0.0f);
#else
	/* singleplayer is more accurate */
	if (cvar("sv_playerslots") == 1) {
		TraceAttack_FireBulletsWithDecal(1, Weapons_GetCameraPos(pl), Skill_GetValue("plr_9mmAR_bullet", 5), [0.025,0.025], WEAPON_MP5, "Impact.BigShot");
	} else {
		TraceAttack_FireBulletsWithDecal(1, Weapons_GetCameraPos(pl), Skill_GetValue("plr_9mmAR_bullet", 5), [0.05,0.05], WEAPON_MP5, "Impact.BigShot");
	}

	Sound_Play(pl, CHAN_WEAPON, "weapon_mp5.shoot");
#endif

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CR_SHOOTMP5, 0.1f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOTMP5, 0.1f);

	pl.w_attack_next = 0.085f;
	pl.w_idle_next = 10.0f;
}

void
w_mp5_secondary(player pl)
{
	if (pl.w_attack_next > 0.0f)
		return;
	if (pl.gflags & GF_SEMI_TOGGLED)
		return;

	/* Ammo check */
	bool out_of_ammo = (pl.ammo_m203_grenade <= 0i) ? true : false;
	if (out_of_ammo || pl.WaterLevel() >= WATERLEVEL_SUBMERGED) {
#ifdef SERVER
		Sound_Play(pl, CHAN_AUTO, "weapon_mp5.empty");
#endif
		pl.gflags |= GF_SEMI_TOGGLED;
		return;
	}

	pl.ammo_m203_grenade--;

#ifdef SERVER
	NSProjectile_SpawnDef("projectile_ARgrenade", pl);
	Sound_Play(pl, CHAN_WEAPON, "weapon_mp5.gl");
#endif

	Weapons_ViewPunchAngle(pl, [-10.0f, 0.0f, 0.0f]);
	Weapons_ViewAnimation(pl, MP5_GRENADE);

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CR_SHOOTMP5, 0.45f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOTMP5, 0.45f);

	pl.w_attack_next = 1.0f;
	pl.w_idle_next = 10.0f;
}

void
w_mp5_reload(player pl)
{
	if (pl.w_attack_next) {
		return;
	}

	/* Ammo check */
	if (pl.mp5_mag >= 50) {
		return;
	}
	if (pl.ammo_9mm <= 0) {
		return;
	}

	Weapons_ViewAnimation(pl, MP5_RELOAD);

#ifdef SERVER
	static void w_mp5_reload_done(void) {
		player pl = (player)self;
		Weapons_ReloadWeapon(pl, player::mp5_mag, player::ammo_9mm, 50);
	}

	pl.think = w_mp5_reload_done;
	pl.nextthink = time + 1.4f;
#endif

	pl.w_attack_next = 1.5f;
	pl.w_idle_next = 10.0f;
}

void
w_mp5_release(player pl)
{

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.mp5_mag == 0 && pl.ammo_9mm > 0) {
		Weapons_Reload(pl);
		return;
	}
	if (pl.w_idle_next > 0.0) {
		return;
	}

	int r = floor(pseudorandom() * 3.0f);
	if (r == 1) {
		Weapons_ViewAnimation(pl, MP5_IDLE1);
	} else {
		Weapons_ViewAnimation(pl, MP5_IDLE2);
	}

	pl.w_idle_next = 15.0f;
}

void
w_mp5_crosshair(player pl)
{
#ifdef CLIENT
	vector aicon_pos;

	Cross_DrawSub(g_cross_spr, [24,24], [0,48/128], [0.1875, 0.1875]);

	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	HUD_DrawAmmo3();

	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(
		aicon_pos,
		[24,24],
		g_hud7_spr,
		[0,72/128],
		[24/256, 24/128],
		g_hud_color,
		pSeatLocal->m_flAmmo2Alpha,
		DRAWFLAG_ADDITIVE
	);

	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 74];
	drawsubpic(
		aicon_pos,
		[24,24],
		g_hud7_spr,
		[48/256,72/128],
		[24/256, 24/128],
		g_hud_color,
		pSeatLocal->m_flAmmo3Alpha,
		DRAWFLAG_ADDITIVE
	);
#endif
}

float
w_mp5_aimanim(player pl)
{
	return pl.flags & ANIM_CR_AIMMP5 ? ANIM_CR_AIMCROWBAR : ANIM_AIMMP5;
}

void
w_mp5_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (pl.mp5_mag == 0 && pl.ammo_9mm == 0 && pl.ammo_m203_grenade == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud4_spr,
			[0,135/256],
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
			[0,135/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_9mm, MAX_A_9MM, a);
	HUD_DrawAmmoBar(pos + [25, 0], pl.ammo_m203_grenade, MAX_A_M203_GRENADE, a);
#endif
}

int
w_mp5_isempty(player pl)
{

	if (pl.mp5_mag <= 0 && pl.ammo_9mm <= 0 && pl.ammo_m203_grenade <= 0)
		return 1;

	return 0;
}

weapontype_t
w_mp5_type(player pl)
{
	return WPNTYPE_RANGED;
}

weapon_t w_mp5 =
{
	.name		= "9mmAR",
	.id			= ITEM_MP5,
	.slot		= 2,
	.slot_pos	= 0,
	.weight		= 15,
	.draw		= w_mp5_draw,
	.holster	= w_mp5_holster,
	.primary	= w_mp5_primary,
	.secondary	= w_mp5_secondary,
	.reload		= w_mp5_reload,
	.release	= w_mp5_release,
	.postdraw	= w_mp5_crosshair,
	.precache	= w_mp5_precache,
	.pickup		= w_mp5_pickup,
	.updateammo	= w_mp5_updateammo,
	.wmodel		= w_mp5_wmodel,
	.pmodel		= w_mp5_pmodel,
	.deathmsg	= w_mp5_deathmsg,
	.aimanim	= w_mp5_aimanim,
	.isempty	= w_mp5_isempty,
	.type		= w_mp5_type,
	.hudpic		= w_mp5_hudpic
};