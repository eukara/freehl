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

/*QUAKED monster_cockroach (0 0.8 0.8) (-4 -4 0) (4 4 4)

HALF-LIFE (1998) ENTITY

Cockroach

*/

class monster_cockroach:CBaseMonster
{
	void(void) monster_cockroach;
	virtual void(void) Death;
};

void
monster_cockroach::Death(void)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		Sound_Play(this, CHAN_VOICE, "monster_cockroach.die");
	}

	/* make sure we gib this thing */
	health = -100;

	/* set the functional differences */
	CBaseMonster::Death();
}

void monster_cockroach::monster_cockroach(void)
{
	Sound_Precache("monster_cockroach.die");
	netname = "Cockroach";
	model = "models/roach.mdl";
	base_mins = [-1,-1,0];
	base_maxs = [1,1,1];
	CBaseMonster::CBaseMonster();
}
