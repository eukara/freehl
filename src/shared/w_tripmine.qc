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
	TRIPMINE_IDLE1,
	TRIPMINE_IDLE2,
	TRIPMINE_FIRE1,
	TRIPMINE_FIRE2,
	TRIPMINE_FIDGET,
	TRIPMINE_HOLSTER,
	TRIPMINE_DRAW,
	TRIPMINE_WORLD,
	TRIPMINE_GROUND,
};

/* MONSTER_TRIPMINE SEGMENT 
 * 
 * Because not being able to place it around levels would be boring.
 * Some maps, such as subtransit and a few singleplayer chapters have this. */

#ifdef SERVER
class monster_tripmine:NSMonster
{
	vector m_vecEndPos;
	void(void) monster_tripmine;

	virtual float(entity, float) SendEntity;
	virtual void(int) Trip;
	virtual void(void) Damaged;
	virtual void(void) Ready;
	virtual void(void) Respawn;
};

float
monster_tripmine::SendEntity(entity pvsent, float flags)
{
	WriteByte(MSG_ENTITY, ENT_TRIPMINE);
	WriteCoord(MSG_ENTITY, origin[0]);
	WriteCoord(MSG_ENTITY, origin[1]);
	WriteCoord(MSG_ENTITY, origin[2]);
	WriteCoord(MSG_ENTITY, angles[0]);
	WriteCoord(MSG_ENTITY, angles[1]);
	WriteCoord(MSG_ENTITY, angles[2]);
	WriteCoord(MSG_ENTITY, m_vecEndPos[0]);
	WriteCoord(MSG_ENTITY, m_vecEndPos[1]);
	WriteCoord(MSG_ENTITY, m_vecEndPos[2]);
	WriteByte(MSG_ENTITY, health);
	return (1);
}

void
monster_tripmine::Trip(int walkthrough)
{
	vector explosionPos = GetOrigin();
	float explosionDamage = Skill_GetValue("plr_tripmine", 150);
	float explosionRadius = explosionDamage * 2.5f;

	if (!walkthrough) {
		real_owner = g_dmg_eAttacker;
	}

	/* This is to prevent infinite loops in Damage_Radius */
	SetPainCallback(__NULL__);
	SetDeathCallback(__NULL__);
	SetTakedamage(DAMAGE_NO);

	pointparticles(particleeffectnum("fx_explosion.main"), GetOrigin(), [0,0,0], 1);
	Damage_Radius(explosionPos, real_owner, explosionDamage, explosionRadius, true, WEAPON_TRIPMINE);
	StartSoundDef("fx.explosion", CHAN_VOICE, true);
	Destroy();
}

void
monster_tripmine::Damaged(void)
{
	Trip(0);
}

void
monster_tripmine::Ready(void)
{
	traceline(origin, origin + GetForward() * 2048, FALSE, this);

	/* first time we're marked as ready, we play a sound and set the distance */
	if (CanBeDamaged() == false) {
		/* Laser calibrated to N units! */
		m_vecEndPos = trace_endpos;
		SetHealth(1);
		SetTakedamage(DAMAGE_YES);
		StartSoundDef("weapon_tripmine.activate", CHAN_WEAPON, true);
		SetSolid(SOLID_BBOX);
		SetPainCallback(Damaged);
		SetDeathCallback(Damaged);
		ForceNetworkUpdate();
	}

	/* laser shorter than when calibrated, explode! */
	if (trace_endpos != m_vecEndPos) {
		Trip(1);
		return;
	}

	/* run this method again next frame */
	ScheduleThink(Ready, 0.0f);
}

void
monster_tripmine::Respawn(void)
{
	SetTakedamage(DAMAGE_NO);
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_NONE);
	SetSize([-8,-8,-8], [8,8,8]);

	/* fast beam */
	if (HasSpawnFlags(1)) {
		ScheduleThink(Ready, 0.0f);
	} else {
		ScheduleThink(Ready, 4.0f);
	}
}

void
monster_tripmine::monster_tripmine(void)
{
	Respawn();
}
#else
class csitem_tripmine
{
	int m_iActive;
	vector m_vecEndPos;

	void(void) csitem_tripmine;
	virtual float(void) predraw;
};

float csitem_tripmine::predraw(void)
{
	if (m_iActive) {
		trailparticles(BEAM_TRIPMINE, this, origin, m_vecEndPos);
	}

	addentity(this);
	return PREDRAW_NEXT;
}

void
csitem_tripmine::csitem_tripmine(void)
{
	solid = SOLID_BBOX;
	movetype = MOVETYPE_NONE;
	drawmask = MASK_ENGINE;
	frame = TRIPMINE_WORLD;
	m_iActive = FALSE;
}

void w_tripmine_parse(void)
{
	csitem_tripmine tm = (csitem_tripmine)self;
	spawnfunc_csitem_tripmine();

	tm.origin[0] = readcoord();
	tm.origin[1] = readcoord();
	tm.origin[2] = readcoord();
	tm.angles[0] = readcoord();
	tm.angles[1] = readcoord();
	tm.angles[2] = readcoord();
	tm.m_vecEndPos[0] = readcoord();
	tm.m_vecEndPos[1] = readcoord();
	tm.m_vecEndPos[2] = readcoord();
	tm.m_iActive = readbyte();
	setmodel(tm, "models/v_tripmine.mdl");

	setcustomskin(tm, "", "geomset 0 2\ngeomset 1 2\n");
	setorigin(tm, tm.origin);
	setsize(tm, [-8,-8,-8], [8,8,8]);
}
#endif

