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

/* generic function that applies damage, pain and suffering */
void
Damage_Apply(entity t, entity c, float dmg, int w, int type)
{
	base_player tp = (base_player)t;

	CGameRules rules = (CGameRules)g_grMode;
	if (t.flags & FL_GODMODE) {
		return;
	}

	/* already dead, please avoid recursion */
	if (t.health <= 0) {
		return;
	}

	/* skip armor */
	if not (type & DMG_SKIP_ARMOR)
	if (tp.armor && dmg > 0) {
		float flArmor;
		float flNewDamage;

		flNewDamage = dmg * 0.2;
		flArmor = (dmg - flNewDamage) * 0.5;

		if (flArmor > tp.armor) {
			flArmor = tp.armor;
			flArmor *= (1/0.5);
			flNewDamage = dmg - flArmor;
			tp.armor = 0;
		} else {
			tp.armor -= flArmor;
		}
		dmg = flNewDamage;
	}

	dmg = rint(dmg);
	t.health -= dmg;

	/* the globals... */
	g_dmg_eAttacker = c;
	g_dmg_eTarget = t;
	g_dmg_iDamage = dmg;
	g_dmg_iHitBody = trace_surface_id;
	g_dmg_iFlags = type;
	g_dmg_iWeapon = w;

	if (dmg > 0) {
		t.dmg_take = dmg;
		t.dmg_inflictor = c;
	} else if (t.max_health && t.health > t.max_health) {
		t.health = t.max_health;
	}

	/* set this global in case we need it later */
	g_eAttacker = c;

	CBaseEntity s = (CBaseEntity)t;

	if (s.health <= 0) {
		if (s.flags & FL_CLIENT) {
			rules.PlayerDeath((player)s);
		} else {
			s.Death();
		}
	} else {
		if (s.flags & FL_CLIENT) {
			rules.PlayerPain((player)s);
		} else {
			s.Pain();
		}
	}
}

/* physical check of whether or not we can trace important parts of an ent */
float
Damage_CheckTrace(entity t, vector vecHitPos)
{
	/* We're lazy. Who cares */
	if (t.solid == SOLID_BSP) {
		return TRUE;
	}

	traceline(vecHitPos, t.origin, 1, self);
	if (trace_fraction == 1) {
		return TRUE;
	}
	traceline(vecHitPos, t.origin + [15,15,0], 1, self);
	if (trace_fraction == 1) {
		return TRUE;
	}
	traceline(vecHitPos, t.origin + [-15,-15,0], 1, self);
	if (trace_fraction == 1) {
		return TRUE;
	}
	traceline(vecHitPos, t.origin + [-15,15,0], 1, self);
	if (trace_fraction == 1) {
		return TRUE;
	}
	traceline(vecHitPos, t.origin + [15,-15,0], 1, self);
	if (trace_fraction == 1) {
		return TRUE;
	}

	return FALSE;
}

/* even more pain and suffering, mostly used for explosives */
void
Damage_Radius(vector org, entity attacker, float dmg, float r, int check, int w)
{
	float new_dmg;
	float dist;
	float diff;
	vector pos;

	for (entity e = world; (e = findfloat(e, ::takedamage, DAMAGE_YES));) {
		pos[0] = e.absmin[0] + (0.5 * (e.absmax[0] - e.absmin[0]));
		pos[1] = e.absmin[1] + (0.5 * (e.absmax[1] - e.absmin[1]));
		pos[2] = e.absmin[2] + (0.5 * (e.absmax[2] - e.absmin[2]));

		/* don't bother if it's not anywhere near us */
		dist = vlen(org - pos);
		if (dist > r) {
			continue;
		}

		/* can we physically hit this thing? */
		if (Damage_CheckTrace(e, org) == FALSE) {
			if (check == TRUE) {
				continue;
			}
		}

		/* calculate new damage values */
		diff = vlen(org - pos);
		diff = (r - diff) / r;
		new_dmg = rint(dmg * diff);

		if (diff > 0) {
			Damage_Apply(e, attacker, new_dmg, w, DMG_EXPLODE);

			/* approximate, feel free to tweak */
			if (e.movetype == MOVETYPE_WALK) {
				makevectors(vectoangles(e.origin - org));
				e.velocity += v_forward * (new_dmg * 5); 
			}
		}
	}
}
