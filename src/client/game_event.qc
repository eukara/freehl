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
	case EV_GAUSSBEAM:
		FX_GaussBeam_Parse();
		break;
	case EV_CHAT:
		float fSender = readbyte();
		float fTeam = readbyte();
		string sMessage = readstring();

		CSQC_Parse_Print(Util_ChatFormat(fSender, 0, sMessage), PRINT_CHAT);
		break;
	case EV_CHAT_TEAM:
		float fSender2 = readbyte();
		float fTeam2 = readbyte();
		string sMessage2 = readstring();

		CSQC_Parse_Print(Util_ChatFormat(fSender2, fTeam2, sMessage2), PRINT_CHAT);
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
