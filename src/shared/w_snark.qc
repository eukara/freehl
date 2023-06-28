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
	SNARK_IDLE,
	SNARK_FIDGET1,
	SNARK_FIDGET2,
	SNARK_HOLSTER,
	SNARK_DRAW,
	SNARK_THROW
};

#ifdef SERVER
class monster_snark:NSMonster
{
	float m_flJump;
	entity m_eTarget;

	void(void) monster_snark;

	virtual void(void) customphysics;
	virtual void(void) Pain;
	virtual void(void) Death;
	virtual void(void) Respawn;
};

void
monster_snark::customphysics(void)
{
	input_movevalues = [250,0,0];
	input_buttons = 0;
	input_impulse = 0;
	input_angles = angles;
	input_timelength = frametime;
	
	if (health <= 0) {
		return;
	}

	if (m_flJump <= 0.0 && m_eTarget == __NULL__) {
		float shortest = 999999;
		for (entity ef = world; (ef = findfloat(ef, ::movetype, MOVETYPE_WALK));) {
			float len = vlen(ef.origin - origin);
			if (ef.classname != "monster_snark" && len < shortest && ef.health > 0) {
				owner = __NULL__;
				m_eTarget = ef;
				shortest = len;
			}
		}
	} 

	if (m_eTarget) {
		angles = input_angles = vectoangles(m_eTarget.origin - origin);
	}

	if (m_eTarget && m_flJump <= 0.0) {
		m_flJump = 0.5f + random();
		Sound_Play(this, CHAN_VOICE, "weapon_snark.hunt");
		input_buttons = 2;
		Damage_Apply(this, world, 1, 0, DMG_GENERIC);

		makevectors(angles);
		traceline(origin, origin + (v_forward * 128), 0, this);

		if (trace_ent.takedamage == DAMAGE_YES) {
			Sound_Play(this, CHAN_BODY, "weapon_snark.deploy");
			Damage_Apply(trace_ent, real_owner, Skill_GetValue("snark_dmg_bite", 10), WEAPON_SNARK, DMG_GENERIC);
			FX_Blood(origin + [0,0,16], [1,0,0]);
		}

		/* TODO this needs to be cleaned up and use isAlive in the future */
		if (m_eTarget.solid == SOLID_CORPSE) {
			m_eTarget = __NULL__;
		}
	}

	m_flJump -= frametime;

	mins = [0,0,0];
	maxs = [0,0,0];
	runstandardplayerphysics(this);
	mins = [-8.0f, -8.0f, 0.0f];
	mins = [8.0f, 8.0f, 8.0f];
}

void
monster_snark::Pain(void)
{
	/* anything else will kill us immediately */
	if (g_dmg_eAttacker != world) {
		health = 0;
		Death();
	}
}

void
monster_snark::Death(void)
{
	float dmg = Skill_GetValue("snark_dmg_pop", 5);
	Damage_Radius(origin, goalentity, dmg, dmg * 2.5f, TRUE, WEAPON_SNARK);
	FX_Blood(origin + [0,0,16], [203,183,15] / 255);
	Sound_Play(this, CHAN_VOICE, "weapon_snark.die");
	Sound_Play(this, CHAN_BODY, "weapon_snark.blast");
	customphysics = __NULL__;
	Destroy();
}

void
monster_snark::Respawn(void)
{
	netname = "Snark";
	SetModel("models/w_squeak.mdl");
	flags |= FL_MONSTER;
	SetSolid(SOLID_CORPSE);
	SetMovetype(MOVETYPE_WALK);
	SetSize([-8,-8,0], [8,8,8]);
	SetFrame(3); /* running like crazy. */
	angles = goalentity.angles;
	health = 20;
	takedamage = DAMAGE_YES;
	m_eTarget = __NULL__;
	m_flJump = 1.0f;
	owner = __NULL__;
}

void
monster_snark::monster_snark(void)
{
	Respawn();
}
#endif

int w_snark_pickup(player pl, int new, int startammo)
{
#ifdef SERVER
	int addAmmo = (startammo == -1) ? 5 : startammo;

	if (pl.ammo_snark < MAX_A_SNARK) {
		pl.ammo_snark = bound(0, pl.ammo_snark + addAmmo, MAX_A_SNARK);
	} else {
		if (!new)
			return (0);
	}
#endif
	return (1);
}

void w_snark_draw(player pl)
{
	Weapons_SetModel("models/v_squeak.mdl");
	Weapons_ViewAnimation(pl, SNARK_DRAW);
}

