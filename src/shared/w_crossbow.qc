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

/*QUAKED weapon_crossbow (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_crossbow.mdl"

HALF-LIFE (1998) ENTITY

Crossbow Weapon

*/

enum
{
	CROSSBOW_IDLE1,
	CROSSBOW_IDLE2,
	CROSSBOW_FIDGET1,
	CROSSBOW_FIDGET2,
	CROSSBOW_FIRE1,
	CROSSBOW_FIRE2,
	CROSSBOW_FIRE3,
	CROSSBOW_RELOAD,
	CROSSBOW_DRAW1,
	CROSSBOW_DRAW2,
	CROSSBOW_HOLSTER1,
	CROSSBOW_HOLSTER2
};

void
w_crossbow_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_crossbow.fire");
	Sound_Precache("weapon_crossbow.hit");
	Sound_Precache("weapon_crossbow.hitbody");
	Sound_Precache("weapon_crossbow.reload");
	precache_model("models/crossbow_bolt.mdl");
	precache_model("models/w_crossbow.mdl");
#else
	precache_model("models/v_crossbow.mdl");
	precache_model("models/p_crossbow.mdl");
#endif
}

void
w_crossbow_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.crossbow_mag, pl.ammo_bolt, -1);
}

string
w_crossbow_wmodel(void)
{
	return "models/w_crossbow.mdl";
}

string
w_crossbow_pmodel(player pl)
{
	return "models/p_crossbow.mdl";
}

string
w_crossbow_deathmsg(void)
{
	return "";
}

int
w_crossbow_pickup(player pl, int new, int startammo)
{
#ifdef SERVER
	if (new) {
		pl.crossbow_mag = 5;
		return (1);
	}

	if (pl.ammo_bolt < MAX_A_BOLT) {
		pl.ammo_bolt = bound(0, pl.ammo_bolt + 5, MAX_A_BOLT);
	} else {
		if (!new)
			return (0);
	}
	
#endif
	return (1);
}

void
w_crossbow_draw(player pl)
{
	Weapons_SetModel("models/v_crossbow.mdl");

	if (pl.crossbow_mag <= 0)
		Weapons_ViewAnimation(pl, CROSSBOW_DRAW2);
	else
		Weapons_ViewAnimation(pl, CROSSBOW_DRAW1);
}

void
w_crossbow_holster(player pl)
{
	Weapons_ViewAnimation(pl, CROSSBOW_HOLSTER1);
}

#ifdef SERVER
void Crossbolt_Touch(void) {
	/* explode mode, multiplayer */
	if (self.weapon) {
		float dmg = Skill_GetValue("plr_xbow_bolt_monster", 50);
		FX_Explosion(self.origin);
		Damage_Radius(self.origin, self.owner, dmg, dmg * 2.5f, TRUE, WEAPON_CROSSBOW);
		if (random() < 0.5) {
			sound(self, 1, "weapons/explode3.wav", 1.0f, ATTN_NORM);
		} else {
			sound(self, 1, "weapons/explode4.wav", 1.0f, ATTN_NORM);
		}
		remove(self);
		return;
	}

	/* walls, etc. */
	if (other.takedamage != DAMAGE_YES) {
		FX_Spark(self.origin, trace_plane_normal);
		Sound_Play(self, 1, "weapon_crossbow.hit");
		remove(self);
		return;
	}

	/* anything else that can take damage */
	Damage_Apply(other, self.owner, Skill_GetValue("plr_xbow_bolt_monster", 50), WEAPON_CROSSBOW, DMG_BLUNT);
	Sound_Play(self, 1, "weapon_crossbow.hitbody");

	if (other.iBleeds == FALSE) {
		FX_Spark(self.origin, trace_plane_normal);
	} else {
		FX_Blood(self.origin, [1,0,0]);
	}
	remove(self);
}
#endif

void
w_crossbow_primary(player pl)
{
	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* ammo check */
	if (pl.crossbow_mag <= 0) {
		return;
	}

	pl.crossbow_mag--;

#ifndef CLIENT
	HLGameRules rules = (HLGameRules) g_grMode;
	Weapons_MakeVectors(pl);
	entity bolt = spawn();
	setmodel(bolt, "models/crossbow_bolt.mdl");
	setorigin(bolt, Weapons_GetCameraPos(pl) + (v_forward * 16));
	bolt.owner = self;
	bolt.velocity = v_forward * 2000;
	bolt.movetype = MOVETYPE_FLYMISSILE;
	bolt.solid = SOLID_BBOX;
	//bolt.flags |= FL_LAGGEDMOVE;
	bolt.gravity = 0.5f;
	bolt.angles = vectoangles(bolt.velocity);
	bolt.avelocity[2] = 10;
	bolt.touch = Crossbolt_Touch;

	if (rules.IsMultiplayer() == true)
		bolt.weapon = pl.viewzoom == 1.0 ? 1 : 0;

	setsize(bolt, [0,0,0], [0,0,0]);

	if (pl.crossbow_mag > 0) {
		Sound_Play(pl, 8, "weapon_crossbow.hitbody");
	}

	Sound_Play(pl, CHAN_WEAPON, "weapon_crossbow.fire");
#endif

	if (pl.crossbow_mag) {
		Weapons_ViewAnimation(pl, CROSSBOW_FIRE1);
	} else {
		Weapons_ViewAnimation(pl, CROSSBOW_FIRE3);
	}

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CR_SHOOTBOW, 0.25f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOTBOW, 0.25f);

	Weapons_ViewPunchAngle(pl, [-2,0,0]);

	pl.w_attack_next = 0.75f;
	pl.w_idle_next = 10.0f;
}

