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

/*QUAKED monster_barnacle (0 0.8 0.8) (-16 -16 -36) (16 16 0)

HALF-LIFE (1998) ENTITY

Barnacle

*/

enum
{
	BCL_IDLE,
	BCL_IDLE2,
	BCL_IDLE3,
	BCL_FLINCH,
	BCL_ATTACK,
	BCL_CHEW,
	BCL_DIE
};

class monster_barnacle:CBaseMonster
{
	void(void) monster_barnacle;

	virtual void(void) Death;
	virtual void(void) Respawn;
	virtual void(void) Physics;
};

void
monster_barnacle::Physics(void)
{
	movetype = MOVETYPE_NONE;
}

void
monster_barnacle::Death(void)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		SetFrame(BCL_DIE);
		Sound_Play(this, CHAN_VOICE, "monster_barnacle.die");
	}

	/* set the functional differences */
	CBaseMonster::Death();
}

void
monster_barnacle::Respawn(void)
{
	CBaseMonster::Respawn();
	SetFrame(BCL_IDLE);
}

void monster_barnacle::monster_barnacle(void)
{
	Sound_Precache("monster_barnacle.attackchew");
	Sound_Precache("monster_barnacle.attackpull");
	Sound_Precache("monster_barnacle.die");

	netname = "Barnacle";
	model = "models/barnacle.mdl";
	base_mins = [-16,-16,-36];
	base_maxs = [16,16,0];
	base_health = Skill_GetValue("barnacle_health", 25);
	CBaseMonster::CBaseMonster();
}
