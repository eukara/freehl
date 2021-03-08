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

/*QUAKED monster_human_grunt (0 0.8 0.8) (-16 -16 0) (16 16 72)

HALF-LIFE (1998) ENTITY

HECU - Human Grunt

*/

enum
{
	GR_WALK,
	GR_RUN,
	GR_VICTORYDANCE,
	GR_COWER,
	GR_FLINCH,
	GR_LEFTLEGFLINCH,
	GR_RIGHTLEGFLINCH,
	GR_RIGHTARMFLINCH,
	GR_LEFTARMFLINCH,
	GR_LAUNCHNADE,
	GR_THROWNADE,
	GR_IDLE,
	GR_IDLE2,
	GR_COMBATIDLE,
	GR_FRONTKICK,
	GR_CROUCHIDLE,
	GR_CROUCHWAIT,
	GR_CROUCHSHOOTMP5,
	GR_STANDSHOOTMP5,
	GR_RELOADMP5,
	GR_CROUCHSHOOTSG,
	GR_STANDSHOOTSG,
	GR_RELOADSG,
	GR_SIGNALADV,
	GR_SIGNALFLANK,
	GR_SIGNALRETREAT,
	GR_DROPNADE,
	GR_LIMPWALK,
	GR_LIMPRUN,
	GR_TURNLEFT,
	GR_TURNRIGHT,
	GR_STRAFELEFT,
	GR_STRAFERIGHT,
	GR_DIEBACK,
	GR_DIEFORWARD,
	GR_DIE,
	GR_DIEBACK2,
	GR_DIEHS,
	GR_DIEGUT,
	GR_BARNACLE1,
	GR_BARNACLE2,
	GR_BARNACLE3,
	GR_BARNACLE4,
	GR_DEADSTOMACH,
	GR_DEADSTOMACH2,
	GR_DEADSIDE,
	GR_DEADSITTING,
	GR_REPELJUMP,
	GR_REPEL,
	GR_REPELSHOOT,
	GR_REPELLAND,
	GR_REPELDIE,
	GR_DRAGHOLEIDLE,
	GR_DRAGHOLE,
	GR_BUSTWALL,
	GR_HOPRAIL,
	GR_CONVERSE1,
	GR_CONVERSE2,
	GR_STARTLELEFT,
	GR_STRRTLERIGHT,
	GR_DIVE,
	GR_DEFUSE,
	GR_CORNER1,
	GR_CORNER2,
	GR_STONETOSS,
	GR_CLIFFDIE,
	GR_DIVESIDEIDLE,
	GR_DIVESIDE,
	GR_DIVEKNEELIDLE,
	GR_DIVEKNEEL,
	GR_WMBUTTON,
	GR_WM,
	GR_WMJUMP,
	GR_BUSTWINDOW,
	GR_DRAGLEFT,
	GR_DRAGRIGHT,
	GR_TRACKWAVE,
	GR_TRACKDIVE,
	GR_FLYBACK,
	GR_IMPALED,
	GR_JUMPTRACKS,
	GR_THROWPIPE,
	GR_PLUNGER
};

class monster_human_grunt:CBaseNPC
{
	float m_flIdleTime;
	int m_iMP5Burst;
	
	void(void) monster_human_grunt;
	
	virtual void(void) Scream;
	virtual void(void) IdleChat;
	virtual void(void) Respawn;
	virtual void(void) Pain;
	virtual void(void) Death;

	virtual int(void) AnimIdle;
	virtual int(void) AnimWalk;
	virtual int(void) AnimRun;

	virtual int(void) AttackRanged;
	virtual int(void) AttackMelee;
	virtual void(void) AttackKick;

};

int
monster_human_grunt::AnimIdle(void)
{
	return GR_IDLE;
}

int
monster_human_grunt::AnimWalk(void)
{
	return GR_WALK;
}

int
monster_human_grunt::AnimRun(void)
{
	return GR_RUN;
}

int
monster_human_grunt::AttackMelee(void)
{
	/* visual */
	AnimPlay(GR_FRONTKICK);

	m_flAttackThink = m_flAnimTime;
	Sound_Play(this, CHAN_VOICE, "monster_zombie.attack");

	/* functional */
	think = AttackKick;
	nextthink = 0.25f;
	return TRUE;
}

