/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
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

void HUD_DrawWeaponSelect(void);

/* Use first frame for drawing (needs precache) */
#define NUMSIZE_X 24/256
#define NUMSIZE_Y 24/128
#define HUD_ALPHA 0.5

float spr_hudnum[10] = {
	0 / 256,
	24 / 256,
	(24*2) / 256,
	(24*3) / 256,
	(24*4) / 256,
	(24*5) / 256,
	(24*6) / 256,
	(24*7) / 256,
	(24*8) / 256,
	(24*9) / 256
};

/* pre-calculated sprite definitions */
float spr_health[4] = {
	80 / 256, // pos x
	24 / 128, // pos u
	32 / 256, // size x
	32 / 128 // size y
};

float spr_suit1[4] = {
	0 / 256, // pos x
	24 / 128, // pos u
	40 / 256, // size x
	40 / 128 // size y
};

float spr_suit2[4] = {
	40 / 256, // pos x
	24 / 128, // pos u
	40 / 256, // size x
	40 / 128 // size y
};

float spr_flash1[4] = {
	160 / 256, // pos x
	24 / 128, // pos u
	32 / 256, // size x
	32 / 128 // size y
};

float spr_flash2[4] = {
	112 / 256, // pos x
	24 / 128, // pos u
	48 / 256, // size x
	32 / 128 // size y
};

/* precaches */
void
HUD_Init(void)
{
	g_cross_spr = spriteframe("sprites/crosshairs.spr", 0, 0.0f);
	g_laser_spr = spriteframe("sprites/laserdot.spr", 0, 0.0f);
	g_hud1_spr = spriteframe("sprites/640hud1.spr", 0, 0.0f);
	g_hud2_spr = spriteframe("sprites/640hud2.spr", 0, 0.0f);
	g_hud3_spr = spriteframe("sprites/640hud3.spr", 0, 0.0f);
	g_hud4_spr = spriteframe("sprites/640hud4.spr", 0, 0.0f);
	g_hud5_spr = spriteframe("sprites/640hud5.spr", 0, 0.0f);
	g_hud6_spr = spriteframe("sprites/640hud6.spr", 0, 0.0f);
	g_hud7_spr = spriteframe("sprites/640hud7.spr", 0, 0.0f);
	HUD_AmmoNotify_Init();
	HUD_DamageNotify_Init();
	HUD_ItemNotify_Init();
}

/* seperator for mainly ammo */
void
HUD_DrawSeperator(vector pos)
{
	drawsubpic(pos,
		[2,24],
		g_hud7_spr,
		[240/256, 0],
		[2/256, 24/128],
		g_hud_color,
		HUD_ALPHA,
		DRAWFLAG_ADDITIVE
	);
}

/* handle single/multiple digits */
void
HUD_DrawNumber(int iNumber, vector vecPos, float fAlpha, vector vColor)
{
	drawsubpic(vecPos,
		[24,24],
		g_hud7_spr,
		[spr_hudnum[iNumber], 0],
		[NUMSIZE_X, NUMSIZE_Y],
		vColor,
		fAlpha,
		DRAWFLAG_ADDITIVE
	);
}

void
HUD_DrawNums(float fNumber, vector vecPos, float fAlpha, vector vColor)
{
	int i = fNumber;
	if (i > 0) {
		while (i > 0) {
			HUD_DrawNumber((float)i % 10.0f, vecPos, fAlpha, vColor);
			i = i / 10;
			vecPos[0] -= 20;
		}
	} else {
		HUD_DrawNumber(0, vecPos, fAlpha, vColor);
	}
}

