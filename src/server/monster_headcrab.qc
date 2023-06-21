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

class monster_headcrab:HLXenMonster
{
	bool m_bBiting;
	float m_flIdleTime;

	void monster_headcrab(void);

	virtual void Spawned(void);
	virtual void HasBeenHit(void);
	virtual void HasBeenKilled(void);
	virtual void IdleNoise(void);
	virtual int AttackMelee(void);
	virtual void Touch(entity);
	virtual float MeleeMaxDistance(void);
};

float
monster_headcrab:: MeleeMaxDistance(void)
{
	return 256;
}

int
monster_headcrab::AttackMelee(void)
{
	/* visual */
	if (random() < 0.5)
		AnimPlay(HC_JUMP);
	else
		AnimPlay(HC_JUMP_VARIATION1);

	m_flAttackThink = m_flAnimTime + 0.25;
	Sound_Play(this, CHAN_VOICE, "monster_headcrab.attack");

	/* functional */
	vector jumpVelocity;
	makevectors(vectoangles(m_eEnemy.origin - origin));
	jumpVelocity = (v_forward * 512) + [0, 0, 250];
	SetVelocity(jumpVelocity);
	m_bBiting = true;
	return (1);
}

void
monster_headcrab::Touch(entity eToucher)
{
	if (m_bBiting)
	if (eToucher.takedamage == DAMAGE_YES)
	if (frame == HC_JUMP || frame == HC_JUMP_VARIATION1) {
		Damage_Apply(eToucher, this, Skill_GetValue("headcrab_dmg_bite", 10), 0, 0);
		StartSoundDef("monster_headcrab.attackhit", CHAN_VOICE, true);
		m_bBiting = false;
	}
}

void
monster_headcrab::HasBeenHit(void)
{
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
monster_headcrab::HasBeenKilled(void)
{
	SetFrame(HC_DIE);
	Sound_Play(this, CHAN_VOICE, "monster_headcrab.die");
}

void
monster_headcrab::IdleNoise(void)
{
	/* don't make noise if we're dead (corpse) */
	if (IsAlive() == false) {
		return;
	}

	if (m_flIdleTime > time) {
		return;
	}
	m_flIdleTime = time + random(2,10);

	StartSoundDef("monster_headcrab.idle", CHAN_VOICE, true);
}

void
monster_headcrab::Spawned(void)
{
	super::Spawned();

	Sound_Precache("monster_headcrab.alert");
	Sound_Precache("monster_headcrab.attack");
	Sound_Precache("monster_headcrab.attackhit");
	Sound_Precache("monster_headcrab.die");
	Sound_Precache("monster_headcrab.idle");
	Sound_Precache("monster_headcrab.pain");
}

void
monster_headcrab::monster_headcrab(void)
{
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
}
