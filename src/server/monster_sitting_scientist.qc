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

/*QUAKED monster_sitting_scientist (0 0.8 0.8) (-14 -14 0) (14 14 36)

HALF-LIFE (1998) ENTITY

Sitting scientists

*/

enum
{
	DSCIA_LYING1 = 37,
	DSCIA_LYING2,
	DSCIA_DEADSIT,
	DSCIA_DEADTABLE1,
	DSCIA_DEADTABLE2,
	DSCIA_DEADTABLE3,
	DSCIA_DEADHANG
};

class monster_sitting_scientist:NSTalkMonster
{
	int m_iPose;
	void(void) monster_sitting_scientist;

	virtual void(void) Respawn;
	virtual void(void) Spawned;
	virtual void(void) Death;
	virtual void(void) Gib;
	virtual void(string, string) SpawnKey;
};

void
monster_sitting_scientist::Gib(void)
{
	SetTakedamage(DAMAGE_NO);
	FX_GibHuman(GetOrigin(), vectoangles(GetOrigin() - g_dmg_eAttacker.origin), g_dmg_iDamage * 2.0f);
	Disappear();
}

void
monster_sitting_scientist::Death(void)
{
	if (GetHealth() < -50) {
		Gib();
		return;
	}
}

void
monster_sitting_scientist::Respawn(void)
{
	v_angle = GetSpawnAngles();
	v_angle[0] = Math_FixDelta(v_angle[0]);
	v_angle[1] = Math_FixDelta(v_angle[1]);
	v_angle[2] = Math_FixDelta(v_angle[2]);

	SetOrigin(GetSpawnOrigin());
	SetAngles(v_angle);
	SetSolid(SOLID_BBOX);
	SetMovetype(MOVETYPE_NONE);
	SetModel(GetSpawnModel());
	SetSize([-14,-14,0],[14,14,36]);
	SetTakedamage(DAMAGE_YES);
	SetHealth(0);
	SetVelocity([0,0,0]);
	SetFrame(74);
	DropToFloor();
	iBleeds = TRUE;
}

void
monster_sitting_scientist::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "pose":
		m_iPose = stoi(strValue);
		break;
	case "body":
		SetBody(stoi(strValue) + 1);
		break;
	case "skin":
		SetSkin(stoi(strValue));
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
monster_sitting_scientist::Spawned(void)
{
	model = "models/scientist.mdl";

	super::Spawned();

	/* has the body not been overriden, etc. choose a character for us */
	if (m_iBody == -1) {
		SetBody((int)floor(random(1,5)));
	}

	switch (m_iBody) {
	case 1:
		m_flPitch = 105;
		netname = "Walter";
		break;
	case 2:
		m_flPitch = 100;
		netname = "Einstein";
		break;
	case 3:
		m_flPitch = 95;
		netname = "Luther";
		SetSkin(1);
		break;
	default:
		m_flPitch = 100;
		netname = "Slick";
	}
}

void
monster_sitting_scientist::monster_sitting_scientist(void)
{
}
