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

/*QUAKED monster_gargantua (0 0.8 0.8) (-32 -32 0) (32 32 128)

HALF-LIFE (1998) ENTITY

Gargantua

*/

enum
{
	GARG_IDLE,
	GARG_IDLE2,
	GARG_IDLE3,
	GARG_IDLE4,
	GARG_WALK,
	GARG_RUN,
	GARG_SHOOT,
	GARG_SHOOT2,
	GARG_ATTACK,
	GARG_STOMP,
	GARG_LEFT,
	GARG_RIGHT,
	GARG_FLINCH,
	GARG_FLINCH2,
	GARG_DIE,
	GARG_BITEHEAD,
	GARG_THROW,
	GARG_SMASH,
	GARG_ROLLCAR,
	GARG_KICKCAR,
	GARG_PUSHCAR,
	GARG_BUST
};

class monster_gargantua:CBaseMonster
{
	float m_flIdleTime;

	void(void) monster_gargantua;

	virtual void(void) Death;
	virtual void(void) Pain;
	virtual void(void) IdleNoise;
	virtual void(void) Respawn;
};

void
monster_gargantua::IdleNoise(void)
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

	Sound_Play(this, CHAN_VOICE, "monster_gargantua.idle");
}

void
monster_gargantua::Pain(void)
{
	CBaseMonster::Pain();

	if (m_flAnimTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	Sound_Play(this, CHAN_VOICE, "monster_gargantua.pain");
	SetFrame((random() < 0.5) ? GARG_FLINCH : GARG_FLINCH2);
	m_flAnimTime = time + 0.25f;
}

void
monster_gargantua::Death(void)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		SetFrame(GARG_DIE);
		Sound_Play(this, CHAN_VOICE, "monster_gargantua.die");
	}

	/* set the functional differences */
	CBaseMonster::Death();
}

void
monster_gargantua::Respawn(void)
{
	CBaseMonster::Respawn();
	SetFrame(GARG_IDLE);
	/* takes damage from explosives only
	 * takedamage = DAMAGE_NO; */
	iBleeds = FALSE;
}

void monster_gargantua::monster_gargantua(void)
{
	Sound_Precache("monster_gargantua.alert");
	Sound_Precache("monster_gargantua.attack");
	Sound_Precache("monster_gargantua.attackflame");
	Sound_Precache("monster_gargantua.attackflameon");
	Sound_Precache("monster_gargantua.attackflameoff");
	Sound_Precache("monster_gargantua.die");
	Sound_Precache("monster_gargantua.idle");
	Sound_Precache("monster_gargantua.pain");
	Sound_Precache("monster_gargantua.step");
	netname = "Gargantua";
	model = "models/garg.mdl";
	base_health = Skill_GetValue("gargantua_health", 800);
	base_mins = [-32,-32,0];
	base_maxs = [32,32,128];
	CBaseMonster::CBaseMonster();
}