void w_snark_holster(player pl)
{
	
}

#ifdef SERVER
void w_snark_deploy(entity snark_owner)
{
	monster_snark snark = spawn(monster_snark, real_owner: snark_owner, goalentity: snark_owner, spawnflags: MSF_MULTIPLAYER);
	makevectors(snark_owner.v_angle);
	snark.Respawn();
	snark.SetOrigin(snark_owner.origin + v_forward * 32);
}
#endif

void w_snark_primary(player pl)
{
	if (pl.WaterLevel() >= WATERLEVEL_SUBMERGED)
		return;
	if (pl.w_attack_next > 0.0)
		return;
	if (pl.ammo_snark <= 0)
		return;

	pl.ammo_snark--;

	/* Audio-Visual Bit */
	Weapons_ViewAnimation(pl, SNARK_THROW);

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CR_SHOOTSQUEAK, 0.41f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOTSQUEAK, 0.5f);

#ifdef SERVER
	w_snark_deploy(pl);

	if (pl.ammo_snark <= 0) {
		Weapons_RemoveItem(pl, WEAPON_SNARK);
	}
#endif

	pl.w_idle_next = 1.0f;
	pl.w_attack_next = 0.25f;

}

void w_snark_secondary(player pl)
{
	
}

void w_snark_reload(player pl)
{
	
}

void w_snark_release(player pl)
{
	int r;

	if (pl.w_idle_next > 0.0) {
		return;
	}

	r = floor(pseudorandom() * 3.0f);
	switch (r) {
	case 0:
		Weapons_ViewAnimation(pl, SNARK_IDLE);
		pl.w_idle_next = 1.875f;
		break;
	case 1:
		Weapons_ViewAnimation(pl, SNARK_FIDGET1);
		pl.w_idle_next = 4.375f;
		break;
	default:
		Weapons_ViewAnimation(pl, SNARK_FIDGET2);
		pl.w_idle_next = 5.0f;
		break;
	}
}

void w_snark_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_snark.deploy");
	Sound_Precache("weapon_snark.die");
	Sound_Precache("weapon_snark.blast");
	Sound_Precache("weapon_snark.hunt");
	precache_model("models/w_sqknest.mdl");
	precache_model("models/w_squeak.mdl");
#else
	precache_model("models/p_squeak.mdl");
	precache_model("models/v_squeak.mdl");
#endif
}

void w_snark_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, pl.ammo_snark, -1);
}

string w_snark_wmodel(void)
{
	return "models/w_sqknest.mdl";
}

string w_snark_pmodel(player pl)
{
	return "models/p_squeak.mdl";
}

string w_snark_deathmsg(void)
{
	return "";
}

float w_snark_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? ANIM_CR_AIMSQUEAK : ANIM_AIMSQUEAK;
}

void w_snark_hud(player pl)
{
#ifdef CLIENT
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [96/256,96/128], [24/256, 24/128], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void w_snark_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(pos, [170,45], g_hud6_spr,
			[0,135/256], [170/256,45/256],
			g_hud_color, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], g_hud3_spr,
			[0,135/256], [170/256,45/256],
			g_hud_color, a, DRAWFLAG_ADDITIVE);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_snark, MAX_A_SNARK, a);
#endif
}

int
w_snark_isempty(player pl)
{

	if (pl.ammo_snark <= 0)
		return 1;

	return 0;
}

weapontype_t
w_snark_type(player pl)
{
	return WPNTYPE_RANGED;
}

weapon_t w_snark =
{
	.name		= "snark",
	.id			= ITEM_SNARK,
	.slot		= 4,
	.slot_pos	= 3,
	.weight		= 5,
	.draw		= w_snark_draw,
	.holster	= w_snark_holster,
	.primary	= w_snark_primary,
	.secondary	= w_snark_secondary,
	.reload		= w_snark_reload,
	.release	= w_snark_release,
	.postdraw	= w_snark_hud,
	.precache	= w_snark_precache,
	.pickup		= w_snark_pickup,
	.updateammo	= w_snark_updateammo,
	.wmodel		= w_snark_wmodel,
	.pmodel		= w_snark_pmodel,
	.deathmsg	= w_snark_deathmsg,
	.aimanim	= w_snark_aimanim,
	.isempty	= w_snark_isempty,
	.type		= w_snark_type,
	.hudpic		= w_snark_hudpic
};