void
monster_human_grunt::AttackKick(void)
{
	traceline(origin, m_eEnemy.origin, FALSE, this);

	if (trace_fraction >= 1.0 || trace_ent.takedamage != DAMAGE_YES) {
		//Sound_Play(this, CHAN_WEAPON, "monster_zombie.attackmiss");
		return;
	}

	Damage_Apply(trace_ent, this, 25, 0, 0);
	//Sound_Play(this, CHAN_WEAPON, "monster_zombie.attackhit");
}

int
monster_human_grunt::AttackRanged(void)
{
	/* visual */
	AnimPlay(GR_STANDSHOOTMP5);
	Sound_Play(this, CHAN_WEAPON, "weapon_mp5.shoot");

	if (m_iMP5Burst >= 2) {
		m_iMP5Burst = 0;
		m_flAttackThink = time + 0.4f;
	} else {
		m_iMP5Burst++;
		m_flAttackThink = time + 0.1f;
	}

	/* functional */
	v_angle = vectoangles(m_eEnemy.origin - origin);
	TraceAttack_FireBullets(1, origin + [0,0,16], 8, [0.01,0.01], 2);
	return TRUE;
}

void monster_human_grunt::Scream(void)
{
	if (m_flIdleTime > time) {
		return;
	}

	Sentence(m_talkAllyShot);
	m_flIdleTime = time + 5.0f;
}

void monster_human_grunt::IdleChat(void)
{
	if (m_flIdleTime > time) {
		return;
	}

	Sentence(m_talkIdle);
	
	/* Sentence(m_talkPlayerIdle); */
	/* come up with logic to make them repsone to questions
	 * Sentence(m_talkAsk);
	 * Sentence(m_talkAnswer);
	 */
	m_flIdleTime = time + 5.0f + random(0,20);
}

void
monster_human_grunt::Pain(void)
{
	CBaseMonster::Pain();

	if (m_flAnimTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	Sound_Play(this, CHAN_VOICE, "monster_human_grunt.pain");
	SetFrame(GR_FLINCH);
	m_flAnimTime = time + 0.25f;
}

void
monster_human_grunt::Death(void)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		/* headshots == different animation */
		/* this animation may not have been used, but it looks cool */
		if (g_dmg_iHitBody == BODY_HEAD) {
			if (random() < 0.5) {
				SetFrame(GR_DIEHS);
			} else {
				SetFrame(GR_DIEBACK);
			}
		} else {
			SetFrame(GR_DIE);
		}
	}

	Sound_Play(this, CHAN_VOICE, "monster_human_grunt.die");

	/* set the functional differences */
	CBaseMonster::Death();
}

void
monster_human_grunt::Respawn(void)
{
	CBaseMonster::Respawn();
	SetFrame(GR_IDLE);
}


void monster_human_grunt::monster_human_grunt(void)
{
	Sound_Precache("monster_human_grunt.die");
	Sound_Precache("monster_human_grunt.pain");

	/* Adding some into other slots in hopes it feels right
	 * listed below are other setences that might need their own:
	 * !HG_MONST - Monster HG_ALERT
	 * !HG_GREN - Grenade toss
	 * !HG_CHECK - Sector check question
	 * !HG_CLEAR - Sector clear response */
	
	m_talkAnswer = "!HG_ANSWER";
	m_talkAsk = "!HG_QUEST";
	m_talkAllyShot = "!HG_COVER";
	m_talkGreet = "";
	m_talkIdle = "!HG_IDLE";
	m_talkSmelling = "";
	m_talkStare = "";
	m_talkSurvived = "!HG_CLEAR";
	m_talkWounded = "!HG_CHECK";

	m_talkPlayerAsk = "";
	m_talkPlayerGreet = "!HG_ALERT";
	m_talkPlayerIdle = "!HG_CHARGE";
	m_talkPlayerWounded1 = "";
	m_talkPlayerWounded2 = "";
	m_talkPlayerWounded3 = "";
	m_talkUnfollow = "";
	m_talkFollow = "";
	m_talkStopFollow = "";

	
	netname = "Grunt";
	model = "models/hgrunt.mdl";
	base_health = Skill_GetValue("hgrunt_health", 50);
	base_mins = [-16,-16,0];
	base_maxs = [16,16,72];
	m_iAlliance = MAL_ENEMY;
	CBaseMonster::CBaseMonster();
}
