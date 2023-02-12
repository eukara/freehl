/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

#ifndef NEW_INVENTORY
var int g_weapon_weights[g_weapons.length];

#ifdef CLIENT
var int g_weapon_order[g_weapons.length];
#endif

void
Weapons_Init(void)
{
	/* in the future we'll have no internal weapon table, then this will fill
	 * one up... */
	/*searchhandle sh;
	filestream fh;
	string line;
	sh = search_begin("scripts/weapon_*.txt", TRUE, TRUE);
	for (int i = 0; i < search_getsize(sh); i++) {
		fh = fopen(search_getfilename(sh, i), FILE_READ);
		if (fh < 0) {
			continue;
		}

		while ((line = fgets(fh))) {
			int w = tokenize(line);
			switch (argv(0)) {
				case "name":
					break;
				case "slot":
					break;
				case "slot_pos":
					break;
			}
		}
		fclose(fh);
	}*/

	for (int i = 0; i < g_weapons.length; i++)
		if (g_weapons[i].precache != __NULL__)
			g_weapons[i].precache();

	/* check our weapon weights */
	int max = 0;
	for (int i = 0; i < g_weapons.length; i++)
		if (g_weapons[i].weight > max)
			max = g_weapons[i].weight;

	/* don't bother building the list if we've got no weights */
	if (max <= 0)
		return;

	/* position in the weight array */
	int w = 0;

	/* loop through all weights */
	for (int b = 0; b <= max; b++) {
		/* loop through all weapons */
		for (int i = 0; i < g_weapons.length; i++) {
			/* if we've found a valid weight, add the weapon to the list */
			if (g_weapons[i].weight == b) {
				g_weapon_weights[w] = i;
				w++;
			}
		}
	}

#if 0
	for (int i = 0; i < g_weapons.length; i++)
		print(sprintf("Weapon-Weight order: %s, %i\n", g_weapons[g_weapon_weights[i]].name, i));
#endif

#ifdef CLIENT
	/* build our slot-order table */
	int st = 0;

	int max_slots = 0;
	for (int i = 0; i < g_weapons.length; i++)
		if (g_weapons[i].slot > max_slots)
			max_slots = g_weapons[i].slot;
	int max_pos = 0;
	for (int i = 0; i < g_weapons.length; i++)
		if (g_weapons[i].slot_pos > max_pos)
			max_pos = g_weapons[i].slot_pos;

	/* loop through all slots */
	for (int s = 0; s <= max_slots; s++) {
		/* loop through all positions */
		for (int p = 0; p < max_pos; p++) {
			/* loop through all the weapons */
			for (int i = 0; i < g_weapons.length; i++) {
				if (g_weapons[i].slot == s && g_weapons[i].slot_pos == p) {
					g_weapon_order[st] = i;
					st++;
				}
			}
		}
	}
#if 0
	for (int i = 0; i < g_weapons.length; i++)
		print(sprintf("Weapon-List order: %s, %i\n", g_weapons[g_weapon_order[i]].name, i));
#endif
#endif
}

void
Weapons_SetLeftModel(string mdl)
{
#ifdef CLIENT
	setmodel(pSeat->m_eViewModelL, mdl);
	setsize(pSeat->m_eViewModelL, [0,0,0], [0,0,0]);
	pSeat->m_eViewModelL.effects |= EF_NOSHADOW;
#endif
}
void
Weapons_SetRightModel(string mdl)
{
#ifdef CLIENT
	setmodel(pSeat->m_eViewModel, mdl);
	setsize(pSeat->m_eViewModel, [0,0,0], [0,0,0]);
	pSeat->m_eViewModel.effects |= EF_NOSHADOW;
#endif
}

void
Weapons_SetModel(string mdl)
{
	Weapons_SetRightModel(mdl);
	Weapons_SetLeftModel("");
}

void
Weapons_SetRightGeomset(string set)
{
#ifdef CLIENT
	setcustomskin(pSeat->m_eViewModel, "", set);
#endif
}
void
Weapons_SetLeftGeomset(string set)
{
#ifdef CLIENT
	setcustomskin(pSeat->m_eViewModelL, "", set);
#endif
}

void
Weapons_SetGeomset(string set)
{
	Weapons_SetRightGeomset(set);
}

void
Weapons_Draw(player pl)
{
	int i = pl.activeweapon;

	/* In case the previous weapon hid the model */
	Weapons_EnableModel();

	pl.w_attack_next = 0.5f;
	pl.w_idle_next = 2.5f;
	pl.viewzoom = 1.0f;

	/* we're meant to respawn when we're dead, don't unset! */
	if (pl.health > 0) {
		pl.think = __NULL__;
		pl.nextthink = 0.0f;
	}

	/* make sure this is all wiped */
	pl.a_ammo1 = pl.a_ammo2 = pl.a_ammo3 = 0;

	if (g_weapons[i].draw != __NULL__)
		g_weapons[i].draw(pl);

	if (g_weapons[i].updateammo != __NULL__)
		g_weapons[i].updateammo(pl);

	pl.gflags |= GF_SEMI_TOGGLED;
}

void
Weapons_Holster(player pl)
{
	int i = pl.activeweapon;

	if (g_weapons[i].holster != __NULL__)
		g_weapons[i].holster(pl);
}

void
Weapons_Primary(player pl)
{
	int i = pl.activeweapon;

	if (pl.gflags & GF_SEMI_TOGGLED)
		return;

	if (g_weapons[i].primary != __NULL__)
		g_weapons[i].primary(pl);

	if (g_weapons[i].updateammo != __NULL__)
		g_weapons[i].updateammo(pl);
}

