/*
 * Copyright (c) 2023-2025 Marco Cawthorne <marco@icculus.org>
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

#define HLHUD_SPRITES 61i
int g_spriteSheets[HLHUD_SPRITES];

typedef enum
{
S_AUTOAIM_C,
S_BUCKET0,
S_BUCKET1,
S_BUCKET2,
S_BUCKET3,
S_BUCKET4,
S_BUCKET5,
S_CROSS,
S_D_357,
S_D_9MMAR,
S_D_9MMHANDGUN,
S_D_BOLT,
S_D_CROSSBOW,
S_D_CROWBAR,
S_D_EGON,
S_D_GAUSS,
S_D_GRENADE,
S_D_HORNET,
S_D_RPG_ROCKET,
S_D_SATCHEL,
S_D_SHOTGUN,
S_D_SKULL,
S_D_SNARK,
S_D_TRACKTRAIN,
S_D_TRIPMINE,
S_DIVIDER,
S_DMG_BIO,
S_DMG_CHEM,
S_DMG_COLD,
S_DMG_DROWN,
S_DMG_GAS,
S_DMG_HEAT,
S_DMG_POISON,
S_DMG_RAD,
S_DMG_SHOCK,
S_FLASH_BEAM,
S_FLASH_EMPTY,
S_FLASH_FULL,
S_ITEM_BATTERY,
S_ITEM_HEALTHKIT,
S_ITEM_LONGJUMP,
S_NUMBER_0,
S_NUMBER_1,
S_NUMBER_2,
S_NUMBER_3,
S_NUMBER_4,
S_NUMBER_5,
S_NUMBER_6,
S_NUMBER_7,
S_NUMBER_8,
S_NUMBER_9,
S_SELECTION,
S_SUIT_EMPTY,
S_SUIT_FULL,
S_TITLE_HALF,
S_TITLE_LIFE,
S_TRAIN_BACK,
S_TRAIN_FORWARD1,
S_TRAIN_FORWARD2,
S_TRAIN_FORWARD3,
S_TRAIN_STOP
} hlSprites_t;

const string g_hlSpriteNames[HLHUD_SPRITES] =
{
"autoaim_c",
"bucket0",
"bucket1",
"bucket2",
"bucket3",
"bucket4",
"bucket5",
"cross",
"d_357",
"d_9mmAR",
"d_9mmhandgun",
"d_bolt",
"d_crossbow",
"d_crowbar",
"d_egon",
"d_gauss",
"d_grenade",
"d_hornet",
"d_rpg_rocket",
"d_satchel",
"d_shotgun",
"d_skull",
"d_snark",
"d_tracktrain",
"d_tripmine",
"divider",
"dmg_bio",
"dmg_chem",
"dmg_cold",
"dmg_drown",
"dmg_gas",
"dmg_heat",
"dmg_poison",
"dmg_rad",
"dmg_shock",
"flash_beam",
"flash_empty",
"flash_full",
"item_battery",
"item_healthkit",
"item_longjump",
"number_0",
"number_1",
"number_2",
"number_3",
"number_4",
"number_5",
"number_6",
"number_7",
"number_8",
"number_9",
"selection",
"suit_empty",
"suit_full",
"title_half",
"title_life",
"train_back",
"train_forward1",
"train_forward2",
"train_forward3",
"train_stop"
};

enumflags
{
	HUDCOUNTER_CHANGED_ORIGIN,
	HUDCOUNTER_CHANGED_IMAGE,
	HUDCOUNTER_CHANGED_MODELINDEX,
	HUDCOUNTER_CHANGED_TEXT,
	HUDCOUNTER_CHANGED_STATE,
	HUDCOUNTER_CHANGED_COUNTER,
	HUDCOUNTER_CHANGED_POSITION,
	HUDCOUNTER_CHANGED_RGBA,
};

void
hlHUDCounter::hlHUDCounter(void)
{
	m_strIcon =
	m_strText = __NULL__;
	m_bEnabled = true;
	m_bAdditive = false;
	m_vecPosXY = [0.0f, 0.0f, 0.0f];
	colormod = [255, 255, 255];

#ifdef SERVER
	m_teamScore = 0i;
#endif
}

#ifdef SERVER
void
hlHUDCounter::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "image":
		m_strIcon = ReadString(strValue);
		break;
	case "text":
		m_strText = ReadString(strValue);
		break;
	case "additive":
		m_bAdditive = ReadBool(strValue);
		break;
	case "x":
		m_vecPosXY[0] = ReadFloat(strValue);
		break;
	case "y":
		m_vecPosXY[1] = ReadFloat(strValue);
		break;
	case "rendercolor":
		colormod = ReadVector(strValue);
		break;
	case "teamscore":
		m_teamScore = ReadInt(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
hlHUDCounter::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_strIcon", m_strIcon);
	SaveString(handle, "m_strText", m_strText);
	SaveBool(handle, "m_bEnabled", m_bEnabled);
	SaveBool(handle, "m_bAdditive", m_bAdditive);
	SaveInt(handle, "m_counterValue", m_counterValue);
	SaveVector(handle, "m_vecPosXY", m_vecPosXY);
}

void
hlHUDCounter::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_strIcon":
		m_strIcon = ReadString(strValue);
		break;
	case "m_strText":
		m_strText = ReadString(strValue);
		break;
	case "m_bAdditive":
		m_bAdditive = ReadBool(strValue);
		break;
	case "m_bEnabled":
		m_bEnabled = ReadBool(strValue);
		break;
	case "m_counterValue":
		m_counterValue = ReadInt(strValue);
		break;
	case "m_vecPosXY":
		m_vecPosXY = ReadVector(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
hlHUDCounter::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		m_bEnabled = false;
		break;
	case TRIG_ON:
		m_bEnabled = true;
		break;
	default:
		m_bEnabled = m_bEnabled ? false : true;
	}
}

void
hlHUDCounter::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Enable":
		Trigger(eAct, TRIG_ON);
		break;
	case "Disable":
		Trigger(eAct, TRIG_OFF);
		break;
	case "Toggle":
		Trigger(eAct, TRIG_TOGGLE);
		break;
	case "SetValue":
		m_counterValue = ReadInt(strData);
		SetModel(GetSpawnString("model"));
		break;
	case "Increment":
		m_counterValue += ReadInt(strData);
		break;
	case "Decrement":
		m_counterValue -= ReadInt(strData);
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}

void
hlHUDCounter::EvaluateEntity(void)
{
	if (m_teamScore >= 1i) {
		m_counterValue = teams.Score(m_teamScore);
	}

	EVALUATE_VECTOR(origin, 0, HUDCOUNTER_CHANGED_ORIGIN)
	EVALUATE_VECTOR(origin, 1, HUDCOUNTER_CHANGED_ORIGIN)
	EVALUATE_VECTOR(origin, 2, HUDCOUNTER_CHANGED_ORIGIN)
	EVALUATE_FIELD(modelindex, HUDCOUNTER_CHANGED_MODELINDEX)
	EVALUATE_FIELD(m_bAdditive, HUDCOUNTER_CHANGED_MODELINDEX)
	EVALUATE_FIELD(m_strIcon, HUDCOUNTER_CHANGED_IMAGE)
	EVALUATE_FIELD(m_strText, HUDCOUNTER_CHANGED_TEXT)
	EVALUATE_FIELD(m_bEnabled, HUDCOUNTER_CHANGED_STATE)
	EVALUATE_FIELD(m_counterValue, HUDCOUNTER_CHANGED_COUNTER)
	EVALUATE_FIELD(m_vecPosXY, HUDCOUNTER_CHANGED_POSITION)
	EVALUATE_FIELD(colormod, HUDCOUNTER_CHANGED_RGBA)

	pvsflags = PVSF_IGNOREPVS;
}

float
hlHUDCounter::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_HLHUDCOUNTER);
	WriteFloat(MSG_ENTITY, flChanged);
	SENDENTITY_COORD(origin[0], HUDCOUNTER_CHANGED_ORIGIN)
	SENDENTITY_COORD(origin[1], HUDCOUNTER_CHANGED_ORIGIN)
	SENDENTITY_COORD(origin[2], HUDCOUNTER_CHANGED_ORIGIN)
	SENDENTITY_FLOAT(modelindex, HUDCOUNTER_CHANGED_MODELINDEX)
	SENDENTITY_FLOAT(m_bAdditive, HUDCOUNTER_CHANGED_MODELINDEX)
	SENDENTITY_STRING(m_strIcon, HUDCOUNTER_CHANGED_IMAGE)
	SENDENTITY_STRING(m_strText, HUDCOUNTER_CHANGED_TEXT)
	SENDENTITY_BYTE(m_bEnabled, HUDCOUNTER_CHANGED_STATE)
	SENDENTITY_INT(m_counterValue, HUDCOUNTER_CHANGED_COUNTER)
	SENDENTITY_FLOAT(m_vecPosXY[0], HUDCOUNTER_CHANGED_POSITION)
	SENDENTITY_FLOAT(m_vecPosXY[1], HUDCOUNTER_CHANGED_POSITION)
	SENDENTITY_BYTE(colormod[0], HUDCOUNTER_CHANGED_RGBA)
	SENDENTITY_BYTE(colormod[1], HUDCOUNTER_CHANGED_RGBA)
	SENDENTITY_BYTE(colormod[2], HUDCOUNTER_CHANGED_RGBA)
	return true;
}
#endif

#ifdef CLIENT
void
hlHUDCounter::ReloadVideoResources(void)
{
	m_strIcon = spriteframe(modelnameforindex(modelindex), 0, 0.0f);
}

void
hlHUDCounter::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], HUDCOUNTER_CHANGED_ORIGIN)
	READENTITY_COORD(origin[1], HUDCOUNTER_CHANGED_ORIGIN)
	READENTITY_COORD(origin[2], HUDCOUNTER_CHANGED_ORIGIN)
	READENTITY_FLOAT(modelindex, HUDCOUNTER_CHANGED_MODELINDEX)
	READENTITY_FLOAT(m_bAdditive, HUDCOUNTER_CHANGED_MODELINDEX)
	READENTITY_STRING(m_strIcon, HUDCOUNTER_CHANGED_IMAGE)
	READENTITY_STRING(m_strText, HUDCOUNTER_CHANGED_TEXT)
	READENTITY_BYTE(m_bEnabled, HUDCOUNTER_CHANGED_STATE)
	READENTITY_INT(m_counterValue, HUDCOUNTER_CHANGED_COUNTER)
	READENTITY_FLOAT(m_vecPosXY[0], HUDCOUNTER_CHANGED_POSITION)
	READENTITY_FLOAT(m_vecPosXY[1], HUDCOUNTER_CHANGED_POSITION)
	READENTITY_BYTE(colormod[0], HUDCOUNTER_CHANGED_RGBA)
	READENTITY_BYTE(colormod[1], HUDCOUNTER_CHANGED_RGBA)
	READENTITY_BYTE(colormod[2], HUDCOUNTER_CHANGED_RGBA)
	setorigin(this, origin);

	if (modelindex) {
		m_strIcon = spriteframe(modelnameforindex(modelindex), 0, 0.0f);
	}
}

void
HLHUD_DrawNumber(int iNumber, vector vecPos, float fAlpha, vector vColor)
{
	atlasPic.Draw_RGBA(
		atlasPic.Load(g_hlSpriteNames[S_NUMBER_0 + iNumber]),
		vecPos,
		vColor * fAlpha,
		1.0,
		true
	);
}

void
HLHUD_DrawNums(float fNumber, vector vecPos, float fAlpha, vector vColor)
{
	int iNumber = fNumber;
	if (iNumber > 0) {
		while (iNumber > 0) {
			HLHUD_DrawNumber((float)iNumber % 10, vecPos, fAlpha, vColor);
			iNumber = iNumber / 10;
			vecPos[0] -= 20;
		} 
	} else {
		HLHUD_DrawNumber(0, vecPos, fAlpha, vColor);
	}
}

void
hlHUDCounter::postdraw(void)
{
	if (!m_bEnabled) {
		return;
	}

	float textLength = Font_StringWidth(m_strText, true, FONT_CON);
	vector vecProj = g_vec_null;
	vector projectedPos = g_vec_null;
	float a = 1.0f;

	if (m_vecPosXY[0] == -1) {
		vecProj[0] = g_hudmins[0] + (g_hudres[0] / 2) - 32;
	} else {
		vecProj[0] = g_hudmins[0] + ((g_hudres[0] - 64) * m_vecPosXY[0]);
	}

	if (m_vecPosXY[1] == -1) {
		vecProj[1] = g_hudmins[1] + (g_hudres[1] / 2) - 32;
	} else {
		vecProj[1] = g_hudmins[1] + ((g_hudres[1] - 64) * m_vecPosXY[1]);
	}

	if (modelindex) {
		if (!m_bAdditive) {
			drawpic(vecProj, m_strIcon, [64, 64], [1,1,1], a, DRAWFLAG_NORMAL);
		} else {
			drawpic(vecProj, m_strIcon, [64, 64], [1,1,1], a, DRAWFLAG_ADDITIVE);
		}
	} /* else if (STRING_SET(m_strIcon)) {
		ncInterfaceSpriteSheet::Draw_RGBA(m_strIcon, vecProj, colormod / 255, a, m_bAdditive);
	} */

	/* counter */
	projectedPos = vecProj + [80, 20];
	HLHUD_DrawNums((float)m_counterValue, projectedPos, a, colormod / 255);
}
#endif
