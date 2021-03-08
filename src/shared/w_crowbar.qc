/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

/*QUAKED weapon_crowbar (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_crowbar.mdl"

HALF-LIFE (1998) ENTITY

Crowbar Weapon

*/

enum
{
	CBAR_IDLE,
	CBAR_DRAW,
	CBAR_HOLSTER,
	CBAR_ATTACK1HIT,
	CBAR_ATTACK1MISS,
	CBAR_ATTACK2MISS,
	CBAR_ATTACK2HIT,
	CBAR_ATTACK3MISS,
	CBAR_ATTACK3HIT
};

void
w_crowbar_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_crowbar.hit");
	Sound_Precache("weapon_crowbar.miss");
	Sound_Precache("weapon_crowbar.hitbody");
	precache_model("models/w_crowbar.mdl");
#else
	precache_model("models/v_crowbar.mdl");
	precache_model("models/p_crowbar.mdl");
#endif
}

void
w_crowbar_updateammo(player pl)
{

}

string
w_crowbar_wmodel(void)
{
	return "models/w_crowbar.mdl";
}
string
w_crowbar_pmodel(void)
{
	return "models/p_crowbar.mdl";
}

string
w_crowbar_deathmsg(void)
{
	return "%s was assaulted by %s's Crowbar.";
}

void
w_crowbar_draw(void)
{
	Weapons_SetModel("models/v_crowbar.mdl");
	Weapons_ViewAnimation(CBAR_DRAW);
}

void
w_crowbar_holster(void)
{
	Weapons_ViewAnimation(CBAR_HOLSTER);
}

void
w_crowbar_primary(void)
{
	int anim = 0;
	vector src;
	player pl = (player)self;

	if (pl.w_attack_next) {
		return;
	}

	Weapons_MakeVectors();
	src = pl.origin + pl.view_ofs;

	/* make sure we can gib corpses */
	int oldhitcontents = self.hitcontentsmaski;
	self.hitcontentsmaski = CONTENTBITS_POINTSOLID | CONTENTBIT_CORPSE;
	traceline(src, src + (v_forward * 32), FALSE, pl);
	self.hitcontentsmaski = oldhitcontents;

	if (trace_fraction >= 1.0) {
		pl.w_attack_next = 0.5f;
	} else {
		pl.w_attack_next = 0.25f;
	}
	pl.w_idle_next = 2.5f;

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(trace_fraction >= 1 ? CBAR_ATTACK1MISS:CBAR_ATTACK1HIT);
		break;
	case 1:
		Weapons_ViewAnimation(trace_fraction >= 1 ? CBAR_ATTACK2MISS:CBAR_ATTACK2HIT);
		break;
	default:
		Weapons_ViewAnimation(trace_fraction >= 1 ? CBAR_ATTACK3MISS:CBAR_ATTACK3HIT);
	}

	if (pl.flags & FL_CROUCHING) {
		Animation_PlayerTopTemp(ANIM_SHOOTCROWBAR, 0.5f);
	} else {
		Animation_PlayerTopTemp(ANIM_CR_SHOOTCROWBAR, 0.42f);
	}

#ifdef SERVER
	Sound_Play(self, CHAN_WEAPON, "weapon_crowbar.miss");

	if (trace_fraction >= 1.0) {
		return;
	}

	/* don't bother with decals, we got squibs */
	if (trace_ent.iBleeds) {
		FX_Blood(trace_endpos, [1,0,0]);
	} else {
		FX_Impact(IMPACT_MELEE, trace_endpos, trace_plane_normal);
	}

	if (trace_ent.takedamage) {
		Damage_Apply(trace_ent, pl, Skill_GetValue("plr_crowbar", 10), WEAPON_CROWBAR, DMG_BLUNT);
		if (trace_ent.iBleeds) {
			Sound_Play(self, CHAN_WEAPON, "weapon_crowbar.hitbody");
		}
	} else {
		Sound_Play(self, CHAN_WEAPON, "weapon_crowbar.hit");
	}
#endif
}

void
w_crowbar_release(void)
{
	player pl = (player)self;

	if (pl.w_idle_next) {
		return;
	}

	Weapons_ViewAnimation(CBAR_IDLE);
	pl.w_idle_next = 15.0f;
}

float
w_crowbar_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_crowbar_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud4_spr,
			[0,0],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			g_hud1_spr,
			[0,0],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_crowbar =
{
	.name		= "crowbar",
	.id		= ITEM_CROWBAR,
	.slot		= 0,
	.slot_pos	= 0,
	.draw		= w_crowbar_draw,
	.holster	= w_crowbar_holster,
	.primary	= w_crowbar_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_crowbar_release,
	.crosshair	= __NULL__,
	.precache	= w_crowbar_precache,
	.pickup		= __NULL__,
	.updateammo	= w_crowbar_updateammo,
	.wmodel		= w_crowbar_wmodel,
	.pmodel		= w_crowbar_pmodel,
	.deathmsg	= w_crowbar_deathmsg,
	.aimanim	= w_crowbar_aimanim,
	.hudpic		= w_crowbar_hudpic
};

/* entity definitions for pickups */
#ifdef SERVER
void
weapon_crowbar(void)
{
	Weapons_InitItem(WEAPON_CROWBAR);
}
#endif
