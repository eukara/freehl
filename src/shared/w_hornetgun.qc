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
	HORNETGUN_IDLE,
	HORNETGUN_FIDGET1,
	HORNETGUN_FIDGET2,
	HORNETGUN_HOLSTER,
	HORNETGUN_DRAW,
	HORNETGUN_SHOOT
};

void
w_hornetgun_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_hornetgun.fire");
	Sound_Precache("weapon_hornetgun.buzz");
	Sound_Precache("weapon_hornetgun.hit");
	precache_model("models/w_hgun.mdl");
	precache_model("models/hornet.mdl");
#else
	precache_model("models/v_hgun.mdl");
	precache_model("models/p_hgun.mdl");
#endif
}

int
w_hornetgun_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	/* only pick it up once */
	if (new) {
		pl.ammo_hornet = MAX_A_HORNET;
		return (1);
	}
#endif
	return (0);
}

void
w_hornetgun_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, pl.ammo_hornet, -1);
}
string w_hornetgun_wmodel(void)
{
	return "models/w_hgun.mdl";
}
string w_hornetgun_pmodel(player pl)
{
	return "models/p_hgun.mdl";
}
string w_hornetgun_deathmsg(void)
{
	return "";
}

void
w_hornetgun_draw(player pl)
{
	Weapons_SetModel("models/v_hgun.mdl");
	Weapons_ViewAnimation(pl, HORNETGUN_DRAW);
}

void
w_hornetgun_holster(player pl)
{
	
}

#ifdef SERVER
void
w_hornetgun_shoothornet(player pl)
{
	static void Hornet_Touch(void) {
		if (other.takedamage == DAMAGE_YES) {
			Damage_Apply(other, self.owner, Skill_GetValue("plr_hornet", 10), WEAPON_HORNETGUN, DMG_GENERIC);
			Sound_Play(other, CHAN_VOICE, "weapon_hornetgun.hit");
		} else {
			Sound_Play(self, CHAN_VOICE, "weapon_hornetgun.buzz");
		}
		remove(self);
	}

	Weapons_MakeVectors(pl);
	entity bolt = spawn();
	setmodel(bolt, "models/hornet.mdl");
	setorigin(bolt, Weapons_GetCameraPos(pl) + (v_forward * 16) + (v_up * -8));
	bolt.owner = pl;
	bolt.velocity = v_forward * 1000;
	bolt.movetype = MOVETYPE_FLY;
	bolt.solid = SOLID_BBOX;
	//bolt.flags |= FL_LAGGEDMOVE;
	bolt.gravity = 0.5f;
	bolt.angles = vectoangles(bolt.velocity);
	bolt.touch = Hornet_Touch;
	bolt.traileffectnum = particleeffectnum("weapon_hornet.trail");
	setsize(bolt, [0,0,0], [0,0,0]);
}
#endif

void
w_hornetgun_release(player pl)
{

	if (pl.w_idle_next > 0.0) {
		return;
	}

	/* slow regeneration of ammunition */
	if (pl.ammo_hornet < MAX_A_HORNET) {
		pl.ammo_hornet = bound(0, pl.ammo_hornet + 1, MAX_A_HORNET);
		Weapons_UpdateAmmo(pl, -1, pl.ammo_hornet, -1);
		pl.w_idle_next = 0.35f;
		return;
	}

	if (pl.w_idle_next > 0.0) {
		return;
	}

	int r;
	r = floor(pseudorandom() * 3.0f);
	switch (r) {
	case 1:
		Weapons_ViewAnimation(pl, HORNETGUN_FIDGET1);
		pl.w_idle_next = 2.5f;
		break;
	case 2:
		Weapons_ViewAnimation(pl, HORNETGUN_FIDGET2);
		pl.w_idle_next = 2.1875f;
		break;
	default:
		Weapons_ViewAnimation(pl, HORNETGUN_IDLE);
		pl.w_idle_next = 1.875f;
	}
}

void
w_hornetgun_primary(player pl)
{
	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* Ammo check */
	if (pl.ammo_hornet <= 0) {
		w_hornetgun_release(pl);
		return;
	}

#ifdef SERVER
	w_hornetgun_shoothornet(pl);
	Sound_Play(pl, CHAN_WEAPON, "weapon_hornetgun.fire");
#endif

	pl.ammo_hornet--;
	Weapons_ViewAnimation(pl, HORNETGUN_SHOOT);

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CR_SHOOTHIVE, 0.43f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOTHIVE, 0.43f);

	pl.w_attack_next = 0.25;
	pl.w_idle_next = 1.0f;
}

void
w_hornetgun_secondary(player pl)
{
	if (pl.w_attack_next) {
		return;
	}

    /* Ammo check */
	if (pl.ammo_hornet <= 0) {
		w_hornetgun_release(pl);
		return;
	}

#ifdef SERVER
	w_hornetgun_shoothornet(pl);
	Sound_Play(pl, CHAN_WEAPON, "weapon_hornetgun.fire");
#endif

	pl.ammo_hornet--;
	Weapons_ViewAnimation(pl, HORNETGUN_SHOOT);

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CR_SHOOTHIVE, 0.43f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOTHIVE, 0.43f);

	pl.w_attack_next = 0.1;
	pl.w_idle_next = 1.0f;
}

void
w_hornetgun_crosshair(player pl)
{
#ifdef CLIENT
	vector aicon_pos;

	Cross_DrawSub(g_cross_spr, [24,24], [72/128,24/128], [0.1875, 0.1875]);
	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];

	HUD_DrawAmmo2();

	drawsubpic(
		aicon_pos,
		[24,24],
		g_hud7_spr,
		[24/256,96/128],
		[24/256, 24/128],
		g_hud_color,
		pSeatLocal->m_flAmmo2Alpha,
		DRAWFLAG_ADDITIVE
	);
#endif
}

float
w_hornetgun_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? ANIM_CR_AIMHIVE : ANIM_AIMHIVE;
}

void
w_hornetgun_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud5_spr,
			[0,180/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			g_hud2_spr,
			[0,180/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_hornet, MAX_A_HORNET, a);
#endif
}

int
w_hornetgun_isempty(player pl)
{
	return 0;
}

weapontype_t
w_hornetgun_type(player pl)
{
	return WPNTYPE_RANGED;
}

weapon_t w_hornetgun =
{
	.name		= "hornet",
	.id			= ITEM_HORNETGUN,
	.slot		= 3,
	.slot_pos	= 3,
	.weight		= 10,
	.draw		= w_hornetgun_draw,
	.holster	= w_hornetgun_holster,
	.primary	= w_hornetgun_primary,
	.secondary	= w_hornetgun_secondary,
	.reload		= __NULL__,
	.release	= w_hornetgun_release,
	.postdraw	= w_hornetgun_crosshair,
	.precache	= w_hornetgun_precache,
	.pickup		= w_hornetgun_pickup,
	.updateammo	= w_hornetgun_updateammo,
	.wmodel		= w_hornetgun_wmodel,
	.pmodel		= w_hornetgun_pmodel,
	.deathmsg	= w_hornetgun_deathmsg,
	.aimanim	= w_hornetgun_aimanim,
	.isempty	= w_hornetgun_isempty,
	.type		= w_hornetgun_type,
	.hudpic		= w_hornetgun_hudpic
};