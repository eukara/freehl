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

/*QUAKED weapon_9mmAR (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_9mmar.mdl"

HALF-LIFE (1998) ENTITY

MP5/9mmAR Weapon
Same as weapon_mp5

*/

/*QUAKED weapon_mp5 (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_9mmar.mdl"

HALF-LIFE (1998) ENTITY

MP5/9mmAR Weapon
Same as weapon_9mmAR

*/

/* Animations */
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

void
w_mp5_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_mp5.shoot");
	Sound_Precache("weapon_mp5.gl");
	precache_model("models/w_9mmar.mdl");
	precache_model("models/grenade.mdl");
#else
	precache_model("models/v_9mmar.mdl");
	precache_model("models/p_9mmar.mdl");
#endif
}

int
w_mp5_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		pl.mp5_mag = 25;
	} else {
		if (pl.ammo_9mm < MAX_A_9MM) {
			pl.ammo_9mm = bound(0, pl.ammo_9mm + 25, MAX_A_9MM);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
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
w_mp5_pmodel(void)
{
	return "models/p_9mmar.mdl";
}

string
w_mp5_deathmsg(void)
{
	return "";
}

void
w_mp5_draw(void)
{
#ifdef CLIENT
	Weapons_SetModel("models/v_9mmar.mdl");
	Weapons_ViewAnimation(MP5_DRAW);
#endif
}

void
w_mp5_holster(void)
{
	Weapons_ViewAnimation(MP5_DRAW);
}

void
w_mp5_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* Ammo check */
	if (pl.mp5_mag <= 0) {
		return;
	}

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);
#else
	/* singleplayer is more accurate */
	if (cvar("sv_playerslots") == 1) {
		TraceAttack_FireBullets(1, Weapons_GetCameraPos(), Skill_GetValue("plr_9mmAR_bullet", 5), [0.025,0.025], WEAPON_MP5);
	} else {
		TraceAttack_FireBullets(1, Weapons_GetCameraPos(), Skill_GetValue("plr_9mmAR_bullet", 5), [0.05,0.05], WEAPON_MP5);
	}

	Sound_Play(pl, CHAN_WEAPON, "weapon_mp5.shoot");
#endif

	pl.mp5_mag--;

	/* Actual firing */
	int r = (float)input_sequence % 2;
	if (r) {
		Weapons_ViewAnimation(MP5_FIRE1);
	} else {
		Weapons_ViewAnimation(MP5_FIRE2);
	}

	Weapons_ViewPunchAngle([-2,0,0]);

	pl.w_attack_next = 0.1f;
	pl.w_idle_next = 10.0f;
}

void
w_mp5_secondary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}


	if (pl.ammo_m203_grenade <= 0) {
		return;
	}

	pl.ammo_m203_grenade--;

#ifdef CLIENT
	Weapons_ViewPunchAngle([-10,0,0]);
	Weapons_ViewAnimation(MP5_GRENADE);
#else
	static void Grenade_ExplodeTouch(void) {
		float dmg = Skill_GetValue("plr_9mmAR_grenade", 100);
		FX_Explosion(self.origin);
		Damage_Radius(self.origin, self.owner, dmg, dmg * 2.5f, TRUE, WEAPON_MP5);

		if (random() < 0.5) {
			sound(self, 1, "weapons/explode3.wav", 1, ATTN_NORM);
		} else {
			sound(self, 1, "weapons/explode4.wav", 1, ATTN_NORM);
		}
		remove(self);
	}

	Weapons_MakeVectors();
	entity gren = spawn();
	setmodel(gren, "models/grenade.mdl");
	setorigin(gren, Weapons_GetCameraPos() + (v_forward * 16));
	gren.owner = self;
	gren.velocity = v_forward * 800;
	gren.angles = vectoangles(gren.velocity);
	gren.avelocity[0] = random(-100, -500);
	gren.gravity = 0.5f;
	gren.movetype = MOVETYPE_BOUNCE;
	//gren.flags |= FL_LAGGEDMOVE;
	gren.solid = SOLID_BBOX;
	setsize(gren, [0,0,0], [0,0,0]);
	gren.touch = Grenade_ExplodeTouch;
	Sound_Play(pl, CHAN_WEAPON, "weapon_mp5.gl");
#endif

	pl.w_attack_next = 1.0f;
	pl.w_idle_next = 10.0f;
}

void
w_mp5_reload(void)
{
	player pl = (player)self;
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

#ifdef CLIENT
	Weapons_ViewAnimation(MP5_RELOAD);
#else
	Weapons_ReloadWeapon(pl, player::mp5_mag, player::ammo_9mm, 50);
#endif

	pl.w_attack_next = 1.5f;
	pl.w_idle_next = 10.0f;
}

void
w_mp5_release(void)
{
	player pl = (player)self;

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.mp5_mag == 0 && pl.ammo_9mm > 0) {
		Weapons_Reload();
		return;
	}
	if (pl.w_idle_next > 0.0) {
		return;
	}

	int r = (float)input_sequence % 3;
	if (r == 1) {
		Weapons_ViewAnimation(MP5_IDLE1);
	} else {
		Weapons_ViewAnimation(MP5_IDLE2);
	}

	pl.w_idle_next = 15.0f;
}

void
w_mp5_crosshair(void)
{
#ifdef CLIENT
	vector cross_pos;
	vector aicon_pos;

	cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];

	drawsubpic(
		cross_pos,
		[24,24],
		g_cross_spr,
		[24/128,48/128],
		[0.1875, 0.1875],
		[1,1,1],
		1.0f,
		DRAWFLAG_NORMAL
	);

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
		pSeat->m_flAmmo2Alpha,
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
		pSeat->m_flAmmo3Alpha,
		DRAWFLAG_ADDITIVE
	);
#endif
}

float
w_mp5_aimanim(void)
{
	return self.flags & ANIM_CR_AIMMP5 ? ANIM_CR_AIMCROWBAR : ANIM_AIMMP5;
}

void
w_mp5_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;
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

weapon_t w_mp5 =
{
	.name		= "9mmAR",
	.id		= ITEM_MP5,
	.slot		= 2,
	.slot_pos	= 0,
	.draw		= w_mp5_draw,
	.holster	= w_mp5_holster,
	.primary	= w_mp5_primary,
	.secondary	= w_mp5_secondary,
	.reload		= w_mp5_reload,
	.release	= w_mp5_release,
	.crosshair	= w_mp5_crosshair,
	.precache	= w_mp5_precache,
	.pickup		= w_mp5_pickup,
	.updateammo	= w_mp5_updateammo,
	.wmodel		= w_mp5_wmodel,
	.pmodel		= w_mp5_pmodel,
	.deathmsg	= w_mp5_deathmsg,
	.aimanim	= w_mp5_aimanim,
	.hudpic		= w_mp5_hudpic
};

#ifdef SERVER
void
weapon_9mmAR(void)
{
	Weapons_InitItem(WEAPON_MP5);
}

void
weapon_mp5(void)
{
	Weapons_InitItem(WEAPON_MP5);
}
#endif
