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
	GLOCK_IDLE1,
	GLOCK_IDLE2,
	GLOCK_IDLE3,
	GLOCK_SHOOT,
	GLOCK_SHOOT_EMPTY,
	GLOCK_RELOAD_EMPTY,
	GLOCK_RELOAD,
	GLOCK_DRAW,
	GLOCK_HOLSTER
};

#ifdef CLIENT
void w_glock_ejectshell(void)
{
	static void w_glock_ejectshell_death(void) {
		remove(self);
	}
	static void w_glock_ejectshell_touch(void) {
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

	makevectors(pSeat->m_eViewModel.angles);
	eShell.velocity += (v_forward * 0);
	eShell.velocity += (v_right * 80);
	eShell.velocity += (v_up * 100);
	eShell.touch = w_glock_ejectshell_touch;

	eShell.avelocity = [0,45,900];
	eShell.think = w_glock_ejectshell_death;
	eShell.nextthink = time + 2.5f;
	setsize(eShell, [0,0,0], [0,0,0]);
	setorigin(eShell, pSeat->m_eViewModel.origin + (v_forward * 26) + (v_right * 8) + (v_up * -4));
}
#endif

void
w_glock_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_glock.fire");
	Sound_Precache("weapon_glock.empty");
	precache_model("models/w_9mmhandgun.mdl");
	precache_model("models/shell.mdl");
#else
	precache_model("models/v_9mmhandgun.mdl");
	precache_model("models/p_9mmhandgun.mdl");
	precache_model("models/shell.mdl");
	Sound_Precache("modelevent_shell.land");
#endif
}

void
w_glock_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.glock_mag, pl.ammo_9mm, -1);
}

string
w_glock_wmodel(void)
{
	return "models/w_9mmhandgun.mdl";
}

string
w_glock_pmodel(player pl)
{
	return "models/p_9mmhandgun.mdl";
}

string
w_glock_deathmsg(void)
{
	return "";
}

int
w_glock_pickup(player pl, int new, int startammo)
{
#ifdef SERVER
	int addAmmo = (startammo == -1) ? 18 : startammo;

	if (new) {
		pl.glock_mag = addAmmo;
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
w_glock_draw(player pl)
{
	Weapons_SetModel("models/v_9mmhandgun.mdl");
	Weapons_ViewAnimation(pl, GLOCK_DRAW);
}

void
w_glock_holster(player pl)
{
	Weapons_ViewAnimation(pl, GLOCK_HOLSTER);
}

int
w_glock_isempty(player pl)
{
	if (pl.glock_mag <= 0 && pl.ammo_9mm <= 0)
		return 1;

	return 0;
}

void
w_glock_primary(player pl)
{
	if (pl.w_attack_next > 0.0)
		return;
	if (pl.gflags & GF_SEMI_TOGGLED)
		return;

	/* ammo check */
	if ((pl.glock_mag <= 0i) ? true : false) {
#ifdef SERVER
		Sound_Play(pl, CHAN_AUTO, "weapon_glock.empty");
#endif
		pl.gflags |= GF_SEMI_TOGGLED;
		return;
	}

	/* actual firing */
	pl.glock_mag--;

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_glock_ejectshell, 0.0f);
#else
	TraceAttack_FireBulletsWithDecal(1, pl.origin + pl.view_ofs, Skill_GetValue("plr_9mm_bullet", 8), [0.01,0.01], WEAPON_GLOCK, "Impact.BigShot");
	Sound_Play(pl, CHAN_WEAPON, "weapon_glock.fire");
#endif

	Weapons_ViewPunchAngle(pl, [-2,0,0]);

	if (pl.glock_mag) {
		Weapons_ViewAnimation(pl, GLOCK_SHOOT);
	} else {
		Weapons_ViewAnimation(pl, GLOCK_SHOOT_EMPTY);
	}

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);

	pl.w_attack_next = 0.3f;
	pl.w_idle_next = 5.0f;
}

