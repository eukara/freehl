/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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
			HUD_DrawNumber((float)i % 10, vecPos, fAlpha, vColor);
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

	if (pl.health != pSeat->m_iHealthOld) {
		pSeat->m_flHealthAlpha = 1.0;
	}

	if (pSeat->m_flHealthAlpha >= HUD_ALPHA) {
		pSeat->m_flHealthAlpha -= clframetime * 0.5;
	} else {
		pSeat->m_flHealthAlpha = HUD_ALPHA;
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
			pSeat->m_flHealthAlpha,
			DRAWFLAG_ADDITIVE
		);
		HUD_DrawNums(pl.health, pos, pSeat->m_flHealthAlpha, g_hud_color);
	} else {
		drawsubpic(
			pos + [-72,-4],
			[32,32],
			g_hud7_spr,
			[spr_health[0], spr_health[1]],
			[spr_health[2], spr_health[3]],
			[1,0,0],
			pSeat->m_flHealthAlpha,
			DRAWFLAG_ADDITIVE
		);
		HUD_DrawNums(pl.health, pos, pSeat->m_flHealthAlpha, [1,0,0]);
	}

	pSeat->m_iHealthOld = pl.health;
}

/* armor/suit charge */
void
HUD_DrawArmor(void)
{
	vector pos;
	player pl = (player)pSeat->m_ePlayer;

	pos = g_hudmins + [198, g_hudres[1] - 42];
	
	if (pl.armor != pSeat->m_iArmorOld) {
		pSeat->m_flArmorAlpha = 1.0;
	}

	if (pSeat->m_flArmorAlpha >= HUD_ALPHA) {
		pSeat->m_flArmorAlpha -= clframetime * 0.5;
	} else {
		pSeat->m_flArmorAlpha = HUD_ALPHA;
	}

	drawsubpic(
		pos + [-80,-9],
		[40,40],
		g_hud7_spr,
		[spr_suit2[0], spr_suit2[1]],
		[spr_suit2[2], spr_suit2[3]],
		g_hud_color,
		pSeat->m_flArmorAlpha,
		DRAWFLAG_ADDITIVE
	);

	if (pl.armor > 0) {
		drawsubpic(
			pos + [-80,-9],
			[40, 40 * (pl.armor / 100)],
			g_hud7_spr,
			[spr_suit1[0],
			spr_suit1[1]],
			[spr_suit1[2], spr_suit1[3] * (pl.armor / 100)],
			g_hud_color,
			pSeat->m_flArmorAlpha,
			DRAWFLAG_ADDITIVE
		);
	}

	HUD_DrawNums(pl.armor, pos, pSeat->m_flArmorAlpha, g_hud_color);
	pSeat->m_iArmorOld = pl.armor;
}

/* magazine/clip ammo */
void
HUD_DrawAmmo1(void)
{
	player pl = (player)pSeat->m_ePlayer;
	vector pos;

	if (pl.a_ammo1 != pSeat->m_iAmmo1Old) {
		pSeat->m_flAmmo1Alpha = 1.0;
		pSeat->m_iAmmo1Old = pl.a_ammo1;
	}

	if (pSeat->m_flAmmo1Alpha >= HUD_ALPHA) {
		pSeat->m_flAmmo1Alpha -= clframetime * 0.5;
	} else {
		pSeat->m_flAmmo1Alpha = HUD_ALPHA;
	}

	pos = g_hudmins + [g_hudres[0] - 152, g_hudres[1] - 42];
	HUD_DrawNums(pl.a_ammo1, pos, pSeat->m_flAmmo1Alpha, g_hud_color);
	HUD_DrawSeperator(pos + [30,0]);
}

/* leftover type ammo */
void
HUD_DrawAmmo2(void)
{
	player pl = (player)pSeat->m_ePlayer;
	vector pos;

	if (pl.a_ammo2 != pSeat->m_iAmmo2Old) {
		pSeat->m_flAmmo2Alpha = 1.0;
		pSeat->m_iAmmo2Old = pl.a_ammo2;
	}

	if (pSeat->m_flAmmo2Alpha >= HUD_ALPHA) {
		pSeat->m_flAmmo2Alpha -= clframetime * 0.5;
	} else {
		pSeat->m_flAmmo2Alpha = HUD_ALPHA;
	}

	pos = g_hudmins + [g_hudres[0] - 72, g_hudres[1] - 42];
	HUD_DrawNums(pl.a_ammo2, pos, pSeat->m_flAmmo2Alpha, g_hud_color);
}

/* special ammo */
void
HUD_DrawAmmo3(void)
{
	player pl = (player)pSeat->m_ePlayer;
	vector pos;

	if (pl.a_ammo3 != pSeat->m_iAmmo3Old) {
		pSeat->m_flAmmo3Alpha = 1.0;
		pSeat->m_iAmmo3Old = pl.a_ammo3;
	}

	if (pSeat->m_flAmmo3Alpha >= HUD_ALPHA) {
		pSeat->m_flAmmo3Alpha -= clframetime * 0.5;
	} else {
		pSeat->m_flAmmo3Alpha = HUD_ALPHA;
	}

	pos = g_hudmins + [g_hudres[0] - 72, g_hudres[1] - 74];
	HUD_DrawNums(pl.a_ammo3, pos, pSeat->m_flAmmo3Alpha, g_hud_color);
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
	vector pos;
	
	if (pSeat->m_flPickupAlpha <= 0.0f) {
		return;
	}

	pos = g_hudmins + [g_hudres[0] - 192, g_hudres[1] - 128];
	Weapons_HUDPic(pSeat->m_iPickupWeapon, 1, pos, pSeat->m_flPickupAlpha);
	pSeat->m_flPickupAlpha -= clframetime;
}

void
HUD_WeaponPickupNotify(int w)
{
	pSeat->m_iPickupWeapon = w;
	pSeat->m_flPickupAlpha = 1.0f;
}

/* main entry */
void
HUD_Draw(void)
{
	player pl = (player)pSeat->m_ePlayer;

	g_hud_color = autocvar_con_color * (1 / 255);

	/* little point in not drawing these, even if you don't have a suit */
	Weapons_DrawCrosshair();
	HUD_DrawWeaponSelect();
	Obituary_Draw();
	Textmenu_Draw();

	if (!(pl.g_items & ITEM_SUIT)) {
		return;
	}

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
	// FIXME
	Textmenu_Draw();
}
