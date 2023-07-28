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
s_satchel_detonate(entity master)
{
	for (entity b = world; (b = find(b, ::classname, "projectile_satchel"));) {
		if (b.owner != master)
			continue;

		NSEntity satchelEnt = (NSEntity)b;
		satchelEnt.Trigger(master, TRIG_TOGGLE);
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
w_satchel_pmodel(player pl)
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
w_satchel_pickup(player pl, int new, int startammo)
{
#ifdef SERVER
	int addAmmo = (startammo == -1) ? 1 : startammo;

	if (pl.ammo_satchel < MAX_A_SATCHEL) {
		pl.ammo_satchel = bound(0, pl.ammo_satchel + addAmmo, MAX_A_SATCHEL);
	} else {
		if (!new)
			return (0);
	}
#endif
	return (1);
}

void
w_satchel_draw(player pl)
{
	if (pl.satchel_chg > 0) {
		Weapons_SetModel("models/v_satchel_radio.mdl");
		Weapons_ViewAnimation(pl, RADIO_DRAW);
		
	} else {
		Weapons_SetModel("models/v_satchel.mdl");
		Weapons_ViewAnimation(pl, SATCHEL_DRAW);
	}
}

void
w_satchel_holster(player pl)
{
	
}

void
w_satchel_primary(player pl)
{
	if (pl.w_attack_next) {
		return;
	}

	/* Ammo check */
	if (pl.satchel_chg <= 0 && pl.ammo_satchel <= 0) {
		return;
	}

	if (pl.satchel_chg <= 0) {
		Weapons_ViewAnimation(pl, RADIO_DRAW);
	} else {
		Weapons_ViewAnimation(pl, RADIO_USE);
	}

#ifdef SERVER
	/* if we don't have any satchels placed yet, place one */
	if (!pl.satchel_chg) {
		NSProjectile_SpawnDef("projectile_satchel", pl);
		pl.satchel_chg++;
		pl.ammo_satchel--;
		pl.mode_tempstate = 1; /* mark us as having deployed something */

		if (pl.flags & FL_CROUCHING)
			Animation_PlayerTop(pl, ANIM_CR_SHOOTSQUEAK, 0.41f);
		else
			Animation_PlayerTop(pl, ANIM_SHOOTSQUEAK, 0.5f);
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
w_satchel_secondary(player pl)
{
	if (pl.w_attack_next) {
		return;
	}

	/* Ammo check */
	if (pl.ammo_satchel <= 0) {
		return;
	}

	Weapons_SetModel("models/v_satchel_radio.mdl");
	Weapons_ViewAnimation(pl, RADIO_DRAW);

#ifdef SERVER
	NSProjectile_SpawnDef("projectile_satchel", pl);
#endif

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CR_SHOOTSQUEAK, 0.41f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOTSQUEAK, 0.5f);

	pl.satchel_chg++;
	pl.ammo_satchel--;
	pl.mode_tempstate = 1; /* mark us as having deployed something */

	pl.w_attack_next = 1.0f;
	pl.w_idle_next = 0.5f;
}

void
w_satchel_reload(player pl)
{
	
}

void
w_satchel_release(player pl)
{
	if (pl.w_idle_next > 0.0) {
		return;
	}

	/* keep track of the model via tempstates */
	if (pl.satchel_chg < 1i && pl.mode_tempstate != 0) {
		pl.mode_tempstate = 0;
		Weapons_SetModel("models/v_satchel.mdl");
		Weapons_ViewAnimation(pl, SATCHEL_DRAW);
		pl.w_idle_next = 15.0f;
		return;
	}

	if (pl.satchel_chg <= 0) {
		Weapons_ViewAnimation(pl, SATCHEL_FIDGET);
	} else {
		Weapons_ViewAnimation(pl, RADIO_FIDGET);
	}
	pl.w_idle_next = 15.0f;
}

float
w_satchel_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? ANIM_CR_AIMSQUEAK : ANIM_AIMSQUEAK;
}

void
w_satchel_hud(player pl)
{
#ifdef CLIENT
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [72/256,96/128], [24/256, 24/128], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_satchel_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT

	if (selected) {
		drawsubpic(pos, [170,45], g_hud6_spr, [0,45/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], g_hud3_spr, [0,45/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_satchel, MAX_A_SATCHEL, a);
#endif
}

int
w_satchel_isempty(player pl)
{
	if (pl.ammo_satchel <= 0)
		return 1;

	return 0;
}

weapontype_t
w_satchel_type(player pl)
{
	return WPNTYPE_THROW;
}

weapon_t w_satchel =
{
	.name		= "satchel",
	.id		= ITEM_SATCHEL,
	.slot		= 4,
	.slot_pos	= 1,
	.weight		= -20,
	.draw		= w_satchel_draw,
	.holster	= w_satchel_holster,
	.primary	= w_satchel_primary,
	.secondary	= w_satchel_secondary,
	.reload		= w_satchel_reload,
	.release	= w_satchel_release,
	.postdraw	= w_satchel_hud,
	.precache	= w_satchel_precache,
	.pickup		= w_satchel_pickup,
	.updateammo	= w_satchel_updateammo,
	.wmodel		= w_satchel_wmodel,
	.pmodel		= w_satchel_pmodel,
	.deathmsg	= w_satchel_deathmsg,
	.aimanim	= w_satchel_aimanim,
	.isempty	= w_satchel_isempty,
	.type		= w_satchel_type,
	.hudpic		= w_satchel_hudpic
};
