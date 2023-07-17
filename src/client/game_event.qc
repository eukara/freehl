/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

int
ClientGame_EventParse(float fHeader)
{
	switch (fHeader) {
	case EV_OBITUARY:
		Obituary_Parse();
		break;
	case EV_HITNOTIFY:
		pSeatLocal->m_flDamageIndicator = 1.0f;
		break;
	case EV_SPARK:
		vector vSparkPos, vSparkAngle;
		vSparkPos[0] = readcoord();
		vSparkPos[1] = readcoord();
		vSparkPos[2] = readcoord();
		vSparkAngle[0] = readcoord();
		vSparkAngle[1] = readcoord();
		vSparkAngle[2] = readcoord();
		FX_Spark(vSparkPos, vSparkAngle);
		break;
	case EV_BLOOD:
		vector vBloodPos = g_vec_null;
		vector vBloodColor = g_vec_null;

		vBloodPos[0] = readcoord();
		vBloodPos[1] = readcoord();
		vBloodPos[2] = readcoord();

		vBloodColor[0] = readbyte() / 255;
		vBloodColor[1] = readbyte() / 255;
		vBloodColor[2] = readbyte() / 255;

		FX_Blood(vBloodPos, vBloodColor);
		break;
	case EV_EXPLOSION:
		vector vExploPos = g_vec_null;

		vExploPos[0] = readcoord();
		vExploPos[1] = readcoord();
		vExploPos[2] = readcoord();

		FX_Explosion(vExploPos);
		break;
	case EV_MODELGIB:
		vector vecPos = g_vec_null;
		vecPos[0] = readcoord();
		vecPos[1] = readcoord();
		vecPos[2] = readcoord();

		vector vSize = g_vec_null;
		vSize[0] = readcoord();
		vSize[1] = readcoord();
		vSize[2] = readcoord();

		float fStyle = readbyte();
		int count = readbyte();
		FX_BreakModel(count, vecPos, vSize, [0,0,0], fStyle);
		break;
	case EV_IMPACT:
		int iType;
		vector vOrigin, vNormal;

		iType = (int)readbyte();
		vOrigin[0] = readcoord();
		vOrigin[1] = readcoord();
		vOrigin[2] = readcoord();

		vNormal[0] = readcoord();
		vNormal[1] = readcoord();
		vNormal[2] = readcoord();

		FX_Impact(iType, vOrigin, vNormal);
		break;
	case EV_GAUSSBEAM:
		FX_GaussBeam_Parse();
		break;
	case EV_CHAT:
		float fSender = readbyte();
		float fTeam = readbyte();
		string sMessage = readstring();

		CSQC_Parse_Print(sprintf("%s: %s", getplayerkeyvalue(fSender, "name"), sMessage), PRINT_CHAT);
		break;
	case EV_CHAT_TEAM:
		float fSender2 = readbyte();
		float fTeam2 = readbyte();
		string sMessage2 = readstring();

		CSQC_Parse_Print(sprintf("[TEAM] %s: %s", getplayerkeyvalue(fSender2, "name"), sMessage2), PRINT_CHAT);
		break;
	case EV_VIEWMODEL:
		View_PlayAnimation(readbyte());
		break;
	case EV_WEAPON_PICKUP:
		int w = readbyte();

		if (autocvar_cl_autoweaponswitch == 1) {
			sendevent("PlayerSwitchWeapon", "i", w);
		}

		HUD_WeaponPickupNotify(w);
		break;
	default:
		return (0);
	}

	return (1);
}
