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

#include "obituary.h"
#include "particles.h"

var int autocvar_cl_autoweaponswitch = TRUE;

vector g_hud_color;
vector g_hudmins;
vector g_hudres;

var string g_hud1_spr;
var string g_hud2_spr;
var string g_hud3_spr;
var string g_hud4_spr;
var string g_hud5_spr;
var string g_hud6_spr;
var string g_hud7_spr;
var string g_cross_spr;
var string g_laser_spr;

struct
{
	/* viewmodel stuff */
	entity m_eViewModel;
	entity m_eMuzzleflash;
	int m_iVMBones;
	int m_iVMEjectBone;
	int m_iLastWeapon;
	int m_iOldWeapon;
	float m_flBobTime;
	float m_flBob;

	/* damage overlay */
	float m_flDamageAlpha;
	vector m_vecDamagePos;

	/* +zoomin cmd */
	int m_iZoomed;
	float m_flZoomTime;

	/* player fields */
	entity m_ePlayer;
	vector m_vecPredictedOrigin;
	vector m_vecPredictedOriginOld;
	vector m_vecPredictedVelocity;
	float m_flPredictedFlags;
	
	/* camera fields */
	vector m_vecCameraOrigin;
	vector m_vecCameraAngle;
	float m_flCameraTime;

	/* hud.c */
	int m_iHealthOld;
	float m_flHealthAlpha;
	int m_iArmorOld;
	float m_flArmorAlpha;
	int m_iAmmo1Old;
	float m_flAmmo1Alpha;
	int m_iAmmo2Old;
	float m_flAmmo2Alpha;
	int m_iAmmo3Old;
	float m_flAmmo3Alpha;
	int m_iPickupWeapon;
	float m_flPickupAlpha;

	/* This is seperated from the other VGUI stuff so we can check scores
	 * while buying and whatnot */
	int m_iScoresVisible;
	int m_iHUDWeaponSelected;
	float m_flHUDWeaponSelectTime;

	/* saturn controller */
	int m_iSaturnMenu;

	/* centerprint related */
	float m_flCenterprintAlpha;
	float m_flCenterprintTime;
	float m_iCenterprintLines;
	string m_strCenterprintBuffer[18];

	/* chat related */
	float m_flPrintTime;
	string m_strPrintBuffer[5];
	int m_iPrintLines;

	int m_iInputAttack2;
	int m_iInputReload;
	int m_iInputUse;
	int m_iInputDuck;
	float m_flInputBlockTime;
	
	/* fading */
	float m_flFadeDuration;
	float m_flFadeHold;
	float m_flFadeMaxAlpha;
	float m_flFadeStyle;
	float m_flFadeAlpha;
	float m_flFadeTime;
	vector m_vecFadeColor;
	int m_iFadeActive;

	/* shake */
	float m_flShakeFreq;
	float m_flShakeDuration;
	float m_flShakeTime;
	float m_flShakeAmp;

	entity m_pWeaponFX;
} g_seats[4], *pSeat;

void HUD_DrawAmmo1(void);
void HUD_DrawAmmo2(void);
void HUD_DrawAmmo3(void);
void HUD_DrawAmmoBar(vector pos, float val, float max, float a);
void HUD_WeaponPickupNotify(int);
