/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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
w_crowbar_pmodel(player pl)
{
	return "models/p_crowbar.mdl";
}

string
w_crowbar_deathmsg(void)
{
	return "%s was assaulted by %s's Crowbar.";
}

void
w_crowbar_draw(player pl)
{
	Weapons_SetModel("models/v_crowbar.mdl");
	Weapons_ViewAnimation(pl, CBAR_DRAW);
}

void
w_crowbar_holster(player pl)
{
	Weapons_ViewAnimation(pl, CBAR_HOLSTER);
}

void
w_crowbar_primary(player pl)
{
	int anim = 0;
	vector src;

	if (pl.w_attack_next) {
		return;
	}

	Weapons_MakeVectors(pl);
	src = pl.origin + pl.view_ofs;

	/* make sure we can gib corpses */
	int oldhitcontents = pl.hitcontentsmaski;
	pl.hitcontentsmaski = CONTENTBITS_POINTSOLID | CONTENTBIT_CORPSE;
	traceline(src, src + (v_forward * 32), FALSE, pl);
	pl.hitcontentsmaski = oldhitcontents;

	if (trace_fraction >= 1.0) {
		pl.w_attack_next = 0.5f;
	} else {
		pl.w_attack_next = 0.25f;
	}
	pl.w_idle_next = 2.5f;

	int r = (float)input_sequence % 3.0f;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(pl, trace_fraction >= 1 ? CBAR_ATTACK1MISS:CBAR_ATTACK1HIT);
		break;
	case 1:
		Weapons_ViewAnimation(pl, trace_fraction >= 1 ? CBAR_ATTACK2MISS:CBAR_ATTACK2HIT);
		break;
	default:
		Weapons_ViewAnimation(pl, trace_fraction >= 1 ? CBAR_ATTACK3MISS:CBAR_ATTACK3HIT);
	}

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CR_SHOOTCROWBAR, 0.41f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOTCROWBAR, 0.5f);

#ifdef SERVER
	Sound_Play(pl, CHAN_WEAPON, "weapon_crowbar.miss");

	if (trace_fraction >= 1.0) {
		return;
	}

	/* don't bother with decals, we got squibs */
	if (trace_ent.iBleeds) {
		FX_Blood(trace_endpos, [1,0,0]);
	}

	if (trace_ent.takedamage) {
		Damage_Apply(trace_ent, pl, Skill_GetValue("plr_crowbar", 10), WEAPON_CROWBAR, DMG_BLUNT);
		if (trace_ent.iBleeds) {
			Sound_Play(pl, CHAN_WEAPON, "weapon_crowbar.hitbody");
		}
	} else {
		Sound_Play(pl, CHAN_WEAPON, "weapon_crowbar.hit");
		DecalGroups_Place("Impact.Shot", trace_endpos + (v_forward * -2));
	}
#endif
}

void
w_crowbar_release(player pl)
{
	if (pl.w_idle_next) {
		return;
	}

	Weapons_ViewAnimation(pl, CBAR_IDLE);
	pl.w_idle_next = 15.0f;
}

float
w_crowbar_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_crowbar_hudpic(player pl, int selected, vector pos, float a)
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

int
w_crowbar_isempty(player pl)
{
	return 0;
}

weapontype_t w_crowbar_type(player pl)
{
	return WPNTYPE_CLOSE;
}

weapon_t w_crowbar =
{
	.name		= "crowbar",
	.id			= ITEM_CROWBAR,
	.slot		= 0,
	.slot_pos	= 0,
	.weight		= 0,
	.draw		= w_crowbar_draw,
	.holster	= w_crowbar_holster,
	.primary	= w_crowbar_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_crowbar_release,
	.postdraw	= __NULL__,
	.precache	= w_crowbar_precache,
	.pickup		= __NULL__,
	.updateammo	= w_crowbar_updateammo,
	.wmodel		= w_crowbar_wmodel,
	.pmodel		= w_crowbar_pmodel,
	.deathmsg	= w_crowbar_deathmsg,
	.aimanim	= w_crowbar_aimanim,
	.isempty	= w_crowbar_isempty,
	.type		= w_crowbar_type,
	.hudpic		= w_crowbar_hudpic
};