/* health */
void
HUD_DrawHealth(void)
{
	vector pos;
	player pl = (player)pSeat->m_ePlayer;

	if (pl.health != pSeatLocal->m_iHealthOld) {
		pSeatLocal->m_flHealthAlpha = 1.0;
	}

	if (pSeatLocal->m_flHealthAlpha >= HUD_ALPHA) {
		pSeatLocal->m_flHealthAlpha -= clframetime * 0.5;
	} else {
		pSeatLocal->m_flHealthAlpha = HUD_ALPHA;
	}

	pos = g_hudmins + [88, g_hudres[1] - 42];
	if (pl.health > 25) {
		drawsubpic(
			pos + [-72,-4],
			[32,32],
			g_hud7_spr,
			[spr_health[0], spr_health[1]],
			[spr_health[2], spr_health[3]],
			g_hud_color,
			pSeatLocal->m_flHealthAlpha,
			DRAWFLAG_ADDITIVE
		);
		HUD_DrawNums(pl.health, pos, pSeatLocal->m_flHealthAlpha, g_hud_color);
	} else {
		drawsubpic(
			pos + [-72,-4],
			[32,32],
			g_hud7_spr,
			[spr_health[0], spr_health[1]],
			[spr_health[2], spr_health[3]],
			[1,0,0],
			pSeatLocal->m_flHealthAlpha,
			DRAWFLAG_ADDITIVE
		);
		HUD_DrawNums(pl.health, pos, pSeatLocal->m_flHealthAlpha, [1,0,0]);
	}

	pSeatLocal->m_iHealthOld = pl.health;
}

/* armor/suit charge */
void
HUD_DrawArmor(void)
{
	vector pos;
	player pl = (player)pSeat->m_ePlayer;

	pos = g_hudmins + [198, g_hudres[1] - 42];
	
	if (pl.armor != pSeatLocal->m_iArmorOld) {
		pSeatLocal->m_flArmorAlpha = 1.0;
	}

	if (pSeatLocal->m_flArmorAlpha >= HUD_ALPHA) {
		pSeatLocal->m_flArmorAlpha -= clframetime * 0.5;
	} else {
		pSeatLocal->m_flArmorAlpha = HUD_ALPHA;
	}

	drawsubpic(
		pos + [-80,-9],
		[40,40],
		g_hud7_spr,
		[spr_suit2[0], spr_suit2[1]],
		[spr_suit2[2], spr_suit2[3]],
		g_hud_color,
		pSeatLocal->m_flArmorAlpha,
		DRAWFLAG_ADDITIVE
	);

	if (pl.armor > 0) {
		float perc = bound(0, (pl.armor / 100), 1.0);
		drawsubpic(
			pos + [-80,-9] + [0, 40 * (1.0-perc)],
			[40, 40 * perc],
			g_hud7_spr,
			[spr_suit1[0],spr_suit1[1] + spr_suit1[3] * (1.0-perc)],
			[spr_suit1[2], spr_suit1[3] * perc],
			g_hud_color,
			pSeatLocal->m_flArmorAlpha,
			DRAWFLAG_ADDITIVE
		);
	}

	HUD_DrawNums(pl.armor, pos, pSeatLocal->m_flArmorAlpha, g_hud_color);
	pSeatLocal->m_iArmorOld = pl.armor;
}

/* magazine/clip ammo */
void
HUD_DrawAmmo1(void)
{
	player pl = (player)pSeat->m_ePlayer;
	vector pos;

	if (pl.a_ammo1 != pSeatLocal->m_iAmmo1Old) {
		pSeatLocal->m_flAmmo1Alpha = 1.0;
		pSeatLocal->m_iAmmo1Old = pl.a_ammo1;
	}

	if (pSeatLocal->m_flAmmo1Alpha >= HUD_ALPHA) {
		pSeatLocal->m_flAmmo1Alpha -= clframetime * 0.5;
	} else {
		pSeatLocal->m_flAmmo1Alpha = HUD_ALPHA;
	}

	pos = g_hudmins + [g_hudres[0] - 152, g_hudres[1] - 42];
	HUD_DrawNums(pl.a_ammo1, pos, pSeatLocal->m_flAmmo1Alpha, g_hud_color);
	HUD_DrawSeperator(pos + [30,0]);
}

