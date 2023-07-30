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

#ifdef SERVER
.float nadeCookingTime;
#endif

enum
{
	HANDGRENADE_IDLE,
	HANDGRENADE_FIDGET,
	HANDGRENADE_PULLPIN,
	HANDGRENADE_THROW1,
	HANDGRENADE_THROW2,
	HANDGRENADE_THROW3,
	HANDGRENADE_HOLSTER,
	HANDGRENADE_DRAW
};

void w_handgrenade_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_handgrenade.bounce");
	precache_model("models/w_grenade.mdl");
	particleeffectnum("fx_explosion.main");
	precache_model("sprites/fexplo.spr");
#else
	precache_model("models/v_grenade.mdl");
	precache_model("models/p_grenade.mdl");
#endif
}

void w_handgrenade_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, pl.ammo_handgrenade, -1);
}

string w_handgrenade_wmodel(void)
{
	return "models/w_grenade.mdl";
}

string w_handgrenade_pmodel(player pl)
{
	return "models/p_grenade.mdl";
}

string w_handgrenade_deathmsg(void)
{
	return "";
}

int w_handgrenade_pickup(player pl, int new, int startammo)
{
#ifdef SERVER
	int addAmmo = (startammo == -1) ? 1 : startammo;

	if (pl.ammo_handgrenade < MAX_A_HANDGRENADE) {
		pl.ammo_handgrenade = bound(0, pl.ammo_handgrenade + addAmmo, MAX_A_HANDGRENADE);
	} else {
		if (!new)
			return (0);
	}
#endif
	return (1);
}

void w_handgrenade_draw(player pl)
{
	pl.mode_tempstate = 0;

	Weapons_SetModel("models/v_grenade.mdl");
	Weapons_ViewAnimation(pl, HANDGRENADE_DRAW);
}

void w_handgrenade_holster(player pl)
{
	
}
void w_handgrenade_primary(player pl)
{
	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	/* We're abusing this network variable for the holding check */
	if (pl.mode_tempstate > 0) {
		return;
	}

	/* Ammo check */
	if (pl.ammo_handgrenade <= 0) {
		return;
	}

	Weapons_ViewAnimation(pl, HANDGRENADE_PULLPIN);

	pl.mode_tempstate = 1;
	pl.w_attack_next = 0.5f;
	pl.w_idle_next = 0.5f;

#ifdef SERVER
	pl.nadeCookingTime = time;
#endif
}

void w_handgrenade_hud(player pl)
{
#ifdef CLIENT
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [48/256,96/128], [24/256, 24/128], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void w_handgrenade_release(player pl)
{
	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.mode_tempstate == 1) {
		Weapons_ViewAnimation(pl, HANDGRENADE_THROW1);
#ifdef SERVER
		vector throwDirection;
		float throwingStrength;

		NSProjectile nade = (NSProjectile )EntityDef_CreateClassname("projectile_handgrenade");
		nade.SetOwner(pl);

		throwDirection = pl.v_angle;
		throwDirection[0] = -10.0f; /* always aim a bit up */

		/* diminish when aiming up */
		if (pl.v_angle[0] < 0) {
			throwDirection[0] += (pl.v_angle[0] * 0.9f);
		} else { /* increase when aiming down */
			throwDirection[0] += (pl.v_angle[0] * 1.1f);
		}

		throwingStrength = bound(0, (90 - throwDirection[0]) * 5.0f, 1000);

		nade.Launch(pl.GetEyePos(), pl.v_angle, time - pl.nadeCookingTime, 0.0f, 0.0f);
		makevectors(throwDirection);
		nade.SetVelocity((v_forward * throwingStrength) + pl.GetVelocity());
#endif
		pl.ammo_handgrenade--;
		pl.mode_tempstate = 2;
		pl.w_attack_next = 1.0f;
		pl.w_idle_next = 0.5f;

		if (pl.flags & FL_CROUCHING)
			Animation_PlayerTop(pl, ANIM_CR_SHOOTCROWBAR, 0.41f);
		else
			Animation_PlayerTop(pl, ANIM_SHOOTCROWBAR, 0.5f);
	} else if (pl.mode_tempstate == 2) {
		Weapons_ViewAnimation(pl, HANDGRENADE_DRAW);
#ifdef SERVER
		if (!pl.ammo_handgrenade) {
			Weapons_RemoveItem(pl, WEAPON_HANDGRENADE);
		}
#endif
		pl.w_attack_next = 0.5f;
		pl.w_idle_next = 0.5f;
		pl.mode_tempstate = 0;
	} else {
		int r = floor(pseudorandom() * 8.0f);
		if (r == 1) {
			Weapons_ViewAnimation(pl, HANDGRENADE_FIDGET);
			pl.w_idle_next = 2.5f;
		} else {
			Weapons_ViewAnimation(pl, HANDGRENADE_IDLE);
			pl.w_idle_next = 3.0f;
		}
	}
}

float
w_handgrenade_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_handgrenade_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT

	if (selected) {
		drawsubpic(pos, [170,45], g_hud6_spr, [0,0], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], g_hud3_spr, [0,0], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_handgrenade, MAX_A_HANDGRENADE, a);
#endif
}

int
w_handgrenade_isempty(player pl)
{

	if (pl.ammo_handgrenade <= 0)
		return 1;

	return 0;
}

weapontype_t
w_handgrenade_type(player pl)
{
	return WPNTYPE_THROW;
}

weapon_t w_handgrenade =
{
	.name		= "grenade",
	.id			= ITEM_HANDGRENADE,
	.slot		= 4,
	.slot_pos	= 0,
	.weight		= 5,
	.draw		= w_handgrenade_draw,
	.holster	= w_handgrenade_holster,
	.primary	= w_handgrenade_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_handgrenade_release,
	.postdraw	= w_handgrenade_hud,
	.precache	= w_handgrenade_precache,
	.pickup		= w_handgrenade_pickup,
	.updateammo	= w_handgrenade_updateammo,
	.wmodel		= w_handgrenade_wmodel,
	.pmodel		= w_handgrenade_pmodel,
	.deathmsg	= w_handgrenade_deathmsg,
	.aimanim	= w_handgrenade_aimanim,
	.isempty	= w_handgrenade_isempty,
	.type		= w_handgrenade_type,
	.hudpic		= w_handgrenade_hudpic
};