void 
Weapons_AmmoUpdate(entity target)
{
	player pl = (player)target;
	int i = pl.activeweapon;

	if (g_weapons[i].updateammo != __NULL__)
		g_weapons[i].updateammo(pl);

}

void
Weapons_Secondary(player pl)
{
	int i = pl.activeweapon;

	if (g_weapons[i].secondary != __NULL__)
		g_weapons[i].secondary(pl);

	if (g_weapons[i].updateammo != __NULL__)
		g_weapons[i].updateammo(pl);
}

void
Weapons_Reload(player pl)
{
	int i = pl.activeweapon;

	if (g_weapons[i].reload != __NULL__)
		g_weapons[i].reload(pl);

	if (g_weapons[i].updateammo != __NULL__)
		g_weapons[i].updateammo(pl);
}

void
Weapons_Release(player pl)
{
	int i = pl.activeweapon;

	if (g_weapons[i].release != __NULL__)
		g_weapons[i].release(pl);

	pl.gflags &= ~GF_SEMI_TOGGLED;
}

void
Weapons_PreDraw(player pl, int thirdperson)
{
	int i = pl.activeweapon;

	if (g_weapons[i].predraw != __NULL__)
		g_weapons[i].predraw(pl, thirdperson);
}

int
Weapons_IsEmpty(player pl, int w)
{
	int r = 0;

	entity oself = self;
	self = pl;

	if (g_weapons[w].isempty != __NULL__)
		r = g_weapons[w].isempty(pl);

	self = oself;

	return (r);
}


weapontype_t
Weapons_GetType(player pl, int w)
{
	weapontype_t r = WPNTYPE_INVALID;

	entity oself = self;
	self = pl;

	if (g_weapons[w].type != __NULL__)
		r = g_weapons[w].type(pl);

	self = oself;

	return (r);
}

void
Weapons_DrawCrosshair(player pl)
{
	int i = pl.activeweapon;

	if (g_weapons[i].postdraw != __NULL__)
		g_weapons[i].postdraw(pl);
}

string
Weapons_GetWorldmodel(int id)
{
	if (g_weapons[id].wmodel != __NULL__)
		return g_weapons[id].wmodel();

	return "";
}

string
Weapons_GetPlayermodel(player pl, int id)
{
	if (g_weapons[id].pmodel != __NULL__)
		return g_weapons[id].pmodel(pl);

	return "";
}

string
Weapons_GetDeathmessage(int id)
{
	if (g_weapons[id].deathmsg != __NULL__)
		return g_weapons[id].deathmsg();

	return "";
}

float
Weapons_GetAim(player pl, int id)
{
	if (g_weapons[id].aimanim != __NULL__)
		return g_weapons[id].aimanim(pl);

	return (0);
}

#ifdef CLIENT
void
Weapons_HUDPic(player pl, int id, int s, vector pos, float a)
{
	if (g_weapons[id].hudpic != __NULL__)
		g_weapons[id].hudpic(pl, s, pos, a);
}
#endif

void
Weapons_MakeVectors(player pl)
{
#ifdef SERVER
	makevectors(pl.v_angle);
#else
	makevectors(view_angles);
#endif
}

vector
Weapons_GetCameraPos(player pl)
{
#ifdef SERVER
	return (pl.origin + pl.view_ofs);
#else
	return getproperty(VF_ORIGIN);
#endif
}

void
Weapons_ViewAnimation(player pl, int i)
{
#if 0
	View_PlayAnimation(i);
#endif
	pl.weaponframe = i;
	pl.weapontime = 0.0f;
}

#ifdef CLIENT
int View_GetAnimation(void);
#endif

int
Weapons_GetAnimation(player pl)
{
	return pl.weaponframe;
}

void
Weapons_ViewPunchAngle(player pl, vector add)
{
	pl.punchangle += add;
}

int
Weapons_IsPresent(player pl, int w)
{
	if (pl.g_items & g_weapons[w].id) {
		return (1);
	} else {
		return (0);
	}
}

void
Weapons_EnableModel(void)
{
#ifdef CLIENT
	View_EnableViewmodel();
#endif
}

void
Weapons_DisableModel(void)
{
#ifdef CLIENT
	View_DisableViewmodel();
#endif
}

/*
=================
Weapons_UpdateAmmo

Sets .a_ammoX fields and clamps them so they can be networked as a single byte.
=================
*/
void
Weapons_UpdateAmmo(player pl, int a1, int a2, int a3)
{
	/* no change */
	if (a1 == -1)
		a1 = pl.a_ammo1;
	if (a2 == -1)
		a2 = pl.a_ammo2;
	if (a3 == -1)
		a3 = pl.a_ammo3;

	/* networked as bytes, since we don't need more. Clamp to avoid errors */
	pl.a_ammo1 = a1;
	pl.a_ammo2 = a2;
	pl.a_ammo3 = a3;
}

void
Weapons_Sound(entity pl, float channel, string snd)
{
#if 0
#ifdef SERVER
	float prev = pl.dimension_see;
	pl.dimension_see=0;
	Sound_Play(pl, channel, snd);
	pl.dimension_see = prev;
#else
	/* client side == immediately */
	Sound_Play(pl, channel, snd);
#endif
#else
	#ifdef SERVER
	Sound_Play(pl, channel, snd);
	#endif
#endif
}
#endif