/* The WEAPON_TRIPMINE code
 * 
 * Here is where the actual 'weapon' logic happens that the player itself
 * runs. It obviously won't work without MONSTER_TRIPMINE */

void w_tripmine_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_tripmine.deploy");
	Sound_Precache("weapon_tripmine.charge");
	Sound_Precache("weapon_tripmine.activate");
	precache_model("models/v_tripmine.mdl");
#else
	precache_model("models/p_tripmine.mdl");
	precache_model("models/v_tripmine.mdl");
#endif
}

void w_tripmine_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, pl.ammo_tripmine, -1);
}

string w_tripmine_wmodel(void)
{
	return "models/v_tripmine.mdl";
}

string w_tripmine_pmodel(player pl)
{
	return "models/p_tripmine.mdl";
}

string w_tripmine_deathmsg(void)
{
	return "";
}

int w_tripmine_pickup(player pl, int new, int startammo)
{
#ifdef SERVER
	int addAmmo = (startammo == -1) ? 1 : startammo;

	if (pl.ammo_tripmine < MAX_A_TRIPMINE) {
		pl.ammo_tripmine = bound(0, pl.ammo_tripmine + addAmmo, MAX_A_TRIPMINE);
	} else {
		if (!new)
			return (0);
	}
#endif
	return (1);
}

void w_tripmine_draw(player pl)
{
	Weapons_SetModel("models/v_tripmine.mdl");
	Weapons_ViewAnimation(pl, TRIPMINE_DRAW);
}

void w_tripmine_holster(player pl)
{
	
}

void
w_tripmine_primary(player pl)
{
	vector src;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	if (pl.ammo_tripmine <= 0) {
		return;
	}

	src = Weapons_GetCameraPos(pl);
	Weapons_MakeVectors(pl);
	traceline(src, src + v_forward * 64, FALSE, pl);

	if (trace_fraction >= 1.0) {
		return;
	}

	pl.ammo_tripmine--;

	Weapons_ViewAnimation(pl, TRIPMINE_FIRE2);

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CR_SHOOTTRIPMINE, 0.41f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOTTRIPMINE, 0.5f);

#ifdef SERVER
	vector ang = vectoangles(trace_plane_normal);
	monster_tripmine mine = spawn(monster_tripmine, real_owner: pl, angles: ang, spawnflags: MSF_MULTIPLAYER);
	mine.health = 0;
	mine.SetOrigin(trace_endpos + (trace_plane_normal * 8));

	Sound_Play(pl, CHAN_WEAPON, "weapon_tripmine.deploy");
	Sound_Play(mine, CHAN_WEAPON, "weapon_tripmine.charge");
#endif

	pl.a_ammo3 = 1;
	pl.w_attack_next =
	pl.w_idle_next = 0.5f;
}

void
w_tripmine_release(player pl)
{
	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.a_ammo3 == 1) {
		Weapons_ViewAnimation(pl, TRIPMINE_DRAW);
#ifdef SERVER
		if (pl.ammo_tripmine <= 0) {
			Weapons_RemoveItem(pl, WEAPON_TRIPMINE);
		}
#endif
		pl.a_ammo3 = 0;
		pl.w_attack_next = 0.5f;
		pl.w_idle_next = 3.0f;
		return;
	}

	int r = (float)input_sequence % 3.0f;
	switch (r) {
	case 1:
		Weapons_ViewAnimation(pl, TRIPMINE_IDLE1);
		pl.w_idle_next = 3.0f;
		break;
	case 2:
		Weapons_ViewAnimation(pl, TRIPMINE_IDLE2);
		pl.w_idle_next = 2.0f;
		break;
	default:
		Weapons_ViewAnimation(pl, TRIPMINE_FIDGET);
		pl.w_idle_next = 3.34f;
		break;
	}
}

float
w_tripmine_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? ANIM_CR_AIMTRIPMINE : ANIM_AIMTRIPMINE;
}

void
w_tripmine_hud(player pl)
{
#ifdef CLIENT
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [120/256,96/128], [24/256, 24/128], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_tripmine_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(pos, [170,45], g_hud6_spr, [0,90/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], g_hud3_spr, [0,90/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_tripmine, MAX_A_TRIPMINE, a);
#endif
}

int
w_tripmine_isempty(player pl)
{
	if (pl.ammo_tripmine <= 0)
		return 1;

	return 0;
}

weapontype_t
w_tripmine_type(player pl)
{
	return WPNTYPE_CLOSE;
}

weapon_t w_tripmine =
{
	.name		= "tripmine",
	.id			= ITEM_TRIPMINE,
	.slot		= 4,
	.slot_pos	= 2,
	.weight		= -10,
	.draw		= w_tripmine_draw,
	.holster	= w_tripmine_holster,
	.primary	= w_tripmine_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_tripmine_release,
	.postdraw	= w_tripmine_hud,
	.precache	= w_tripmine_precache,
	.pickup		= w_tripmine_pickup,
	.updateammo	= w_tripmine_updateammo,
	.wmodel		= w_tripmine_wmodel,
	.pmodel		= w_tripmine_pmodel,
	.deathmsg	= w_tripmine_deathmsg,
	.aimanim	= w_tripmine_aimanim,
	.isempty	= w_tripmine_isempty,
	.type		= w_tripmine_type,
	.hudpic		= w_tripmine_hudpic
};