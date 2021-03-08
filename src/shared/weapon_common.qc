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

#ifdef SERVER
void Decals_Init(void);
#endif

void Weapons_Init(void)
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

	for (int i = 0; i < g_weapons.length; i++) {
		if (g_weapons[i].precache != __NULL__) {
			g_weapons[i].precache();
		}
	}
}

void Weapons_SetModel(string mdl)
{
#ifdef CLIENT
	setmodel(pSeat->m_eViewModel, mdl);
#endif
}

void Weapons_SetGeomset(string set)
{
#ifdef CLIENT
	setcustomskin(pSeat->m_eViewModel, "", set);
#endif
}

void Weapons_Draw(void)
{
	player pl = (player)self;
	int i = pl.activeweapon;

	pl.w_attack_next = 0.5f;
	pl.w_idle_next = 2.5f;
	pl.viewzoom = 1.0f;

#ifdef CLIENT
	entity eold = self;
	self = pSeat->m_pWeaponFX;
	spawnfunc_CBaseFX();
	self = eold;
#endif

	/* make sure this is all wiped */
	pl.a_ammo1 = pl.a_ammo2 = pl.a_ammo3 = 0;

	if (g_weapons[i].draw != __NULL__) {
		g_weapons[i].draw();
	}

	if (g_weapons[i].updateammo != __NULL__) {
		g_weapons[i].updateammo(pl);
	}

}

void Weapons_Holster(void)
{
	player pl = (player)self;
	int i = pl.activeweapon;
	if (g_weapons[i].holster != __NULL__) {
		g_weapons[i].holster();
	}
}

void Weapons_Primary(void)
{
	player pl = (player)self;
	int i = pl.activeweapon;

	if (pl.flags & FL_NOATTACK)
		return;

	if (g_weapons[i].primary != __NULL__) {
		g_weapons[i].primary();
	}

	if (g_weapons[i].updateammo != __NULL__) {
		g_weapons[i].updateammo(pl);
	}
}

void Weapons_AmmoUpdate(entity target)
{
	player pl = (player)target;
	int i = pl.activeweapon;

	if (g_weapons[i].updateammo != __NULL__) {
		g_weapons[i].updateammo(pl);
	}
}

void Weapons_Secondary(void)
{
	player pl = (player)self;
	int i = pl.activeweapon;

	if (pl.flags & FL_NOATTACK)
		return;

	if (g_weapons[i].secondary != __NULL__) {
		g_weapons[i].secondary();
	}

	if (g_weapons[i].updateammo != __NULL__) {
		g_weapons[i].updateammo(pl);
	}

}

void Weapons_Reload(void)
{
	player pl = (player)self;
	int i = pl.activeweapon;

	if (pl.flags & FL_NOATTACK)
		return;

	if (g_weapons[i].reload != __NULL__) {
		g_weapons[i].reload();
	}

	if (g_weapons[i].updateammo != __NULL__) {
		g_weapons[i].updateammo(pl);
	}
}

void Weapons_Release(void)
{
	player pl = (player)self;
	int i = pl.activeweapon;
	if (g_weapons[i].release != __NULL__) {
		g_weapons[i].release();
	}
	
	pl.gflags &= ~GF_SEMI_TOGGLED;
}

void Weapons_DrawCrosshair(void)
{
	player pl = (player)self;
	int i = pl.activeweapon;
	if (g_weapons[i].crosshair != __NULL__) {
		g_weapons[i].crosshair();
	}
}

string Weapons_GetWorldmodel(int id)
{
	if (g_weapons[id].wmodel != __NULL__) {
		return g_weapons[id].wmodel();
	}
	
	return "";
}

string Weapons_GetPlayermodel(int id)
{
	if (g_weapons[id].pmodel != __NULL__) {
		return g_weapons[id].pmodel();
	}
	
	return "";
}

string Weapons_GetDeathmessage(int id)
{
	if (g_weapons[id].deathmsg != __NULL__) {
		return g_weapons[id].deathmsg();
	}
	
	return "";
}

float Weapons_GetAim(int id)
{
	if (g_weapons[id].aimanim != __NULL__) {
		return g_weapons[id].aimanim();
	}
	
	return 0;
}

#ifdef CLIENT
void Weapons_HUDPic(int id, int s, vector pos, float a)
{
	if (g_weapons[id].hudpic != __NULL__) {
		g_weapons[id].hudpic(s, pos, a);
	}
}
#endif

void Weapons_MakeVectors(void)
{
#ifdef SERVER
	player pl = (player)self;
	makevectors(pl.v_angle);
#else
	makevectors(view_angles);
#endif
}

vector Weapons_GetCameraPos(void)
{
#ifdef SERVER
	return self.origin + self.view_ofs;
#else
	return getproperty(VF_ORIGIN);
#endif
}

void Weapons_ViewAnimation(int i)
{
#ifdef CLIENT
	player pl = (player)pSeat->m_ePlayer;
	View_PlayAnimation(i);
#else
	player pl = (player)self;
#endif
	pl.weapontime = 0.0f;
}

#ifdef CLIENT
int View_GetAnimation(void);
int Weapons_GetAnimation(void)
{
	return View_GetAnimation();
}
#endif

void Weapons_ViewPunchAngle(vector add)
{
#ifdef CLIENT
	player pl = (player)self;
	pl.punchangle += add;
#endif
}

void Weapons_PlaySound(entity t, float ch, string s, float vol, float at)
{
#ifdef SERVER
	sound(t, ch, s, vol, at);
#endif
}

int Weapons_IsPresent(player pl, int w)
{
	if (pl.g_items & g_weapons[w].id) {
		return TRUE;
	} else {
		return FALSE;
	}
}
/*
=================
Weapons_UpdateAmmo

Sets .a_ammoX fields and clamps them so they can be networked as a single byte.
=================
*/
void
Weapons_UpdateAmmo(base_player pl, int a1, int a2, int a3)
{
	/* no change */
	if (a1 == -1) {
		a1 = pl.a_ammo1;
	}
	if (a2 == -1) {
		a2 = pl.a_ammo2;
	}
	if (a3 == -1) {
		a3 = pl.a_ammo3;
	}

	/* networked as bytes, since we don't need more. Clamp to avoid errors */
	pl.a_ammo1 = bound(0, a1, 255);
	pl.a_ammo2 = bound(0, a2, 255);
	pl.a_ammo3 = bound(0, a3, 255);
}
