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

/*QUAKED weapon_shotgun (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_shotgun.mdl"

HALF-LIFE (1998) ENTITY

Shotgun Weapon

*/

enum
{
	SHOTGUN_IDLE1,
	SHOTGUN_FIRE1,
	SHOTGUN_FIRE2,
	SHOTGUN_RELOAD,
	SHOTGUN_PUMP,
	SHOTGUN_START_RELOAD,
	SHOTGUN_DRAW,
	SHOTGUN_HOLSTER,
	SHOTGUN_IDLE2,
	SHOTGUN_IDLE3
};

enum
{
	SHOTTY_IDLE,
	SHOTTY_RELOAD_START,
	SHOTTY_RELOAD,
	SHOTTY_RELOAD_END,
	SHOTTY_COCKSOUND
};

#ifdef CLIENT
void w_shotgun_ejectshell(void)
{
	static void w_shotgun_ejectshell_death(void) {
		remove(self);
	}
	static void w_shotgun_ejectshell_touch(void) {
		if (other == world)
			Sound_Play(self, CHAN_BODY, "modelevent_shotgunshell.land");
	}
	entity eShell = spawn();
	setmodel(eShell, "models/shotgunshell.mdl");
	eShell.solid = SOLID_BBOX;
	eShell.movetype = MOVETYPE_BOUNCE;
	eShell.drawmask = MASK_ENGINE;
	eShell.angles = [pSeat->m_eViewModel.angles[0], pSeat->m_eViewModel.angles[1], 0];
	eShell.velocity = pSeat->m_vecPredictedVelocity;

	makevectors(pSeat->m_eViewModel.angles);
	eShell.velocity += (v_forward * 0);
	eShell.velocity += (v_right * 80);
	eShell.velocity += (v_up * 100);
	eShell.touch = w_shotgun_ejectshell_touch;

	eShell.avelocity = [0,45,900];
	eShell.think = w_shotgun_ejectshell_death;
	eShell.nextthink = time + 2.5f;
	setsize(eShell, [0,0,0], [0,0,0]);
	setorigin(eShell, pSeat->m_eViewModel.origin + (v_forward * 26) + (v_right * 8) + (v_up * -8));
}
#endif

void w_shotgun_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_shotgun.single");
	Sound_Precache("weapon_shotgun.double");
	Sound_Precache("weapon_shotgun.reload");
	Sound_Precache("weapon_shotgun.cock");
	precache_model("models/w_shotgun.mdl");
	precache_model("models/shotgunshell.mdl");
#else
	precache_model("models/v_shotgun.mdl");
	precache_model("models/p_shotgun.mdl");
	precache_model("models/shotgunshell.mdl");
	Sound_Precache("modelevent_shotgunshell.land");
#endif
}

void
w_shotgun_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.shotgun_mag, pl.ammo_buckshot, -1);
}

string
w_shotgun_wmodel(void)
{
	return "models/w_shotgun.mdl";
}

string
w_shotgun_pmodel(void)
{
	return "models/p_shotgun.mdl";
}

string
w_shotgun_deathmsg(void)
{
	return "";
}

int
w_shotgun_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		pl.shotgun_mag = 8;
	} else {
		if (pl.ammo_buckshot < MAX_A_BUCKSHOT) {
			pl.ammo_buckshot = bound(0, pl.ammo_buckshot + 8, MAX_A_BUCKSHOT);
		} else {
			return (0);
		}
	}
#endif
	return (1);
}

void
w_shotgun_draw(void)
{
	player pl = (player)self;
	pl.mode_tempstate = 0;

	Weapons_SetModel("models/v_shotgun.mdl");
	Weapons_ViewAnimation(SHOTGUN_DRAW);
}

void 
w_shotgun_holster(void)
{
	Weapons_ViewAnimation(SHOTGUN_HOLSTER);
}

void w_shotgun_release(void);

void
w_shotgun_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next) {
		w_shotgun_release();
		return;
	}

	/* interrupt reloading if no longer empty */
	if (pl.mode_tempstate == SHOTTY_RELOAD && pl.shotgun_mag >= 1) {
		pl.mode_tempstate = SHOTTY_RELOAD_END;
		w_shotgun_release();
		return;
	} else if (pl.mode_tempstate > SHOTTY_IDLE) {
		w_shotgun_release();
		return;
	}

	/* Ammo check */
	if (pl.shotgun_mag <= 0) {
		w_shotgun_release();
		return;
	}

