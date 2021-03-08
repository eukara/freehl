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

/*QUAKED monster_zombie (0 0.8 0.8) (-16 -16 0) (16 16 72)

HALF-LIFE (1998) ENTITY

Zombie

*/

enum
{
	ZO_IDLE,
	ZO_TURNLEFT,
	ZO_TURNRIGHT,
	ZO_FLINCHSM,
	ZO_FLINCH,
	ZO_FLINCHBIG,
	ZO_RISE,
	ZO_FALLING,
	ZO_ATTACK1,
	ZO_ATTACK2,
	ZO_WALK,
	ZO_FLINCHLA,
	ZO_FLINCHRA,
	ZO_FLINCHLEFT,
	ZO_FLINCHRIGHT,
	ZO_DIEHS,
	ZO_DIEHS2,
	ZO_DIE,
	ZO_DIE2,
	ZO_DIE3,
	ZO_PAUSE,
	ZO_WALLBUST,
	ZO_WALLKICK,
	ZO_WINDOWBUST,
	ZO_SODA,
	ZO_SLIDEIDLE,
	ZO_SLIDE,
	ZO_VENTIDLE,
	ZO_VENT,
	ZO_DEADIDLE,
	ZO_DEAD,
	ZO_FREAKDIE,
	ZO_FREAK,
	ZO_EATTABLE,
	ZO_EAT,
	ZO_EATSTAND,
	ZO_DOORIP,
	ZO_PULLSCI,
	ZO_EAT2,
	ZO_EAT2STAND,
	ZO_VENT2IDLE,
	ZO_VENT2,
	ZO_HAUL,
	ZO_RISESNACK
};

class monster_zombie:CBaseMonster
{
	float m_flIdleTime;

	void(void) monster_zombie;

	virtual void(void) Pain;
	virtual void(void) Death;
	virtual void(void) IdleNoise;
	virtual void(void) Respawn;

	virtual int(void) AnimIdle;
	virtual int(void) AnimWalk;
	virtual int(void) AnimRun;

	virtual int(void) AttackMelee;
	virtual void(void) AttackFlail;
};

int
monster_zombie::AnimIdle(void)
{
	return ZO_IDLE;
}

int
monster_zombie::AnimWalk(void)
{
	return ZO_WALK;
}

int
monster_zombie::AnimRun(void)
{
	return ZO_WALK;
}

int
monster_zombie::AttackMelee(void)
{
	/* visual */
	if (random() < 0.5)
		AnimPlay(ZO_ATTACK1);
	else
		AnimPlay(ZO_ATTACK2);

	m_flAttackThink = m_flAnimTime;
	Sound_Play(this, CHAN_VOICE, "monster_zombie.attack");

	/* functional */
	think = AttackFlail;
	nextthink = 0.25f;
	return TRUE;
}

void
monster_zombie::AttackFlail(void)
{
	traceline(origin, m_eEnemy.origin, FALSE, this);

	if (trace_fraction >= 1.0 || trace_ent.takedamage != DAMAGE_YES) {
		Sound_Play(this, CHAN_WEAPON, "monster_zombie.attackmiss");
		return;
	}

	Damage_Apply(trace_ent, this, 25, 0, 0);
	Sound_Play(this, CHAN_WEAPON, "monster_zombie.attackhit");
}

void
monster_zombie::Pain(void)
{
	CBaseMonster::Pain();

	if (m_flAnimTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	Sound_Play(this, CHAN_VOICE, "monster_zombie.pain");
	SetFrame(ZO_FLINCH + floor(random(0, 2)));
	m_flAnimTime = time + 0.25f;
}

void
monster_zombie::Death(void)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		/* headshots == different animation */
		if (g_dmg_iHitBody == BODY_HEAD) {
			if (random() < 0.5) {
				SetFrame(ZO_DIEHS);
			} else {
				SetFrame(ZO_DIEHS2);
			}
		} else {
			 SetFrame(ZO_DIE + floor(random(0, 3)));
		}

		Sound_Play(this, CHAN_VOICE, "monster_zombie.pain");
	}

	/* set the functional differences */
	CBaseMonster::Death();
}

void
monster_zombie::IdleNoise(void)
{
	/* don't make noise if we're dead (corpse) */
	if (style == MONSTER_DEAD) {
		return;
	}

	if (m_flIdleTime > time) {
		return;
	}
	m_flIdleTime = time + random(2,10);

	Sound_Play(this, CHAN_VOICE, "monster_zombie.idle");
}

void
monster_zombie::Respawn(void)
{
	CBaseMonster::Respawn();
	SetFrame(ZO_IDLE);
}

void
monster_zombie::monster_zombie(void)
{
	Sound_Precache("monster_zombie.alert");
	Sound_Precache("monster_zombie.attack");
	Sound_Precache("monster_zombie.attackhit");
	Sound_Precache("monster_zombie.attackmiss");
	Sound_Precache("monster_zombie.idle");
	Sound_Precache("monster_zombie.pain");
	netname = "Zombie";
	model = "models/zombie.mdl";
	base_health = Skill_GetValue("zombie_health", 50);
	base_mins = [-16,-16,0];
	base_maxs = [16,16,72];
	m_iAlliance = MAL_ALIEN;
	CBaseMonster::CBaseMonster();
}
