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

/*QUAKED monster_apache (0 0.8 0.8) (-300 -300 -172) (300 300 8)

HALF-LIFE (1998) ENTITY

Boeing AH-64 Apache

*/

class monster_apache:CBaseMonster
{
	void(void) monster_apache;
	virtual void(void) Respawn;
};

void monster_apache::Respawn(void)
{
	CBaseMonster::Respawn();
	movetype = MOVETYPE_NONE;
	takedamage = DAMAGE_NO;
	iBleeds = FALSE;
	setsize(this, [-300,-300,-172], [300, 300, 8]);
}

void monster_apache::monster_apache(void)
{
	netname = "Apache";
	model = "models/apache.mdl";
	base_mins = [-16,-16,0];
	base_maxs = [16,16,72];
	base_health = Skill_GetValue("apache_health", 250);
	CBaseMonster::CBaseMonster();
}
