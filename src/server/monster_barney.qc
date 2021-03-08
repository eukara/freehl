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

/*QUAKED monster_barney (0 0.8 0.8) (-16 -16 0) (16 16 72)

HALF-LIFE (1998) ENTITY

Barney Calhoun

*/

enum
{
	BA_IDLE1,
	BA_IDLE2,
	BA_IDLE3,
	BA_IDLE4,
	BA_WALK,
	BA_RUN,
	BA_SHOOT1,
	BA_SHOOT2,
	BA_DRAW,
	BA_HOLSTER,
	BA_RELOAD,
	BA_TURNLEFT,
	BA_TURNRIGHT,
	BA_FLINCH_LA,
	BA_FLINCH_RA,
	BA_FLINCH_LL,
	BA_FLINCH_RL,
	BA_FLINCH_SML
};

class monster_barney:CBaseNPC
{
	void(void) monster_barney;

	virtual void(void) Respawn;
	virtual void(void) OnPlayerUse;
	virtual void(void) Pain;
	virtual void(void) Death;
	virtual int(void) AnimIdle;
	virtual int(void) AnimWalk;
	virtual int(void) AnimRun;

	virtual void(void) AttackDraw;
	virtual void(void) AttackHolster;
	virtual int(void) AttackMelee;
	virtual int(void) AttackRanged;
};

int
monster_barney::AnimIdle(void)
{
	return BA_IDLE1;
}

int
monster_barney::AnimWalk(void)
{
	return BA_WALK;
}

int
monster_barney::AnimRun(void)
{
	return BA_RUN;
}

void
monster_barney::AttackDraw(void)
{
	AnimPlay(BA_DRAW);
	m_flAttackThink = m_flAnimTime;
}

void
monster_barney::AttackHolster(void)
{
	AnimPlay(BA_HOLSTER);
	m_flAttackThink = m_flAnimTime;
}

int
monster_barney::AttackMelee(void)
{
	return AttackRanged();
}

int
monster_barney::AttackRanged(void)
{
	/* visual */
	AnimPlay(BA_SHOOT1);
	m_flAttackThink = time + 0.4f;

	/* functional */
	v_angle = vectoangles(m_eEnemy.origin - origin);
	TraceAttack_FireBullets(1, origin + [0,0,16], 8, [0.01,0.01], 2);
	Sound_Play(this, CHAN_WEAPON, "weapon_glock.fire");
	return TRUE;
}

void
monster_barney::OnPlayerUse(void)
{
	if (spawnflags & MSF_PREDISASTER) {
		Sentence("!BA_POK");
		return;
	}

	CBaseNPC::OnPlayerUse();
}

void
monster_barney::Pain(void)
{
	CBaseNPC::Pain();

	WarnAllies();

	if (m_flAnimTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	Sound_Speak(this, "monster_barney.pain");

	AnimPlay(BA_FLINCH_LA + floor(random(0, 5)));
	m_flAttackThink = m_flAnimTime;
	m_iFlags |= MONSTER_FEAR;
}

void 
monster_barney::Death(void)
{
	WarnAllies();

	if (style != MONSTER_DEAD) {
		SetFrame(25 + floor(random(0, 6)));
		Sound_Speak(this, "monster_barney.die");
	}

	/* now mark our state as 'dead' */
	CBaseNPC::Death();
}

void
monster_barney::Respawn(void)
{
	CBaseNPC::Respawn();
	m_iFlags |= MONSTER_CANFOLLOW;
	PlayerUse = OnPlayerUse;
}

void
monster_barney::monster_barney(void)
{
	Sound_Precache("monster_barney.die");
	Sound_Precache("monster_barney.pain");

	/* TODO
	 * BA_MAD - When player gets too naughty
	 * */
	m_talkAnswer = "!BA_ANSWER";
	m_talkAsk = "!BA_QUESTION";
	m_talkAllyShot = "!BA_SHOOT";
	m_talkGreet = "";
	m_talkIdle = "!BA_IDLE";
	m_talkHearing = "!BA_HEAR";
	m_talkSmelling = "!BA_SMELL";
	m_talkStare = "!BA_STARE";
	m_talkSurvived = "!BA_WOUND";
	m_talkWounded = "!BA_WOUND";

	m_talkPlayerAsk = "!BA_QUESTION";
	m_talkPlayerGreet = "!BA_HELLO";
	m_talkPlayerIdle = "!BA_IDLE";
	m_talkPlayerWounded1 = "!BA_CUREA";
	m_talkPlayerWounded2 = "!BA_CUREB";
	m_talkPlayerWounded3 = "!BA_CUREC";
	m_talkUnfollow = "!BA_WAIT";
	m_talkFollow = "!BA_OK";
	m_talkStopFollow = "!BA_STOP";

	model = "models/barney.mdl";
	netname = "Barney";
	base_health = Skill_GetValue("barney_health", 35);
	base_mins = [-16,-16,0];
	base_maxs = [16,16,72];
	m_iAlliance = MAL_FRIEND;
	CBaseNPC::CBaseNPC();
}
