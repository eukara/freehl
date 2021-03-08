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

/*QUAKED monster_bullchicken (0 0.8 0.8) (-32 -32 0) (32 32 64)

HALF-LIFE (1998) ENTITY

Bullsquid

*/

enum
{
	BULL_WALK,
	BULL_RUN,
	BULL_SURPIRSE,
	BULL_FLINCH,
	BULL_FLINCH2,
	BULL_LEFT,
	BULL_RIGHT,
	BULL_IDLE,
	BULL_WHIP,
	BULL_BITE,
	BULL_RANGE,
	BULL_LOOK,
	BULL_SEECRAB,
	BULL_EAT,
	BULL_INSPECT,
	BULL_SNIFF,
	BULL_DIE,
	BULL_DIE2,
	BULL_JUMP,
	BULL_DRAGIDLE,
	BULL_DRAG,
	BULL_SCARE,
	BULL_FALLIDLE,
	BULL_FALL
};

/* the growls are used in combination with the bite sounds
 * for close range attacks
 */

class monster_bullchicken:CBaseMonster
{
	float m_flIdleTime;

	void(void) monster_bullchicken;

	virtual void(void) Death;
	virtual void(void) Pain;
	virtual void(void) IdleNoise;
	virtual int(void) AnimIdle;
	virtual int(void) AnimWalk;
	virtual int(void) AnimRun;
};

int
monster_bullchicken::AnimIdle(void)
{
	return BULL_IDLE;
}

int
monster_bullchicken::AnimWalk(void)
{
	return BULL_WALK;
}

int
monster_bullchicken::AnimRun(void)
{
	return BULL_RUN;
}

void
monster_bullchicken::IdleNoise(void)
{
	/* don't make noise if we're dead (corpse) */
	if (style == MONSTER_DEAD) {
		return;
	}

	if (m_flIdleTime > time) {
		return;
	}
	/* timing needs to adjusted as sounds conflict */
	m_flIdleTime = time + random(2,10);

	Sound_Play(this, CHAN_VOICE, "monster_bullchicken.idle");
}

void
monster_bullchicken::Pain(void)
{
	CBaseMonster::Pain();

	if (m_flAnimTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	Sound_Play(this, CHAN_VOICE, "monster_bullchicken.pain");
	SetFrame((random() < 0.5) ? BULL_FLINCH : BULL_FLINCH2);
	m_flAnimTime = time + 0.25f;
}

void
monster_bullchicken::Death(void)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {

	/* two different animations */
	SetFrame((random() < 0.5) ? BULL_DIE : BULL_DIE2);

		Sound_Play(this, CHAN_VOICE, "monster_bullchicken.die");
	}

	/* set the functional differences */
	CBaseMonster::Death();
}

void monster_bullchicken::monster_bullchicken(void)
{
	Sound_Precache("monster_bullchicken.alert");
	Sound_Precache("monster_bullchicken.attack");
	Sound_Precache("monster_bullchicken.attackbite");
	Sound_Precache("monster_bullchicken.attackshoot");
	Sound_Precache("monster_bullchicken.die");
	Sound_Precache("monster_bullchicken.idle");
	Sound_Precache("monster_bullchicken.pain");
	netname = "Bullsquid";
	model = "models/bullsquid.mdl";
	base_health = Skill_GetValue("bullsquid_health", 40);
	base_mins = [-32,-32,0];
	base_maxs = [32,32,64];
	CBaseMonster::CBaseMonster();
}
