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

typedef struct
{
	string name;
	int id; /* bitflag id */
	int slot;
	int slot_pos;
	int allow_drop;

	void(void) draw;
	void(void) holster;
	void(void) primary;
	void(void) secondary;
	void(void) reload;
	void(void) release;
	void(void) crosshair;

	void(void) precache;
	int(int, int) pickup;
	void(player) updateammo;
	string() wmodel;
	string() pmodel;
	string() deathmsg;
	float() aimanim;
	void(int, vector, float) hudpic;
} weapon_t;

float Weapons_GetAim(int);
void Weapons_Reload(void);
void Weapons_DrawCrosshair(void);
void Weapons_MakeVectors(void);
vector Weapons_GetCameraPos(void);
void Weapons_ViewAnimation(int);
void Weapons_ViewPunchAngle(vector);
void Weapons_PlaySound(entity, float, string, float, float);
int Weapons_IsPresent(player, int);
void Weapons_SetModel(string);
void Weapons_SetGeomset(string);
void Weapons_UpdateAmmo(base_player, int, int, int);

#ifdef CLIENT
string Weapons_GetPlayermodel(int);
int Weapons_GetAnimation(void);
void Weapons_HUDPic(int, int, vector, float);
#endif
