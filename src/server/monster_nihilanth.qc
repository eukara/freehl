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

/*QUAKED monster_nihilanth (0 0.8 0.8) (-192 -192 0) (192 192 384)

HALF-LIFE (1998) ENTITY

Nihilanth

*/

enum
{
	NIL_IDLE,
	NIL_ATTACK,
	NIL_ATTACK2,
	NIL_THROW,
	NIL_BLOCK,
	NIL_RECHARGE,
	NIL_IDLEOPEN,
	NIL_ATTACKOPEN,
	NIL_ATTACKOPEN2,
	NIL_FLINCH,
	NIL_FLINCH2,
	NIL_FALL,
	NIL_DIE,
	NIL_FORWARD,
	NIL_BACK,
	NIL_UP,
	NIL_DOWN,
	NIL_RIGHT,
	NIL_LEFT,
	NIL_WALK2,
	NIL_SHOOT
};

class monster_nihilanth:CBaseMonster
{
	float m_flIdleTime;

	void(void) monster_nihilanth;

	virtual void(void) Death;
	virtual void(void) Pain;
	virtual void(void) IdleNoise;
	virtual void(void) Respawn;
};

void
monster_nihilanth::IdleNoise(void)
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

	Sound_Play(this, CHAN_VOICE, "monster_nihilanth.idle");
}

void
monster_nihilanth::Pain(void)
{
	CBaseMonster::Pain();

	if (m_flAnimTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	Sound_Play(this, CHAN_VOICE, "monster_nihilanth.pain");

	SetFrame((random() < 0.5) ? NIL_FLINCH : NIL_FLINCH2);
	m_flAnimTime = time + 0.25f;
}

void
monster_nihilanth::Death(void)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		SetFrame(NIL_DIE);
		Sound_Play(this, CHAN_VOICE, "monster_nihilanth.die");
	}

	/* set the functional differences */
	CBaseMonster::Death();
}

void
monster_nihilanth::Respawn(void)
{
	CBaseMonster::Respawn();
	SetFrame(NIL_IDLE);
}

void monster_nihilanth::monster_nihilanth(void)
{
	Sound_Precache("monster_nihilanth.attack");
	Sound_Precache("monster_nihilanth.attackball");
	Sound_Precache("monster_nihilanth.attackballmove");
	Sound_Precache("monster_nihilanth.die");
	Sound_Precache("monster_nihilanth.idle");
	Sound_Precache("monster_nihilanth.pain");
	Sound_Precache("monster_nihilanth.recharge");
	netname = "Nihilanth";
	model = "models/nihilanth.mdl";
	base_health = Skill_GetValue("nihilanth_health", 800);
	base_mins = [-192,-192,-32];
	base_maxs = [192,192,384];
	CBaseMonster::CBaseMonster();
}
