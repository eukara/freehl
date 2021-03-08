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

/*QUAKED monster_leech (0 0.8 0.8) (-6 -6 0) (6 6 6)

HALF-LIFE (1998) ENTITY

Leech

*/

enum
{
	LEECH_SWIM,
	LEECH_SWIM2,
	LEECH_ATTACK,
	LEECH_HOVER,
	LEECH_LEFT,
	LEECH_RIGHT,
	LEECH_DIE,
	LEECH_DIEEND
};

class monster_leech:CBaseMonster
{
	float m_flIdleTime;

	void(void) monster_leech;

	virtual void(void) Death;
	virtual void(void) DeathEnd;
	virtual void(void) Respawn;
};

void
monster_leech::DeathEnd(void)
{
	SetFrame(LEECH_DIEEND);
}

void
monster_leech::Death(void)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		SetFrame(LEECH_DIE);
		think = DeathEnd;
		nextthink = time + 1.0f;
	}

	/* set the functional differences */
	CBaseMonster::Death();
}

void
monster_leech::Respawn(void)
{
	CBaseMonster::Respawn();
	SetFrame(LEECH_SWIM);
}

void monster_leech::monster_leech(void)
{
	Sound_Precache("monster_leech.alert");
	Sound_Precache("monster_leech.attack");
	netname = "Leech";
	model = "models/leech.mdl";
	base_mins = [-6,-6,0];
	base_maxs = [6,6,6];
	CBaseMonster::CBaseMonster();
}
