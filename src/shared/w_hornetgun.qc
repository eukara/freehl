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

/*QUAKED weapon_hornetgun (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_hgun.mdl"

HALF-LIFE (1998) ENTITY

Hornetgun Weapon

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
w_hornetgun_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	/* only pick it up once */
	if (new) {
		pl.ammo_hornet = MAX_A_HORNET;
		return TRUE;
	}
#endif
	return FALSE;
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
string w_hornetgun_pmodel(void)
{
	return "models/p_hgun.mdl";
}
string w_hornetgun_deathmsg(void)
{
	return "";
}

void
w_hornetgun_draw(void)
{
	Weapons_SetModel("models/v_hgun.mdl");
	Weapons_ViewAnimation(HORNETGUN_DRAW);
}

void
w_hornetgun_holster(void)
{
	
}

#ifdef SERVER
void
w_hornetgun_shoothornet(void)
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

	Weapons_MakeVectors();
	entity bolt = spawn();
	setmodel(bolt, "models/hornet.mdl");
	setorigin(bolt, Weapons_GetCameraPos() + (v_forward * 16) + (v_up * -8));
	bolt.owner = self;
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
w_hornetgun_release(void)
{
	player pl = (player)self;

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
	r = (float)input_sequence % 3;
	switch (r) {
	case 1:
		Weapons_ViewAnimation(HORNETGUN_FIDGET1);
		pl.w_idle_next = 2.5f;
		break;
	case 2:
		Weapons_ViewAnimation(HORNETGUN_FIDGET2);
		pl.w_idle_next = 2.1875f;
		break;
	default:
		Weapons_ViewAnimation(HORNETGUN_IDLE);
		pl.w_idle_next = 1.875f;
	}
}

void
w_hornetgun_primary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* Ammo check */
	if (pl.ammo_hornet <= 0) {
		w_hornetgun_release();
		return;
	}

#ifdef SERVER
	w_hornetgun_shoothornet();
	Sound_Play(pl, CHAN_WEAPON, "weapon_hornetgun.fire");
#endif

	pl.ammo_hornet--;
	Weapons_ViewAnimation(HORNETGUN_SHOOT);

	pl.w_attack_next = 0.25;
	pl.w_idle_next = 1.0f;
}

void
w_hornetgun_secondary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next) {
		return;
	}

    /* Ammo check */
	if (pl.ammo_hornet <= 0) {
		w_hornetgun_release();
		return;
	}

#ifdef SERVER
	w_hornetgun_shoothornet();
	Weapons_PlaySound(pl, CHAN_WEAPON, sprintf("agrunt/ag_fire%d.wav", floor(random(1,4))), 1, ATTN_NORM);
#endif

	pl.ammo_hornet--;
	Weapons_ViewAnimation(HORNETGUN_SHOOT);

	pl.w_attack_next = 0.1;
	pl.w_idle_next = 1.0f;
}

void
w_hornetgun_crosshair(void)
{
#ifdef CLIENT
	vector cross_pos;
	vector aicon_pos;

	cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];
	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];

	drawsubpic(
		cross_pos,
		[24,24],
		g_cross_spr,
		[72/128,24/128],
		[0.1875, 0.1875],
		[1,1,1],
		1.0f,
		DRAWFLAG_NORMAL
	);

	HUD_DrawAmmo2();

	drawsubpic(
		aicon_pos,
		[24,24],
		g_hud7_spr,
		[24/256,96/128],
		[24/256, 24/128],
		g_hud_color,
		pSeat->m_flAmmo2Alpha,
		DRAWFLAG_ADDITIVE
	);
#endif
}

float
w_hornetgun_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMHIVE : ANIM_AIMHIVE;
}

void
w_hornetgun_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;

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

weapon_t w_hornetgun =
{
	.name		= "hornet",
	.id		= ITEM_HORNETGUN,
	.slot		= 3,
	.slot_pos	= 3,
	.draw		= w_hornetgun_draw,
	.holster	= w_hornetgun_holster,
	.primary	= w_hornetgun_primary,
	.secondary	= w_hornetgun_secondary,
	.reload		= __NULL__,
	.release	= w_hornetgun_release,
	.crosshair	= w_hornetgun_crosshair,
	.precache	= w_hornetgun_precache,
	.pickup		= w_hornetgun_pickup,
	.updateammo	= w_hornetgun_updateammo,
	.wmodel		= w_hornetgun_wmodel,
	.pmodel		= w_hornetgun_pmodel,
	.deathmsg	= w_hornetgun_deathmsg,
	.aimanim	= w_hornetgun_aimanim,
	.hudpic		= w_hornetgun_hudpic
};

#ifdef SERVER
void
weapon_hornetgun(void)
{
	Weapons_InitItem(WEAPON_HORNETGUN);
}
#endif
