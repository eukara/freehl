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

/*QUAKED monster_alien_grunt (0 0.8 0.8) (-32 -32 0) (32 32 64)

HALF-LIFE (1998) ENTITY

Alien Grunt

*/

enum
{
	AG_IDLE,
	AG_THREAT,
	AG_WALK,
	AG_RUN,
	AG_LEFT,
	AG_RIGHT,
	AG_FLINCH,
	AG_FLINCHBIG,
	AG_ATTACK,
	AG_ATTACK2,
	AG_VICTORYSQUAT,
	AG_VICTORYEAT,
	AG_VICTORYSTAND,
	AG_FLINCHARML,
	AG_FLINCHLEGL,
	AG_FLINCHARMR,
	AG_FLINCHLEGR,
	AG_SHOOTUP,
	AG_SHOOTDOWN,
	AG_SHOOT,
	AG_SHOOTQUICK,
	AG_SHOOTLONG,
	AG_DIEHS,
	AG_DIEGUT,
	AG_DIEFORWARD,
	AG_DIE,
	AG_DIEBACK,
	AG_FLOAT,
	AG_SCARE,
	AG_OPEN,
	AG_SMASHRAIL,
	AG_LAND
};

class monster_alien_grunt:CBaseMonster
{
	float m_flIdleTime;
	float m_flPainTime;

	void(void) monster_alien_grunt;

	virtual void(void) Pain;
	virtual void(void) Death;
	virtual void(void) IdleNoise;
	virtual void(void) Respawn;
};

void
monster_alien_grunt::Pain(void)
{
	CBaseMonster::Pain();

	if (m_flPainTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	Sound_Play(this, CHAN_VOICE, "monster_alien_grunt.pain");
	SetFrame(AG_FLINCH + floor(random(0, 2)));
	m_flPainTime = time + 0.25f;
}

void
monster_alien_grunt::Death(void)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		/* headshots == different animation */
		if (g_dmg_iHitBody == BODY_HEAD) {
			if (random() < 0.5) {
				SetFrame(AG_DIEHS);
			} else {
				SetFrame(AG_DIEFORWARD);
			}
		} else {
			SetFrame(AG_DIE + floor(random(0, 2)));
		}

		Sound_Play(this, CHAN_VOICE, "monster_alien_grunt.die");
	}

	/* set the functional differences */
	CBaseMonster::Death();
}

void
monster_alien_grunt::IdleNoise(void)
{
	/* don't make noise if we're dead (corpse) */
	if (style == MONSTER_DEAD) {
		return;
	}

	if (m_flIdleTime > time) {
		return;
	}
	m_flIdleTime = time + random(2,10);

	Sound_Play(this, CHAN_VOICE, "monster_alien_grunt.idle");
}

void
monster_alien_grunt::Respawn(void)
{
	CBaseMonster::Respawn();
	SetFrame(AG_IDLE);
}

void
monster_alien_grunt::monster_alien_grunt(void)
{
	Sound_Precache("monster_alien_grunt.alert");
	Sound_Precache("monster_alien_grunt.attack");
	Sound_Precache("monster_alien_grunt.die");
	Sound_Precache("monster_alien_grunt.idle");
	Sound_Precache("monster_alien_grunt.pain");

	netname = "Alien Grunt";
	model = "models/agrunt.mdl";
	base_mins = [-32,-32,0];
	base_maxs = [32,32,64];
	base_health = Skill_GetValue("agrunt_health", 90);
	CBaseMonster::CBaseMonster();
}
