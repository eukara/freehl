/*
 * Copyright (c) 2023 Vera Visions LLC.
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
hlHUDCounter::postdraw(void)
{
	if (!m_bEnabled)
		return;

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
			drawpic(vecProj, m_strIcon, [64, 64], [1,1,1], a);
		} else {
			drawpic(vecProj, m_strIcon, [64, 64], [1,1,1], a, DRAWFLAG_ADDITIVE);
		}
	} else {
		HLSprite_Draw_RGBA(m_strIcon, vecProj, colormod / 255, a, m_bAdditive);
	}

	/* counter */
	projectedPos = vecProj + [64, 12];
	//HUD_DrawNums((float)m_counterValue, projectedPos, 1.0, colormod / 255);
}
#endif
