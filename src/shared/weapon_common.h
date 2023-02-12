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
/* for AI identification purposes */
typedef enum
{
	WPNTYPE_INVALID,	/* no logic */
	WPNTYPE_RANGED,		/* will want to keep their distance mostly */
	WPNTYPE_THROW,		/* has to keep some distance, but not too far */
	WPNTYPE_CLOSE,		/* have to get really close */
	WPNTYPE_FULLAUTO,	/* for things that need to be held down */
	WPNTYPE_SEMI		/* semi automatic */
} weapontype_t;

typedef struct
{
	string name;
	int id; /* bitflag id */
	int slot;
	int slot_pos;
	int allow_drop;
	int weight; /* required for bestweapon */
	void(void) precache;
	string() wmodel;
	string() deathmsg;

	/* player specific */
	string(player) pmodel;
	float(player) aimanim;
	weapontype_t(player) type; /* required for bot-AI */
	void(player) draw;
	void(player) holster;
	void(player) primary;
	void(player) secondary;
	void(player) reload;
	void(player) release;
	int(player, int, int) pickup;
	void(player) updateammo;

	void(player, int) predraw; /* predraw... */
	void(player) postdraw; /* postdraw... */

	int(player) isempty; /* kinda handy */
	void(player, int, vector, float) hudpic;
} weapon_t;

void Weapons_Holster(player pl);
void Weapons_Primary(player pl);
void Weapons_Secondary(player pl);
void Weapons_Reload(player pl);
void Weapons_Release(player pl);
void Weapons_PreDraw(player pl, int);

float Weapons_GetAim(player, int);
int Weapons_IsEmpty(player, int);
void Weapons_DrawCrosshair(player pl);
void Weapons_MakeVectors(player pl);
vector Weapons_GetCameraPos(player pl);
void Weapons_ViewAnimation(player pl, int);
void Weapons_ViewPunchAngle(player pl, vector);
int Weapons_IsPresent(player, int);
void Weapons_UpdateAmmo(player, int, int, int);
int Weapons_GetAnimation(player pl);
void Weapons_EnableModel(void);
void Weapons_DisableModel(void);
weapontype_t Weapons_GetType(player, int);

void Weapons_SetLeftModel(string);
void Weapons_SetRightModel(string);

void Weapons_SetRightGeomset(string);
void Weapons_SetLeftGeomset(string);

/* compat */
void Weapons_SetGeomset(string);
void Weapons_SetModel(string);

void Weapons_Sound(entity, float, string);

#ifdef CLIENT
string Weapons_GetPlayermodel(player, int);
void Weapons_HUDPic(player, int, int, vector, float);
#endif
#else
#endif