void
w_crossbow_secondary(player pl)
{
	if (pl.w_attack_next) {
		return;
	}
	/* Simple toggle of fovs */
	if (pl.viewzoom == 1.0f) {
		pl.viewzoom = 0.2f;
	} else {
		pl.viewzoom = 1.0f;
	}
	pl.w_attack_next = 0.5f;
}

void
w_crossbow_reload(player pl)
{
	if (pl.w_attack_next > 0.0) {
		return;
	}

	if (pl.ammo_bolt <= 0) {
		return;
	}
	if (pl.crossbow_mag >= 5) {
		return;
	}
	
	/* undo our zoom */
	pl.viewzoom = 1.0f;

#ifdef SERVER
	static void w_crossbow_reload_done(void) {
		player pl = (player)self;
		Weapons_ReloadWeapon(pl, player::crossbow_mag, player::ammo_bolt, 5);
	}

	pl.think = w_crossbow_reload_done;
	pl.nextthink = time + 4.4f;
	Sound_Play(pl, CHAN_ITEM, "weapon_crossbow.reload");
#endif

	Weapons_ViewAnimation(pl, CROSSBOW_RELOAD);

	pl.w_attack_next = 4.5f;
	pl.w_idle_next = 10.0f;
}

void
w_crossbow_release(player pl)
{
	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.crossbow_mag == 0 && pl.ammo_bolt > 0) {
		Weapons_Reload(pl);
		return;
	}

	if (pl.w_idle_next > 0.0) {
		return;
	}

	int r = floor(pseudorandom() * 2.0f);
	if (r == 1) {
		if (pl.crossbow_mag) {
			Weapons_ViewAnimation(pl, CROSSBOW_IDLE1);
		} else {
			Weapons_ViewAnimation(pl, CROSSBOW_IDLE2);
		}
	} else {
		if (pl.crossbow_mag) {
			Weapons_ViewAnimation(pl, CROSSBOW_FIDGET1);
		} else {
			Weapons_ViewAnimation(pl, CROSSBOW_FIDGET2);
		}
	}

	pl.w_idle_next = 3.0f;
}

void
w_crossbow_crosshair(player pl)
{
#ifdef CLIENT
	vector cross_pos;
	vector aicon_pos;

	if (pl.viewzoom == 1) {
		cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];
		drawsubpic(
			cross_pos,
			[24,24],
			g_cross_spr,
			[72/128,0],
			[0.1875, 0.1875],
			[1,1,1],
			1,
			DRAWFLAG_NORMAL
		);
	} else {
		cross_pos = g_hudmins + (g_hudres / 2) + [-52,-8];
		drawsubpic(
			cross_pos,
			[104,16],
			g_cross_spr,
			[24/128,96/128],
			[104/128, 16/128],
			[1,1,1],
			1,
			DRAWFLAG_NORMAL
		);
	}

	HUD_DrawAmmo1();
	HUD_DrawAmmo2();

	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(
		aicon_pos,
		[24,24],
		g_hud7_spr,
		[96/256,72/128],
		[24/256, 24/128],
		g_hud_color,
		pSeatLocal->m_flAmmo2Alpha,
		DRAWFLAG_ADDITIVE
	);
#endif
}

float
w_crossbow_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? ANIM_CR_AIMBOW : ANIM_AIMBOW;
}

void
w_crossbow_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (pl.crossbow_mag == 0 && pl.ammo_bolt == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud5_spr,
			[0,0],
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
			[0,0],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_bolt, MAX_A_BOLT, a);
#endif
}

int
w_crossbow_isempty(player pl)
{
	if (pl.crossbow_mag <= 0 && pl.ammo_bolt <= 0)
		return 1;

	return 0;
}

weapontype_t w_crossbow_type(player pl)
{
	return WPNTYPE_RANGED;
}

weapon_t w_crossbow =
{
	.name		= "crossbow",
	.id			= ITEM_CROSSBOW,
	.slot		= 2,
	.slot_pos	= 2,
	.weight		= 10,
	.draw		= w_crossbow_draw,
	.holster	= w_crossbow_holster,
	.primary	= w_crossbow_primary,
	.secondary	= w_crossbow_secondary,
	.reload		= w_crossbow_reload,
	.release	= w_crossbow_release,
	.postdraw	= w_crossbow_crosshair,
	.precache	= w_crossbow_precache,
	.pickup		= w_crossbow_pickup,
	.updateammo	= w_crossbow_updateammo,
	.wmodel		= w_crossbow_wmodel,
	.pmodel		= w_crossbow_pmodel,
	.deathmsg	= w_crossbow_deathmsg,
	.aimanim	= w_crossbow_aimanim,
	.isempty	= w_crossbow_isempty,
	.type		= w_crossbow_type,
	.hudpic		= w_crossbow_hudpic
};

#ifdef SERVER
void
weapon_crossbow(void)
{
	Weapons_InitItem(WEAPON_CROSSBOW);
}
#endif
