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

class hlTripmine:ncSurfacePropEntity
{
	void hlTripmine(void);

#ifdef SERVER
	virtual void Respawn(void);
	virtual void Spawned(void);
	virtual void Ready(void);
	virtual void Pain(entity, entity, int, vector, vector, int);
	virtual void Death(entity, entity, int, vector, vector, int);
	virtual float SendEntity(entity, float);
#endif

#ifdef CLIENT
	virtual float predraw(void);
	virtual void ReceiveEntity(float, float);
#endif

private:

	vector m_vecEndPos;

#ifdef CLIENT
	int m_iActive;
#endif
};

void
hlTripmine::hlTripmine(void)
{
#ifdef CLIENT
	solid = SOLID_BBOX;
	movetype = MOVETYPE_NONE;
	drawmask = MASK_ENGINE;
	frame = TRIPMINE_WORLD;
	m_iActive = FALSE;
#endif
}

#ifdef SERVER
void
hlTripmine::Respawn(void)
{
	super::Respawn();
	RestoreAngles();
}

void
hlTripmine::Spawned(void)
{
	super::Spawned();

	MakeInvulnerable();
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_NONE);
	SetSize([-8,-8,-8], [8,8,8]);

	/* fast beam */
	if (HasSpawnFlags(1)) {
		ScheduleThink(Ready, 0.0f);
	} else {
		ScheduleThink(Ready, 4.0f);
		StartSoundDef("TripmineGrenade.Charge", CHAN_VOICE, true);
	}
}

void
hlTripmine::Death(entity inflictor, entity attacker, int damage, vector dir, vector absImpactPos, int hitBody)
{
	vector explosionPos = GetOrigin();
	float explosionDamage = Skill_GetValue("plr_tripmine", 150);
	float explosionRadius = explosionDamage * 2.5f;

	/* This is to prevent infinite loops in Damage_Radius */
	MakeInvulnerable();

	pointparticles(particleeffectnum("fx_explosion.main"), GetOrigin(), [0,0,0], 1);

	combat.RadiusDamage(explosionPos, explosionRadius, 0i, (int)explosionDamage, attacker, "");
	StartSoundDef("fx.explosion", CHAN_VOICE, true);
	Destroy();
}

void
hlTripmine::Pain(entity inflictor, entity attacker, int damage, vector dir, vector absImpactPos, int hitBody)
{
	Death(inflictor, attacker, damage, dir, absImpactPos, hitBody);
}

void
hlTripmine::Ready(void)
{
	traceline(origin, origin + GetForward() * 2048, FALSE, this);

	/* first time we're marked as ready, we play a sound and set the distance */
	if (takedamage == DAMAGE_NO) {
		/* Laser calibrated to N units! */
		m_vecEndPos = trace_endpos;
		SetHealth(1);
		MakeVulnerable();
		StartSoundDef("TripmineGrenade.Activate", CHAN_WEAPON, true);
		SetSolid(SOLID_BBOX);
		ForceNetworkUpdate();
	}

	/* laser shorter than when calibrated, explode! */
	if (trace_endpos != m_vecEndPos) {
		Death(trace_ent, real_owner, 0, g_vec_null, origin, 0);
		return;
	}

	/* run this method again next frame */
	ScheduleThink(Ready, 0.0f);
}

float
hlTripmine::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_TRIPMINE);
	WriteFloat(MSG_ENTITY, flChanged);
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
#endif

#ifdef CLIENT
void
hlTripmine::ReceiveEntity(float flNew, float flChanged)
{
	this.origin[0] = readcoord();
	this.origin[1] = readcoord();
	this.origin[2] = readcoord();
	this.angles[0] = readcoord();
	this.angles[1] = readcoord();
	this.angles[2] = readcoord();
	this.m_vecEndPos[0] = readcoord();
	this.m_vecEndPos[1] = readcoord();
	this.m_vecEndPos[2] = readcoord();
	this.m_iActive = readbyte();

	setmodel(this, "models/v_tripmine.mdl");

	setcustomskin(this, "", "geomset 0 2\ngeomset 1 2\n");
	SetSize([-8,-8,-8], [8,8,8]);
	Relink();
}

float
hlTripmine::predraw(void)
{
	if (m_iActive) {
		trailparticles(BEAM_TRIPMINE, this, GetOrigin(), m_vecEndPos);
	}

	addentity(this);
	return (PREDRAW_NEXT);
}
#endif