#ifdef SERVER
	/* Singleplayer is more accurate */
	if (serverkeyfloat("sv_playerslots") == 1) {
		TraceAttack_FireBullets(6, pl.origin + pl.view_ofs, Skill_GetValue("plr_buckshot", 5), [0.08716,0.08716], WEAPON_SHOTGUN);
	} else {
		TraceAttack_FireBullets(4, pl.origin + pl.view_ofs, Skill_GetValue("plr_buckshot", 5), [0.08716,0.04362], WEAPON_SHOTGUN);
	}
	Sound_Play(pl, CHAN_WEAPON, "weapon_shotgun.single");
#else
	View_SetMuzzleflash(MUZZLE_WEIRD);
	View_AddEvent(w_shotgun_ejectshell, 0.5f);
#endif

	Weapons_ViewAnimation(SHOTGUN_FIRE1);
	Weapons_ViewPunchAngle([-5,0,0]);

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CR_SHOOTSHOTGUN, 0.41f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOTSHOTGUN, 0.5f);

	pl.shotgun_mag--;

	/* after 1/2 a second, play the cocksound and eject shell */
	pl.mode_tempstate = SHOTTY_COCKSOUND;
	pl.w_idle_next = 0.5f;

	pl.w_attack_next = 0.75;
}

void
w_shotgun_secondary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next) {
		w_shotgun_release();
		return;
	}

	/* interrupt reloading if no longer empty */
	if (pl.mode_tempstate == SHOTTY_RELOAD && pl.shotgun_mag >= 2) {
		pl.mode_tempstate = SHOTTY_RELOAD_END;
		w_shotgun_release();
		return;
	} else if (pl.mode_tempstate > SHOTTY_IDLE) {
		w_shotgun_release();
		return;
	}

	/* Ammo check */
	if (pl.shotgun_mag <= 1) {
		w_shotgun_release();
		return;
	}

	Weapons_ViewAnimation(SHOTGUN_FIRE2);
	Weapons_ViewPunchAngle([-10,0,0]);

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CR_SHOOTSHOTGUN, 0.41f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOTSHOTGUN, 0.5f);

#ifdef SERVER
	/* Singleplayer is more accurate */
	if (serverkeyfloat("sv_playerslots") == 1) {
		TraceAttack_FireBullets(12, pl.origin + pl.view_ofs, 5, [0.08716,0.08716], WEAPON_SHOTGUN);
	} else {
		TraceAttack_FireBullets(8, pl.origin + pl.view_ofs, 5, [0.17365,0.04362], WEAPON_SHOTGUN);
	}
	Sound_Play(pl, CHAN_WEAPON, "weapon_shotgun.double");
#else
	View_SetMuzzleflash(MUZZLE_WEIRD);
	View_AddEvent(w_shotgun_ejectshell, 1.0f);
#endif
	/* after 1 second, play the cocksound and eject shell */
	pl.mode_tempstate = SHOTTY_COCKSOUND;
	pl.w_idle_next = 1.0f;

	pl.shotgun_mag -= 2;
	pl.w_attack_next = 1.5f;
}

void
w_shotgun_reload(void)
{
	player pl = (player)self;

	if (pl.shotgun_mag >= 8) {
		return;
	}
	if (pl.ammo_buckshot <= 0) {
		return;
	}

	if (pl.mode_tempstate > SHOTTY_IDLE) {
		return;
	}
	pl.mode_tempstate = SHOTTY_RELOAD_START;
	pl.w_idle_next = 0.0f;
}

