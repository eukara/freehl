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

/*QUAKED monster_alien_controller (0 0.8 0.8) (-16 -16 0) (16 16 72)

HALF-LIFE (1998) ENTITY

Alien Controller

*/

enum
{
	CON_ATTACK,
	CON_ATTACK2,
	CON_THROW,
	CON_IDLE2,
	CON_BLOCK,
	CON_SHOOT,
	CON_FLINCH,
	CON_FLINCH2,
	CON_FALL,
	CON_FORWARD,
	CON_BACKWARD,
	CON_UP,
	CON_DOWN,
	CON_RIGHT,
	CON_LEFT,
	CON_IDLE,
	CON_UNUSED,
	CON_UNUSED2,
	CON_DIE
};

class monster_alien_controller:CBaseMonster
{
	float m_flIdleTime;
	float m_flPainTime;

	void(void) monster_alien_controller;

	virtual void(void) Pain;
	virtual void(void) Death;
	virtual void(void) IdleNoise;
	virtual void(void) Respawn;
};

void
monster_alien_controller::Pain(void)
{
	CBaseMonster::Pain();

	if (m_flPainTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	Sound_Play(this, CHAN_VOICE, "monster_alien_controller.die");
	SetFrame(CON_FLINCH + floor(random(0, 2)));
	m_flPainTime = time + 0.25f;
}

void
monster_alien_controller::Death(void)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		SetFrame(CON_DIE);
		Sound_Play(this, CHAN_VOICE, "monster_alien_controller.die");
	}

	/* set the functional differences */
	CBaseMonster::Death();
}

void
monster_alien_controller::IdleNoise(void)
{
	/* don't make noise if we're dead (corpse) */
	if (style == MONSTER_DEAD) {
		return;
	}

	if (m_flIdleTime > time) {
		return;
	}
	m_flIdleTime = time + random(2,10);

	Sound_Play(this, CHAN_VOICE, "monster_alien_controller.idle");
}

void
monster_alien_controller::Respawn(void)
{
	CBaseMonster::Respawn();
	SetFrame(CON_IDLE);
}

void
monster_alien_controller::monster_alien_controller(void)
{
	Sound_Precache("monster_alien_controller.alert");
	Sound_Precache("monster_alien_controller.attack");
	Sound_Precache("monster_alien_controller.die");
	Sound_Precache("monster_alien_controller.idle");
	Sound_Precache("monster_alien_controller.pain");
	netname = "Alien Controller";
	model = "models/controller.mdl";
	base_mins = [-16,-16,0];
	base_maxs = [16,16,72];
	CBaseMonster::CBaseMonster();
}
