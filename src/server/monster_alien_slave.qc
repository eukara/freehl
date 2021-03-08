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

/*QUAKED monster_alien_slave (0 0.8 0.8) (-16 -16 0) (16 16 72)

HALF-LIFE (1998) ENTITY

Alien Slave

*/

enum
{
	SLV_IDLE,
	SLV_IDLE2,
	SLV_IDLE3,
	SLV_CROUCH,
	SLV_WALK,
	SLV_WALK2,
	SLV_RUN,
	SLV_RIGHT,
	SLV_LEFT,
	SLV_JUMP,
	SLV_STAIRUP,
	SLV_ATTACK,
	SLV_ATTACKZAP,
	SLV_FLINCH,
	SLV_FLINCHLA,
	SLV_FLINCHRA,
	SLV_FLINCHL,
	SLV_FLINCHR,
	SLV_DIEHS,
	SLV_DIE,
	SLV_DIEBACK,
	SLV_DIEFORWARD,
	SLV_COLLAR,
	SLV_COLLAR2,
	SLV_PUSHUP,
	SLV_GRAB,
	SLV_UPDOWN,
	SLV_DOWNUP,
	SLV_JIBBER,
	SLV_JABBER
};

class monster_alien_slave:CBaseNPC
{
	float m_flIdleTime;
	float m_flPainTime;

	void(void) monster_alien_slave;
	
	virtual void(void) Death;
	virtual void(void) Pain;
	virtual void(void) IdleChat;
	virtual void(void) Respawn;

	virtual int(void) AnimIdle;
	virtual int(void) AnimWalk;
	virtual int(void) AnimRun;

	virtual int(void) AttackMelee;
	virtual void(void) AttackFlail;

	virtual int(void) AttackRanged;
	virtual void(void) AttackBeam;
};

int
monster_alien_slave::AnimIdle(void)
{
	return SLV_IDLE;
}

int
monster_alien_slave::AnimWalk(void)
{
	return SLV_WALK;
}

int
monster_alien_slave::AnimRun(void)
{
	return SLV_RUN;
}

int
monster_alien_slave::AttackMelee(void)
{
	/* visual */
	AnimPlay(SLV_ATTACK);

	m_flAttackThink = m_flAnimTime;

	/* functional */
	think = AttackFlail;
	nextthink = 0.25f;
	return TRUE;
}

void
monster_alien_slave::AttackFlail(void)
{
	traceline(origin, m_eEnemy.origin, FALSE, this);

	if (trace_fraction >= 1.0 || trace_ent.takedamage != DAMAGE_YES) {
		Sound_Play(this, CHAN_WEAPON, "monster_zombie.attackmiss");
		return;
	}

	Damage_Apply(trace_ent, this, 25, 0, 0);
	Sound_Play(this, CHAN_WEAPON, "monster_zombie.attackhit");
}

int
monster_alien_slave::AttackRanged(void)
{
	/* visual */
	AnimPlay(SLV_ATTACKZAP);

	m_flAttackThink = m_flAnimTime;
	Sound_Play(this, CHAN_VOICE, "monster_alien_slave.attack_charge");

	/* functional */
	think = AttackBeam;
	nextthink = time + 1.5f;
	return TRUE;
}

void
monster_alien_slave::AttackBeam(void)
{
	traceline(origin, m_eEnemy.origin, FALSE, this);
	Sound_Play(this, CHAN_WEAPON, "monster_alien_slave.attack_shoot");

	if (trace_fraction >= 1.0 || trace_ent.takedamage != DAMAGE_YES) {
		//Sound_Play(this, CHAN_WEAPON, "monster_zombie.attackmiss");
		return;
	}

	Damage_Apply(trace_ent, this, 100, 0, 0);
}

void 
monster_alien_slave::IdleChat(void)
{
	if (m_flIdleTime > time) {
		return;
	}

	Sentence(m_talkIdle);

	m_flIdleTime = time + 5.0f + random(0,20);
}

void
monster_alien_slave::Pain(void)
{
	CBaseNPC::Pain();

	if (m_flPainTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	Sound_Play(this, CHAN_VOICE, "monster_alien_slave.pain");
	SetFrame(SLV_FLINCH + floor(random(0, 2)));
	m_flPainTime = time + 0.25f;
}

void
monster_alien_slave::Death(void)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		/* headshots == different animation */
		if (g_dmg_iHitBody == BODY_HEAD) {
			if (random() < 0.5) {
				SetFrame(SLV_DIEHS);
			} else {
				SetFrame(SLV_DIEBACK);
			}
		} else {
			SetFrame(SLV_DIE + floor(random(0, 3)));
		}

		Sound_Play(this, CHAN_VOICE, "monster_alien_slave.die");
	}

	/* set the functional differences */
	CBaseNPC::Death();
}

void
monster_alien_slave::Respawn(void)
{
	CBaseNPC::Respawn();
	SetFrame(SLV_IDLE);
}

void
monster_alien_slave::monster_alien_slave(void)
{
	Sound_Precache("monster_alien_slave.die");
	Sound_Precache("monster_alien_slave.pain");
	Sound_Precache("monster_alien_slave.attack_charge");
	Sound_Precache("monster_alien_slave.attack_shoot");
	Sound_Precache("monster_zombie.attackhit");
	Sound_Precache("monster_zombie.attackmiss");

	m_talkAnswer = "";
	m_talkAsk = "";
	m_talkAllyShot = "";
	m_talkGreet = "SLV_ALERT";
	m_talkIdle = "!SLV_IDLE";
	m_talkSmelling = "";
	m_talkStare = "";
	m_talkSurvived = "";
	m_talkWounded = "";

	m_talkPlayerAsk = "";
	m_talkPlayerGreet = "!SLV_ALERT";
	m_talkPlayerIdle = "";
	m_talkPlayerWounded1 = "";
	m_talkPlayerWounded2 = "";
	m_talkPlayerWounded3 = "";
	m_talkUnfollow = "";
	m_talkFollow = "";
	m_talkStopFollow = "";

	netname = "Alien Slave";
	model = "models/islave.mdl";
	base_health = Skill_GetValue("islave_health", 30);
	base_mins = [-16,-16,0];
	base_maxs = [16,16,72];
	m_iAlliance = MAL_ALIEN;
	CBaseNPC::CBaseNPC();
}