void
w_glock_secondary(player pl)
{
	if (pl.w_attack_next > 0.0)
		return;
	if (pl.gflags & GF_SEMI_TOGGLED)
		return;

	/* ammo check */
	if ((pl.glock_mag <= 0i) ? true : false) {
#ifdef SERVER
		Sound_Play(pl, CHAN_AUTO, "weapon_glock.empty");
#endif
		pl.gflags |= GF_SEMI_TOGGLED;
		return;
	}

	pl.glock_mag--;

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_glock_ejectshell, 0.0f);
#else
	TraceAttack_FireBulletsWithDecal(1, pl.origin + pl.view_ofs, Skill_GetValue("plr_9mm_bullet", 8), [0.1,0.1], WEAPON_GLOCK, "Impact.BigShot");
	Sound_Play(pl, CHAN_WEAPON, "weapon_glock.fire");
#endif

	Weapons_ViewPunchAngle(pl, [-2,0,0]);

	if (pl.glock_mag) {
		Weapons_ViewAnimation(pl, GLOCK_SHOOT);
	} else {
		Weapons_ViewAnimation(pl, GLOCK_SHOOT_EMPTY);
	}

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);

	pl.w_attack_next = 0.2f;
	pl.w_idle_next = 5.0f;
}

void
w_glock_reload(player pl)
{
	if (pl.w_attack_next > 0.0) {
		return;
	}

	if (pl.glock_mag >= 18) {
		return;
	}
	if (pl.ammo_9mm <= 0) {
		return;
	}

	if (pl.glock_mag) {
		Weapons_ViewAnimation(pl, GLOCK_RELOAD);
	} else {
		Weapons_ViewAnimation(pl, GLOCK_RELOAD_EMPTY);
	}

#ifdef SERVER
	static void w_glock_reload_done(void) {
		player pl = (player)self;
		Weapons_ReloadWeapon(pl, player::glock_mag, player::ammo_9mm, 18);
	}

	pl.think = w_glock_reload_done;
	pl.nextthink = time + 1.9f;
#endif

	pl.w_attack_next = 2.0f;
	pl.w_idle_next = 10.0f;
}

void
w_glock_release(player pl)
{
	int r;

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.glock_mag == 0 && pl.ammo_9mm > 0) {
		Weapons_Reload(pl);
		return;
	}

	if (w_glock_isempty(pl))
		return;
	if (pl.w_idle_next > 0.0)
		return;

	r = floor(pseudorandom() * 3.0f);
	switch (r) {
	case 1:
		Weapons_ViewAnimation(pl, GLOCK_IDLE2);
		pl.w_idle_next = 2.5f;
		break;
	case 2:
		Weapons_ViewAnimation(pl, GLOCK_IDLE3);
		pl.w_idle_next = 3.5f;
		break;
	default:
		Weapons_ViewAnimation(pl, GLOCK_IDLE1);
		pl.w_idle_next = 3.75f;
		break;
	}
}

float
w_glock_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_glock_hud(player pl)
{
#ifdef CLIENT
	vector aicon_pos;

	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];

	Cross_DrawSub(g_cross_spr, [24,24], [0.1875,0], [0.1875, 0.1875]);

	HUD_DrawAmmo1();
	HUD_DrawAmmo2();

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
#endif
}

void
w_glock_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (pl.glock_mag == 0 && pl.ammo_9mm == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud4_spr,
			[0,45/256],
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
			[0,45/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_9mm, MAX_A_9MM, a);
#endif
}

weapontype_t
w_glock_type(player pl)
{
	return WPNTYPE_RANGED;
}

weapon_t w_glock =
{
	.name		= "9mmhandgun",
	.id			= ITEM_GLOCK,
	.slot		= 1,
	.slot_pos	= 0,
	.weight		= 10,
	.draw		= w_glock_draw,
	.holster	= w_glock_holster,
	.primary	= w_glock_primary,
	.secondary	= w_glock_secondary,
	.reload		= w_glock_reload,
	.release	= w_glock_release,
	.postdraw	= w_glock_hud,
	.precache	= w_glock_precache,
	.pickup		= w_glock_pickup,
	.updateammo	= w_glock_updateammo,
	.wmodel		= w_glock_wmodel,
	.pmodel		= w_glock_pmodel,
	.deathmsg	= w_glock_deathmsg,
	.aimanim	= w_glock_aimanim,
	.isempty	= w_glock_isempty,
	.type		= w_glock_type,
	.hudpic		= w_glock_hudpic
};
