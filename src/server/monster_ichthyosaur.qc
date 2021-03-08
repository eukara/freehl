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

/*QUAKED monster_ichthyosaur (0 0.8 0.8) (-32 -32 0) (32 32 64)

HALF-LIFE (1998) ENTITY

Ichthyosaur

*/

enum
{
	ICHY_IDLE,
	ICHY_SWIM,
	ICHY_THRUST,
	ICHY_DIE1,
	ICHY_DIE2,
	ICHY_FLINCH,
	ICHY_FLINCH2,
	ICHY_DIE3,
	ICHY_BITER,
	ICHY_BITEL,
	ICHY_ATTACK,
	ICHY_RIGHT,
	ICHY_LEFT,
	ICHY_180,
	ICHY_HITCAGE,
	ICHY_JUMP
};

class monster_ichthyosaur:CBaseMonster
{
	float m_flIdleTime;

	void(void) monster_ichthyosaur;

	virtual void(void) Pain;
	virtual void(void) Death;
	virtual void(void) IdleNoise;
	virtual void(void) Respawn;
};

void
monster_ichthyosaur::Pain(void)
{
	CBaseMonster::Pain();

	if (m_flAnimTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	Sound_Play(this, CHAN_VOICE, "monster_ichthyosaur.pain");
	SetFrame(ICHY_FLINCH + floor(random(0, 2)));
	m_flAnimTime = time + 0.25f;
}

void
monster_ichthyosaur::Death(void)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		int r = floor(random(0,3));

		switch (r) {
		case 1:
			SetFrame(ICHY_DIE2);
			break;
		case 2:
			SetFrame(ICHY_DIE3);
			break;
		default:
			SetFrame(ICHY_DIE1);
			break;
		}

		Sound_Play(this, CHAN_VOICE, "monster_ichthyosaur.die");
	}

	/* set the functional differences */
	CBaseMonster::Death();
}

void
monster_ichthyosaur::IdleNoise(void)
{
	/* don't make noise if we're dead (corpse) */
	if (style == MONSTER_DEAD) {
		return;
	}

	if (m_flIdleTime > time) {
		return;
	}
	m_flIdleTime = time + random(2,10);

	Sound_Play(this, CHAN_VOICE, "monster_ichthyosaur.idle");
}

void
monster_ichthyosaur::Respawn(void)
{
	CBaseMonster::Respawn();
	SetFrame(ICHY_IDLE);
}

void
monster_ichthyosaur::monster_ichthyosaur(void)
{
	Sound_Precache("monster_ichthyosaur.alert");
	Sound_Precache("monster_ichthyosaur.attack");
	Sound_Precache("monster_ichthyosaur.die");
	Sound_Precache("monster_ichthyosaur.idle");
	Sound_Precache("monster_ichthyosaur.pain");
	netname = "Ichthyosaur";
	model = "models/icky.mdl";
	base_mins = [-32,-32,0];
	base_maxs = [32,32,64];
	CBaseMonster::CBaseMonster();
}
