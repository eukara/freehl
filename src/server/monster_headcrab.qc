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

/*QUAKED monster_headcrab (0 0.8 0.8) (-16 -16 0) (16 16 36)

HALF-LIFE (1998) ENTITY

Headcrab

*/

enum
{
	HC_IDLE1,
	HC_IDLE2,
	HC_IDLE3,
	HC_WALK,
	HC_RUN,
	HC_ANGRY,
	HC_FLINCH,
	HC_DIE,
	HC_180_LEFT,
	HC_180_RIGHT,
	HC_JUMP,
	HC_JUMP_VARIATION1,
	HC_JUMP_VARIATION2,
	HC_YAW_ADJUSTMENT,
	HC_HEADCRABBED1,
	HC_HEADCRABBED2,
	HC_HEADIDLE,
	HC_CRASHIDLE,
	HC_CRASH,
	HC_STRUGGLEIDLE,
	HC_STRUGGLE
};

class monster_headcrab:CBaseMonster
{
	float m_flIdleTime;

	void(void) monster_headcrab;

	virtual void(void) Pain;
	virtual void(void) Death;
	virtual void(void) IdleNoise;
	virtual int(void) AnimIdle;
	virtual int(void) AnimWalk;
	virtual int(void) AnimRun;
	virtual int(void) AttackRanged;
	virtual void(void) touch;
};

int
monster_headcrab::AnimIdle(void)
{
	return HC_IDLE1;
}

int
monster_headcrab::AnimWalk(void)
{
	return HC_WALK;
}

int
monster_headcrab::AnimRun(void)
{
	return HC_RUN;
}

int
monster_headcrab::AttackRanged(void)
{
	/* visual */
	if (random() < 0.5)
		AnimPlay(HC_JUMP);
	else
		AnimPlay(HC_JUMP_VARIATION1);

	m_flAttackThink = m_flAnimTime;
	Sound_Play(this, CHAN_VOICE, "monster_headcrab.attack");

	/* functional */
	makevectors(vectoangles(m_eEnemy.origin - origin));
	velocity = v_forward * 512 + [0,0,250];
	return TRUE;
}

void
monster_headcrab::touch(void)
{
	if (other.takedamage == DAMAGE_YES)
	if (frame == HC_JUMP || frame == HC_JUMP_VARIATION1)
		Damage_Apply(other, this, 500, 0, 0);
}

void
monster_headcrab::Pain(void)
{
	CBaseMonster::Pain();

	if (m_flAnimTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	Sound_Play(this, CHAN_VOICE, "monster_headcrab.pain");
	SetFrame(HC_FLINCH);
	m_flAnimTime = time + 0.25f;
}

void
monster_headcrab::Death(void)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		SetFrame(HC_DIE);
		Sound_Play(this, CHAN_VOICE, "monster_headcrab.die");
	}

	/* set the functional differences */
	CBaseMonster::Death();
}

void
monster_headcrab::IdleNoise(void)
{
	/* don't make noise if we're dead (corpse) */
	if (style == MONSTER_DEAD) {
		return;
	}

	if (m_flIdleTime > time) {
		return;
	}
	m_flIdleTime = time + random(2,10);

	Sound_Play(this, CHAN_VOICE, "monster_headcrab.idle");
}

void
monster_headcrab::monster_headcrab(void)
{
	Sound_Precache("monster_headcrab.alert");
	Sound_Precache("monster_headcrab.attack");
	Sound_Precache("monster_headcrab.attackhit");
	Sound_Precache("monster_headcrab.die");
	Sound_Precache("monster_headcrab.idle");
	Sound_Precache("monster_headcrab.pain");

	if (classname == "monster_babycrab") {
		netname = "Baby Headcrab";
		model = "models/baby_headcrab.mdl";
		base_health = Skill_GetValue ("headcrab_health", 10) /4;
	} else {
		netname = "Headcrab";
		model = "models/headcrab.mdl";
		base_health = Skill_GetValue("headcrab_health", 10);
	}

	base_mins = [-16,-16,0];
	base_maxs = [16,16,36];
	m_iAlliance = MAL_ALIEN;
	CBaseMonster::CBaseMonster();
}
