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

/*QUAKED monster_scientist (0 0.8 0.8) (-16 -16 0) (16 16 72)

HALF-LIFE (1998) ENTITY

Scientist

*/

enum
{
	SCIA_WALK,
	SCIA_WALKSCARED,
	SCIA_RUN,
	SCIA_RUNSCARED,
	SCIA_RUNLOOK,
	SCIA_180LEFT,
	SCIA_180RIGHT,
	SCIA_FLINCH,
	SCIA_PAIN,
	SCIA_PAINLEFT,
	SCIA_PAINRIGHT,
	SCIA_PAINLEGLEFT,
	SCIA_PAINLEGRIGHT,
	SCIA_IDLE1,
	SCIA_IDLE2,
	SCIA_IDLE3,
	SCIA_IDLE4,
	SCIA_IDLE5,
	SCIA_IDLE6,
	SCIA_SCARED_END,
	SCIA_SCARED1,
	SCIA_SCARED2,
	SCIA_SCARED3,
	SCIA_SCARED4,
	SCIA_PANIC,
	SCIA_FEAR1,
	SCIA_FEAR2,
	SCIA_CRY,
	SCIA_SCI1,
	SCIA_SCI2,
	SCIA_SCI3,
	SCIA_DIE_SIMPLE,
	SCIA_DIE_FORWARD1,
	SCIA_DIE_FORWARD2,
	SCIA_DIE_BACKWARD,
	SCIA_DIE_HEADSHOT,
	SCIA_DIE_GUTSHOT,
	SCIA_LYING1,
	SCIA_LYING2,
	SCIA_DEADSIT,
	SCIA_DEADTABLE1,
	SCIA_DEADTABLE2,
	SCIA_DEADTABLE3
};

class monster_scientist:CBaseNPC
{
	void(void) monster_scientist;

	virtual void(void) Respawn;
	virtual void(void) OnPlayerUse;
	virtual void(void) Pain;
	virtual void(void) Death;
	virtual int(void) AnimIdle;
	virtual int(void) AnimWalk;
	virtual int(void) AnimRun;
	virtual void(string, string) SpawnKey;
};

int
monster_scientist::AnimIdle(void)
{
	return SCIA_IDLE1;
}

int
monster_scientist::AnimWalk(void)
{
	return SCIA_WALK;
}

int
monster_scientist::AnimRun(void)
{
	return SCIA_RUN;
}

void
monster_scientist::OnPlayerUse(void)
{
	if (spawnflags & MSF_PREDISASTER) {
		Sentence("!SC_POK");
		return;
	}

	CBaseNPC::OnPlayerUse();
}

void
monster_scientist::Pain(void)
{
	WarnAllies();

	if (m_flAnimTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	Sound_Speak(this, "monster_scientist.pain");

	frame = SCIA_FLINCH + floor(random(0, 6));
	m_iFlags |= MONSTER_FEAR;
	m_flAnimTime = time + 0.25f;
}

void
monster_scientist::Death(void)
{
	WarnAllies();

	if (style != MONSTER_DEAD) {
		SetFrame(SCIA_DIE_SIMPLE + floor(random(0, 6)));
		Sound_Speak(this, "monster_scientist.die");
	}

	/* now mark our state as 'dead' */
	CBaseNPC::Death();
}

void
monster_scientist::Respawn(void)
{
	CBaseNPC::Respawn();
	m_iFlags |= MONSTER_CANFOLLOW;
	PlayerUse = OnPlayerUse;
}

void
monster_scientist::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "body":
		SetBody(stoi(strValue) + 1);
		break;
	default:
		CBaseEntity::SpawnKey(strKey, strValue);
	}
}

void
monster_scientist::monster_scientist(void)
{
	Sound_Precache("monster_scientist.die");
	Sound_Precache("monster_scientist.pain");

	if (spawnflags & MSF_PREDISASTER) {
		m_talkAsk = "";
		m_talkPlayerAsk = "!SC_PQUEST";
		m_talkPlayerGreet = "!SC_PHELLO";
		m_talkPlayerIdle = "!SC_PIDLE";
	} else {
		m_talkAsk = "!SC_QUESTION";
		m_talkPlayerAsk = "!SC_QUESTION";
		m_talkPlayerGreet = "!SC_HELLO";
		m_talkPlayerIdle = "!SC_PIDLE";
	}

	m_talkAnswer = "!SC_ANSWER";
	m_talkAllyShot = "!SC_PLFEAR";
	m_talkGreet = "";
	m_talkIdle = "!SC_IDLE";
	m_talkHearing = "!SC_HEAR";
	m_talkSmelling = "!SC_SMELL";
	m_talkStare = "!SC_STARE";
	m_talkSurvived = "!SC_WOUND";
	m_talkWounded = "!SC_MORTAL";

	/* they seem to use predisaster lines regardless of disaster state */
	m_talkPlayerWounded1 = "!SC_CUREA";
	m_talkPlayerWounded2 = "!SC_CUREB";
	m_talkPlayerWounded3 = "!SC_CUREC";
	m_talkUnfollow = "!SC_WAIT";
	m_talkFollow = "!SC_OK";
	m_talkStopFollow = "!SC_STOP";
	m_iBody = -1;

	model = "models/scientist.mdl";
	base_mins = [-16,-16,0];
	base_maxs = [16,16,72];
	base_health = Skill_GetValue("scientist_health", 20);

	CBaseNPC::CBaseNPC();

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
