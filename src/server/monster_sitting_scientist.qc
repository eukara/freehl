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

class monster_sitting_scientist:CBaseMonster
{
	int m_iPose;
	void(void) monster_sitting_scientist;

	virtual void(void) Hide;
	virtual void(void) Respawn;
	virtual void(void) Death;
	virtual void(void) Gib;
	virtual void(string, string) SpawnKey;
};

void
monster_sitting_scientist::Gib(void)
{
	takedamage = DAMAGE_NO;
	FX_GibHuman(this.origin);
	Hide();
}

void
monster_sitting_scientist::Death(void)
{
	if (health < -50) {
		Gib();
		return;
	}
}

void
monster_sitting_scientist::Hide(void)
{
	SetModel("");
	solid = SOLID_NOT;
	movetype = MOVETYPE_NONE;
}

void
monster_sitting_scientist::Respawn(void)
{
	v_angle[0] = Math_FixDelta(m_oldAngle[0]);
	v_angle[1] = Math_FixDelta(m_oldAngle[1]);
	v_angle[2] = Math_FixDelta(m_oldAngle[2]);

	SetOrigin(m_oldOrigin);
	angles = v_angle;
	solid = SOLID_BBOX;
	movetype = MOVETYPE_NONE;
	SetModel(m_oldModel);
	setsize(this, [-14,-14,0],[14,14,36]);
	takedamage = DAMAGE_YES;
	health = 0;
	velocity = [0,0,0];
	iBleeds = TRUE;
	SendFlags |= NPC_BODY;
	frame = 74;
	droptofloor();
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
		CBaseMonster::SpawnKey(strKey, strValue);
	}
}

void
monster_sitting_scientist::monster_sitting_scientist(void)
{
	model = "models/scientist.mdl";
	CBaseMonster::CBaseMonster();

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