/* leftover type ammo */
void
HUD_DrawAmmo2(void)
{
	player pl = (player)pSeat->m_ePlayer;
	vector pos;

	if (pl.a_ammo2 != pSeatLocal->m_iAmmo2Old) {
		pSeatLocal->m_flAmmo2Alpha = 1.0;
		pSeatLocal->m_iAmmo2Old = pl.a_ammo2;
	}

	if (pSeatLocal->m_flAmmo2Alpha >= HUD_ALPHA) {
		pSeatLocal->m_flAmmo2Alpha -= clframetime * 0.5;
	} else {
		pSeatLocal->m_flAmmo2Alpha = HUD_ALPHA;
	}

	pos = g_hudmins + [g_hudres[0] - 72, g_hudres[1] - 42];
	HUD_DrawNums(pl.a_ammo2, pos, pSeatLocal->m_flAmmo2Alpha, g_hud_color);
}

/* special ammo */
void
HUD_DrawAmmo3(void)
{
	player pl = (player)pSeat->m_ePlayer;
	vector pos;

	if (pl.a_ammo3 != pSeatLocal->m_iAmmo3Old) {
		pSeatLocal->m_flAmmo3Alpha = 1.0;
		pSeatLocal->m_iAmmo3Old = pl.a_ammo3;
	}

	if (pSeatLocal->m_flAmmo3Alpha >= HUD_ALPHA) {
		pSeatLocal->m_flAmmo3Alpha -= clframetime * 0.5;
	} else {
		pSeatLocal->m_flAmmo3Alpha = HUD_ALPHA;
	}

	pos = g_hudmins + [g_hudres[0] - 72, g_hudres[1] - 74];
	HUD_DrawNums(pl.a_ammo3, pos, pSeatLocal->m_flAmmo3Alpha, g_hud_color);
}

/* ammo bar */
void
HUD_DrawAmmoBar(vector pos, float val, float max, float a)
{
	if (val <= 0)
		return;

	float perc;
	perc = val / max;
	drawfill(pos + [10,0], [20,4], g_hud_color, a, DRAWFLAG_NORMAL);
	drawfill(pos + [10,0], [20 * perc,4], [0,1,0], a, DRAWFLAG_NORMAL);
}

/* flashlight/torch indicator */
void
HUD_DrawFlashlight(void)
{
	vector pos;
	player pl = (player)pSeat->m_ePlayer;
	pos = g_hudmins + [g_hudres[0] - 48, 16];

	/* both on, draw both sprites at full intensity */
	if (pl.gflags & GF_FLASHLIGHT) {
		drawsubpic(
			pos,
			[32,32],
			g_hud7_spr,
			[spr_flash1[0], spr_flash1[1]],
			[spr_flash1[2], spr_flash1[3]],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);

		drawsubpic(
			pos,
			[48,32],
			g_hud7_spr,
			[spr_flash2[0], spr_flash2[1]],
			[spr_flash2[2], spr_flash2[3]],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[32,32],
			g_hud7_spr,
			[spr_flash1[0], spr_flash1[1]],
			[spr_flash1[2], spr_flash1[3]],
			g_hud_color,
			HUD_ALPHA,
			DRAWFLAG_ADDITIVE
		);
	}
}

/* logo animation used during e3 1998 */
void
HUD_DrawLogo(void)
{
	vector pos;
	static int f;
	static float frame_timer;

	frame_timer -= clframetime;
	pos = [g_hudres[0] - 262, 48];

	drawpic(
		pos,
		sprintf("sprites/640_logo.spr_%i.tga", f),
		[256,48],
		[1,1,1],
		1.0f,
		DRAWFLAG_ADDITIVE
	);

	if (frame_timer > 0) {
		return;
	}

	frame_timer = 0.1f;

	f++;
	if (f == 31) {
		f = 0;
	}
}

/* weapon/ammo pickup notifications */
void
HUD_DrawNotify(void)
{
	player pl = (player)self;
	vector pos;
	float a;

	pos = g_hudmins + [g_hudres[0] - 192, g_hudres[1] - 128];

	if (pSeatLocal->m_flPickupAlpha <= 0.0f) {
		pos[1] += 48;
		HUD_ItemNotify_Draw(pos);
		HUD_AmmoNotify_Draw(pos);
		return;
	}

	a = bound(0.0, pSeatLocal->m_flPickupAlpha, 1.0);
	pos[1] += 48 * (1.0 - a);
	Weapons_HUDPic(pl, pSeatLocal->m_iPickupWeapon, 1, pos, a);
	HUD_ItemNotify_Draw(pos);
	HUD_AmmoNotify_Draw(pos);
	pSeatLocal->m_flPickupAlpha -= (clframetime * 0.5);
}