void
w_shotgun_release(void)
{
	player pl = (player)self;

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.mode_tempstate == SHOTTY_IDLE && pl.shotgun_mag == 0 && pl.ammo_buckshot > 0) {
		Weapons_Reload();
		return;
	}

	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.mode_tempstate == SHOTTY_IDLE) {
		int r = floor(pseudorandom() * 3.0f);
		switch (r) {
		case 1:
			Weapons_ViewAnimation(SHOTGUN_IDLE2);
			pl.w_idle_next = 2.222222f;
			break;
		case 2:
			Weapons_ViewAnimation(SHOTGUN_IDLE3);
			pl.w_idle_next = 5.0f;
			break;
		default:
			Weapons_ViewAnimation(SHOTGUN_IDLE1);
			pl.w_idle_next = 2.222222f;
			break;
		}
	} else if (pl.mode_tempstate == SHOTTY_RELOAD_START) {
		Weapons_ViewAnimation(SHOTGUN_START_RELOAD);
		pl.mode_tempstate = SHOTTY_RELOAD;
		pl.w_idle_next = 0.65f;
	} else if (pl.mode_tempstate == SHOTTY_RELOAD) {
		Weapons_ViewAnimation(SHOTGUN_RELOAD);
		pl.shotgun_mag++;
		pl.ammo_buckshot--;
#ifdef SERVER
		Sound_Play(pl, CHAN_WEAPON, "weapon_shotgun.reload");
#endif
		if (pl.ammo_buckshot <= 0 || pl.shotgun_mag >= 8) {
			pl.mode_tempstate = SHOTTY_RELOAD_END;
		}
		Weapons_UpdateAmmo(pl, pl.shotgun_mag, pl.ammo_buckshot, pl.mode_tempstate);
		pl.w_idle_next = 0.5f;	
	} else if (pl.mode_tempstate == SHOTTY_RELOAD_END) {
		Weapons_ViewAnimation(SHOTGUN_PUMP);
#ifdef SERVER
		Sound_Play(pl, CHAN_WEAPON, "weapon_shotgun.cock");
#endif
		pl.mode_tempstate = SHOTTY_IDLE;
		pl.w_idle_next = 10.0f;
		pl.w_attack_next = 0.5f;
	} else if (pl.mode_tempstate == SHOTTY_COCKSOUND) {
#ifdef CLIENT

#else
		Sound_Play(pl, CHAN_AUTO, "weapon_shotgun.cock");
#endif
		pl.mode_tempstate = SHOTTY_IDLE;
		pl.w_idle_next = 10.0f;
		pl.w_attack_next = 0.5f;
	}
}

void
w_shotgun_crosshair(void)
{
#ifdef CLIENT
	static vector cross_pos;
	cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];
	drawsubpic(cross_pos, [24,24], g_cross_spr, [48/128,24/128], [0.1875, 0.1875], [1,1,1], 1, DRAWFLAG_NORMAL);
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [72/256,72/128], [24/256, 24/128], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

float
w_shotgun_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMSHOTGUN : ANIM_AIMSHOTGUN;
}

void
w_shotgun_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;
	vector hud_col;

	if (pl.shotgun_mag == 0 && pl.ammo_buckshot == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	if (selected) {
		drawsubpic(pos, [170,45], g_hud4_spr, [0,180/256], [170/256,45/256], hud_col, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], g_hud1_spr, [0,180/256], [170/256,45/256], hud_col, a, DRAWFLAG_ADDITIVE);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_buckshot, MAX_A_BUCKSHOT, a);
#endif
}

weapon_t w_shotgun =
{
	.name		= "shotgun",
	.id		= ITEM_SHOTGUN,
	.slot		= 2,
	.slot_pos	= 1,
	.weight		= 15,
	.draw		= w_shotgun_draw,
	.holster	= w_shotgun_holster,
	.primary	= w_shotgun_primary,
	.secondary	= w_shotgun_secondary,
	.reload		= w_shotgun_reload,
	.release	= w_shotgun_release,
	.crosshair	= w_shotgun_crosshair,
	.precache	= w_shotgun_precache,
	.pickup		= w_shotgun_pickup,
	.updateammo	= w_shotgun_updateammo,
	.wmodel		= w_shotgun_wmodel,
	.pmodel		= w_shotgun_pmodel,
	.deathmsg	= w_shotgun_deathmsg,
	.aimanim	= w_shotgun_aimanim,
	.hudpic		= w_shotgun_hudpic
};

#ifdef SERVER
void
weapon_shotgun(void)
{
	Weapons_InitItem(WEAPON_SHOTGUN);
}
#endif
