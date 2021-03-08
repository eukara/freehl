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

/*QUAKED monster_bigmomma (0 0.8 0.8) (-95 -95 0) (95 95 190)

HALF-LIFE (1998) ENTITY

Gonarch

*/

enum
{
	GON_IDLE,
	GON_IDLE2,
	GON_WALK,
	GON_RUN,
	GON_DIE,
	GON_CLAW,
	GON_CLAW2,
	GON_CLAW3,
	GON_SPAWN,
	GON_SHOOT,
	GON_FLINCH,
	GON_DEFEND,
	GON_JUMP,
	GON_ANGRY,
	GON_ANGRY2,
	GON_ANGRY3,
	GON_BREAKWALL,
	GON_FALL,
	GON_FALL2,
	GON_FALLDIE
};

class monster_bigmomma:CBaseMonster
{
	float m_flIdleTime;

	void(void) monster_bigmomma;

	virtual void(void) Death;
	virtual void(void) Pain;
	virtual void(void) IdleNoise;
	virtual void(void) Respawn;
};

void
monster_bigmomma::IdleNoise(void)
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

	Sound_Play(this, CHAN_VOICE, "monster_bigmomma.idle");
}

void
monster_bigmomma::Pain(void)
{
	CBaseMonster::Pain();

	if (m_flAnimTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	Sound_Play(this, CHAN_VOICE, "monster_bigmomma.pain");
	SetFrame(GON_FLINCH);
	m_flAnimTime = time + 0.25f;
}

void
monster_bigmomma::Death(void)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		SetFrame(GON_DIE);
		Sound_Play(this, CHAN_VOICE, "monster_bigmomma.die");
	}

	/* set the functional differences */
	CBaseMonster::Death();
}

void
monster_bigmomma::Respawn(void)
{
	CBaseMonster::Respawn();
	SetFrame(GON_IDLE);
}

void monster_bigmomma::monster_bigmomma(void)
{
	Sound_Precache("monster_bigmomma.alert");
	Sound_Precache("monster_bigmomma.attack");
	Sound_Precache("monster_bigmomma.child");
	Sound_Precache("monster_bigmomma.die");
	Sound_Precache("monster_bigmomma.idle");
	Sound_Precache("monster_bigmomma.pain");
	Sound_Precache("monster_bigmomma.step");
	netname = "Gonarch";
	model = "models/big_mom.mdl";
	/* health is based on factor, for it's not killable until last stage */
	base_health = Skill_GetValue("bigmomma_health_factor", 1.5) * 300;
	base_mins = [-95,-95,0];
	base_maxs = [95,95,190];
	CBaseMonster::CBaseMonster();
}