void
HUD_WeaponPickupNotify(int w)
{
#if defined (VALVE) || defined (GEARBOX)
	switch (w) {
		case WEAPON_SNARK:
		case WEAPON_SATCHEL:
		case WEAPON_HANDGRENADE:
		case WEAPON_TRIPMINE:
#if defined(GEARBOX)
		case WEAPON_PENGUIN:
#endif
		return;
		default:
	}
#endif

	pSeatLocal->m_iPickupWeapon = w;
	pSeatLocal->m_flPickupAlpha = 2.5f;
}

void
HUD_DrawDamageIndicator(void)
{
	vector cross_pos;

	if (pSeatLocal->m_flDamageIndicator <= 0.0)
		return;

	cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];

	/*drawsubpic(
		cross_pos,
		[24,24],
		g_cross_spr,
		[0.0, 72/128],
		[0.1875, 0.1875],
		[1,1,1] * pSeatLocal->m_flDamageIndicator,
		1.0f,
		DRAWFLAG_ADDITIVE
	);*/

	pSeatLocal->m_flDamageIndicator -= clframetime;
}

void
HUD_TimeRemaining(void)
{
	vector iconPos = g_hudmins + [16, g_hudres[1] - 64];

	/* display time if timelimit is being hit */
	if (serverkeyfloat("timelimit")) {
		string tempstr = strcat("Time Remaining: ", Util_GetTime());
		Font_DrawText_RGB(iconPos, tempstr, g_hud_color, FONT_20);
	}
}

/* main entry */
void
HUD_Draw(void)
{
	player pl = (player)pSeat->m_ePlayer;

#ifndef TFC
	#ifndef GEARBOX
	g_hud_color = autocvar_con_color * (1 / 255);
	#else
	if (getplayerkeyfloat(pl.entnum-1, "*team") == 1)
		g_hud_color = [255, 150, 0] / 255;
	else if (getplayerkeyfloat(pl.entnum-1, "*team") == 2)
		g_hud_color = [0, 1, 0];
	else
		g_hud_color = autocvar_con_color * (1 / 255);
	#endif
#endif

	/* little point in not drawing these, even if you don't have a suit */
	Weapons_DrawCrosshair(pl);
	HUD_DrawDamageIndicator();
	HUD_DrawWeaponSelect();
	Obituary_Draw();
	Textmenu_Draw();

	HUD_TimeRemaining();

	if (!(pl.g_items & ITEM_SUIT)) {
		return;
	}

	HUD_DamageNotify_Draw();
	HUD_DrawHealth();
	HUD_DrawArmor();
	HUD_DrawFlashlight();
	HUD_DrawNotify();
	Damage_Draw();
}

/* specatator main entry */
void
HUD_DrawSpectator(void)
{
	Textmenu_Draw();

	NSClientSpectator spec = (NSClientSpectator)pSeat->m_ePlayer;

	drawfont = Font_GetID(FONT_20);
	vector vecPos = [0.0f, 0.0f, 0.0f];
	string strText = __NULL__;
	float palpha = 1.0f;

	if (spec.spec_mode == SPECMODE_FREE) {
		palpha = 0.5f;
	}

	strText = sprintf("Tracking: %s", getplayerkeyvalue(spec.spec_ent - 1, "name"));
	vecPos[0] = g_hudmins[0] + (g_hudres[0] / 2) - (stringwidth(strText, TRUE, [20,20]) / 2);
	vecPos[1] = g_hudmins[1] + g_hudres[1] - 60;
	drawstring(vecPos, strText, [20,20], [1,1,1], palpha, DRAWFLAG_ADDITIVE);

	strText = sprintf("Mode: %s", g_specmodes[spec.spec_mode]);
	vecPos[0] = g_hudmins[0] + (g_hudres[0] / 2) - (stringwidth(strText, TRUE, [20,20]) / 2);
	vecPos[1] = g_hudmins[1] + g_hudres[1] - 40;
	drawstring(vecPos, strText, [20,20], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);
}
