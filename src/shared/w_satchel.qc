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

/*QUAKED weapon_satchel (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_satchel.mdl"

HALF-LIFE (1998) ENTITY

Satchel Weapon

*/

enum
{
	SATCHEL_IDLE,
	SATCHEL_FIDGET,
	SATCHEL_DRAW,
	SATCHEL_THROW
};

enum
{
	RADIO_IDLE,
	RADIO_FIDGET,
	RADIO_DRAW,
	RADIO_USE,
	RADIO_HOLSTER
};



#ifdef SERVER
void
s_satchel_drop(entity master, vector src, vector vel)
{
	static void s_satchel_touch(void)
	{
		if (other != world)
			return;
		
		Sound_Play(self, CHAN_BODY, "weapon_satchel.bounce");
	}
	entity satch;
	satch = spawn();
	satch.owner = master;
	satch.classname = "satchel";
	satch.movetype = MOVETYPE_BOUNCE;
	satch.solid = SOLID_BBOX;
	satch.frame = 1;
	satch.gravity = 0.5f;
	satch.friction = 0.8f;
	satch.velocity = vel;
	satch.avelocity = [0,400,0];
	satch.touch = s_satchel_touch;
	setmodel(satch, "models/w_satchel.mdl");
	setsize(satch, [-4,-4,-4], [4,4,4]);
	setorigin(satch, src);
}

void
s_satchel_detonate(entity master)
{
	for (entity b = world; (b = find(b, ::classname, "satchel"));) {
		if (b.owner != master)
			continue;

		float dmg = Skill_GetValue("plr_satchel", 150);
		FX_Explosion(b.origin);
		Damage_Radius(b.origin, master, dmg, dmg * 2.5f, TRUE, WEAPON_SATCHEL);
		sound(b, CHAN_WEAPON, sprintf("weapons/explode%d.wav", floor(random() * 2) + 3), 1, ATTN_NORM);
		remove(b);
	}
}
#endif

void
w_satchel_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.satchel_chg, pl.ammo_satchel, -1);
}

string
w_satchel_wmodel(void)
{
	return "models/w_satchel.mdl";
}

string
w_satchel_pmodel(void)
{
	return "models/p_satchel.mdl";
}

string
w_satchel_deathmsg(void)
{
	return "";
}

void
w_satchel_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_satchel.bounce");
	precache_model("models/w_satchel.mdl");
#else
	precache_model("models/v_satchel.mdl");
	precache_model("models/v_satchel_radio.mdl");
	precache_model("models/p_satchel.mdl");
#endif
}

int
w_satchel_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (pl.ammo_satchel < MAX_A_SATCHEL) {
		pl.ammo_satchel = bound(0, pl.ammo_satchel + 1, MAX_A_SATCHEL);
	} else {
		return FALSE;
	}
#endif
	return TRUE;
}

void
w_satchel_draw(void)
{
#ifdef CLIENT
	player pl = (player)self;
	if (pl.satchel_chg > 0) {
		Weapons_SetModel("models/v_satchel_radio.mdl");
		Weapons_ViewAnimation(RADIO_DRAW);
		
	} else {
		Weapons_SetModel("models/v_satchel.mdl");
		Weapons_ViewAnimation(SATCHEL_DRAW);
	}
#endif
}

void
w_satchel_holster(void)
{
	
}

void
w_satchel_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next) {
		return;
	}

	/* Ammo check */
	if (pl.satchel_chg <= 0 && pl.ammo_satchel <= 0) {
		return;
	}

	if (pl.satchel_chg <= 0) {
		Weapons_ViewAnimation(RADIO_DRAW);
	} else {
		Weapons_ViewAnimation(RADIO_USE);
	}

#ifdef SERVER
	/* if we don't have any satchels placed yet, place one */
	if (!pl.satchel_chg) {
		vector throw;
		
		Weapons_MakeVectors();
		throw = pl.velocity + (v_forward * 274);
		s_satchel_drop(self, pl.origin, throw);
		pl.satchel_chg++;
		pl.ammo_satchel--;
	} else {
		/* detonate all we have */
		s_satchel_detonate(pl);
		pl.satchel_chg = 0;

		/* no satchels left to place? just get rid of this thing */
		if (pl.ammo_satchel <= 0) {
			Weapons_RemoveItem(pl, WEAPON_SATCHEL);
		}
	}
#else
	Weapons_SetModel("models/v_satchel_radio.mdl");

	/* same thing as the SERVER ifdef above... */
	if (!pl.satchel_chg) {
		pl.satchel_chg++;
		pl.ammo_satchel--;
	} else {
		pl.satchel_chg = 0;
	}
#endif

	pl.w_attack_next = 1.0f;
	pl.w_idle_next = 1.0f;
}

void
w_satchel_secondary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next) {
		return;
	}

	/* Ammo check */
	if (pl.ammo_satchel <= 0) {
		return;
	}

#ifdef SERVER
	vector throw;
	Weapons_MakeVectors();
	throw = pl.velocity + (v_forward * 274);
	s_satchel_drop(self, pl.origin, throw);
#else
	Weapons_SetModel("models/v_satchel_radio.mdl");
	Weapons_ViewAnimation(RADIO_DRAW);
#endif

	pl.satchel_chg++;
	pl.ammo_satchel--;

	pl.w_attack_next = 1.0f;
	pl.w_idle_next = 2.5f;
}

void
w_satchel_reload(void)
{
	
}

void
w_satchel_release(void)
{
	player pl = (player)self;

	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.satchel_chg <= 0) {
		Weapons_ViewAnimation(SATCHEL_FIDGET);
	} else {
		Weapons_ViewAnimation(RADIO_FIDGET);
	}
	pl.w_idle_next = 15.0f;
}

float
w_satchel_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMSQUEAK : ANIM_AIMSQUEAK;
}

void
w_satchel_hud(void)
{
#ifdef CLIENT
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [72/256,96/128], [24/256, 24/128], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_satchel_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;

	if (selected) {
		drawsubpic(pos, [170,45], g_hud6_spr, [0,45/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], g_hud3_spr, [0,45/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_satchel, MAX_A_SATCHEL, a);
#endif
}

weapon_t w_satchel =
{
	.name		= "satchel",
	.id		= ITEM_SATCHEL,
	.slot		= 4,
	.slot_pos	= 1,
	.draw		= w_satchel_draw,
	.holster	= w_satchel_holster,
	.primary	= w_satchel_primary,
	.secondary	= w_satchel_secondary,
	.reload		= w_satchel_reload,
	.release	= w_satchel_release,
	.crosshair	= w_satchel_hud,
	.precache	= w_satchel_precache,
	.pickup		= w_satchel_pickup,
	.updateammo	= w_satchel_updateammo,
	.wmodel		= w_satchel_wmodel,
	.pmodel		= w_satchel_pmodel,
	.deathmsg	= w_satchel_deathmsg,
	.aimanim	= w_satchel_aimanim,
	.hudpic		= w_satchel_hudpic
};

#ifdef SERVER
void
weapon_satchel(void)
{
	Weapons_InitItem(WEAPON_SATCHEL);
}
#endif
