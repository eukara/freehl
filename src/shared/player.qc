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

/* all potential SendFlags bits we can possibly send */
enumflags
{
	PLAYER_KEEPALIVE,
	PLAYER_MODELINDEX,
	PLAYER_ORIGIN,
	PLAYER_ORIGIN_Z,
	PLAYER_ANGLES_X,
	PLAYER_ANGLES_Y,
	PLAYER_COLORMAP,
	PLAYER_VELOCITY,
	PLAYER_VELOCITY_Z,
	PLAYER_FLAGS,
	PLAYER_WEAPON,
	PLAYER_ITEMS,
	PLAYER_HEALTH,
	PLAYER_ARMOR,
	PLAYER_MOVETYPE,
	PLAYER_VIEWOFS,
	PLAYER_TOPFRAME,
	PLAYER_BOTTOMFRAME,
	PLAYER_AMMO1,
	PLAYER_AMMO2,
	PLAYER_AMMO3,
	PLAYER_UNUSED1,
	PLAYER_UNUSED2
};

class player:NSClientPlayer
{
	void(void) player;

	/* animation */
	PREDICTED_INT(anim_top);
	PREDICTED_FLOAT(anim_top_time);
	PREDICTED_FLOAT(anim_top_delay);
	PREDICTED_INT(anim_bottom);
	PREDICTED_FLOAT(anim_bottom_time);

	/* ammo 1 */
	PREDICTED_INT(glock_mag);
	PREDICTED_INT(mp5_mag);
	PREDICTED_INT(python_mag);
	PREDICTED_INT(shotgun_mag);
	PREDICTED_INT(crossbow_mag);
	PREDICTED_INT(rpg_mag);
	PREDICTED_INT(satchel_chg);

	/* ammo 2 */
	PREDICTED_INT(ammo_9mm);
	PREDICTED_INT(ammo_357);
	PREDICTED_INT(ammo_buckshot);
	PREDICTED_INT(ammo_bolt);
	PREDICTED_INT(ammo_rocket);
	PREDICTED_INT(ammo_uranium);
	PREDICTED_INT(ammo_handgrenade);
	PREDICTED_INT(ammo_satchel);
	PREDICTED_INT(ammo_tripmine);
	PREDICTED_INT(ammo_snark);
	PREDICTED_INT(ammo_hornet);

	/* ammo 3 */
	PREDICTED_INT(ammo_m203_grenade);
	PREDICTED_INT(ammo_gauss_volume);
	PREDICTED_INT(ammo_rpg_state);
	PREDICTED_INT(mode_tempstate);

	virtual void(void) Physics_Jump;
	virtual void(void) Physics_WaterMove;

#ifdef CLIENT
	virtual void(void) draw;
	virtual float() predraw;
	virtual void(void) postdraw;
	virtual void(float,float) ReceiveEntity;
	virtual void(void) PredictPreFrame;
	virtual void(void) PredictPostFrame;
#else
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
	virtual void(float) Save;
	virtual void(string,string) Restore;
#endif
};

#ifdef CLIENT
void Weapons_AmmoUpdate(entity);
void HUD_AmmoNotify_Check(player pl);
void HUD_ItemNotify_Check(player pl);
/*
=================
player::ReceiveEntity
=================
*/
void
player::ReceiveEntity(float new, float fl)
{
	/* the generic client attributes */
	NSClientPlayer::ReceiveEntity(new, fl);

	/* animation */
	if (fl & PLAYER_TOPFRAME) {
		anim_top = readbyte();
		anim_top_time = readfloat();
		anim_top_delay = readfloat();
	}
	if (fl & PLAYER_BOTTOMFRAME) {
		anim_bottom = readbyte();
		anim_bottom_time = readfloat();
	}

	if (fl & PLAYER_AMMO1) {
		glock_mag = readbyte();
		mp5_mag = readbyte();
		python_mag = readbyte();
		shotgun_mag = readbyte();
		crossbow_mag = readbyte();
		rpg_mag = readbyte();
		satchel_chg = readbyte();
	}
	
	if (fl & PLAYER_AMMO2) {
		ammo_9mm = readbyte();
		ammo_357 = readbyte();
		ammo_buckshot = readbyte();
		ammo_bolt = readbyte();
		ammo_rocket = readbyte();
		ammo_uranium = readbyte();
		ammo_handgrenade = readbyte();
		ammo_satchel = readbyte();
		ammo_tripmine = readbyte();
		ammo_snark = readbyte();
		ammo_hornet = readbyte();
	}

	if (fl & PLAYER_AMMO3) {
		ammo_m203_grenade = readbyte();
		ammo_gauss_volume = readbyte();
		ammo_rpg_state = readbyte();
		mode_tempstate = readbyte();
	}

	setorigin(this, origin);

	/* these only concern the current player */
	CSQC_UpdateSeat();
	if (this != pSeat->m_ePlayer)
		return;

	/* do not notify us of updates when spawning initially */
	if (fl == UPDATE_ALL)
		PredictPreFrame();

	if (fl & PLAYER_AMMO1 || fl & PLAYER_AMMO2 || fl & PLAYER_AMMO3) {
		Weapons_AmmoUpdate(this);
		HUD_AmmoNotify_Check(this);
	}

	if (fl & PLAYER_ITEMS || fl & PLAYER_HEALTH || fl & PLAYER_ARMOR)
		HUD_ItemNotify_Check(this);
}

/*
=================
player::PredictPostFrame

Save the last valid server values away in the _net variants of each field
so we can roll them back later.
=================
*/
void
player::PredictPreFrame(void)
{
	/* the generic client attributes */
	NSClientPlayer::PredictPreFrame();

	SAVE_STATE(anim_top);
	SAVE_STATE(anim_top_delay);
	SAVE_STATE(anim_top_time);
	SAVE_STATE(anim_bottom);
	SAVE_STATE(anim_bottom_time);

	SAVE_STATE(glock_mag);
	SAVE_STATE(mp5_mag);
	SAVE_STATE(python_mag);
	SAVE_STATE(shotgun_mag);
	SAVE_STATE(crossbow_mag);
	SAVE_STATE(rpg_mag);
	SAVE_STATE(satchel_chg);

	SAVE_STATE(ammo_9mm);
	SAVE_STATE(ammo_357);
	SAVE_STATE(ammo_buckshot);
	SAVE_STATE(ammo_bolt);
	SAVE_STATE(ammo_rocket);
	SAVE_STATE(ammo_uranium);
	SAVE_STATE(ammo_handgrenade);
	SAVE_STATE(ammo_satchel);
	SAVE_STATE(ammo_tripmine);
	SAVE_STATE(ammo_snark);
	SAVE_STATE(ammo_hornet);

	SAVE_STATE(ammo_m203_grenade);
	SAVE_STATE(ammo_gauss_volume);
	SAVE_STATE(ammo_rpg_state);
	SAVE_STATE(mode_tempstate);
}

/*
=================
player::PredictPostFrame

Where we roll back our values to the ones last sent/verified by the server.
=================
*/
void
player::PredictPostFrame(void)
{
	/* the generic client attributes */
	NSClientPlayer::PredictPostFrame();

	ROLL_BACK(anim_top);
	ROLL_BACK(anim_top_delay);
	ROLL_BACK(anim_top_time);
	ROLL_BACK(anim_bottom);
	ROLL_BACK(anim_bottom_time);

	ROLL_BACK(glock_mag);
	ROLL_BACK(mp5_mag);
	ROLL_BACK(python_mag);
	ROLL_BACK(shotgun_mag);
	ROLL_BACK(crossbow_mag);
	ROLL_BACK(rpg_mag);
	ROLL_BACK(satchel_chg);

	ROLL_BACK(ammo_9mm);
	ROLL_BACK(ammo_357);
	ROLL_BACK(ammo_buckshot);
	ROLL_BACK(ammo_m203_grenade);
	ROLL_BACK(ammo_bolt);
	ROLL_BACK(ammo_rocket);
	ROLL_BACK(ammo_uranium);
	ROLL_BACK(ammo_handgrenade);
	ROLL_BACK(ammo_satchel);
	ROLL_BACK(ammo_tripmine);
	ROLL_BACK(ammo_snark);
	ROLL_BACK(ammo_hornet);

	ROLL_BACK(ammo_m203_grenade);
	ROLL_BACK(ammo_gauss_volume);
	ROLL_BACK(ammo_rpg_state);
	ROLL_BACK(mode_tempstate);
}

#else
void
player::Save(float handle)
{
	SaveInt(handle, "anim_top", anim_top);
	SaveFloat(handle, "anim_top_time", anim_top_time);
	SaveFloat(handle, "anim_top_delay", anim_top_delay);
	SaveInt(handle, "anim_bottom", anim_bottom);
	SaveFloat(handle, "anim_bottom_time", anim_bottom_time);

	/* ammo 1 */
	SaveInt(handle, "glock_mag", glock_mag);
	SaveInt(handle, "mp5_mag", mp5_mag);
	SaveInt(handle, "python_mag", python_mag);
	SaveInt(handle, "shotgun_mag", shotgun_mag);
	SaveInt(handle, "crossbow_mag", crossbow_mag);
	SaveInt(handle, "rpg_mag", rpg_mag);
	SaveInt(handle, "satchel_chg", satchel_chg);

	/* ammo 2 */
	SaveInt(handle, "ammo_9mm", ammo_9mm);
	SaveInt(handle, "ammo_357", ammo_357);
	SaveInt(handle, "ammo_buckshot", ammo_buckshot);
	SaveInt(handle, "ammo_bolt", ammo_bolt);
	SaveInt(handle, "ammo_rocket", ammo_rocket);
	SaveInt(handle, "ammo_uranium", ammo_uranium);
	SaveInt(handle, "ammo_handgrenade", ammo_handgrenade);
	SaveInt(handle, "ammo_satchel", ammo_satchel);
	SaveInt(handle, "ammo_tripmine", ammo_tripmine);
	SaveInt(handle, "ammo_snark", ammo_snark);
	SaveInt(handle, "ammo_hornet", ammo_hornet);

	/* ammo 3 */
	SaveInt(handle, "ammo_m203_grenade", ammo_m203_grenade);
	SaveInt(handle, "ammo_gauss_volume", ammo_gauss_volume);
	SaveInt(handle, "ammo_rpg_state", ammo_rpg_state);
	SaveInt(handle, "mode_tempstate", mode_tempstate);

	super::Save(handle);
}

void
player::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "anim_top":
		anim_top = ReadInt(strValue);
		break;
	case "anim_top_time":
		anim_top_time = ReadFloat(strValue);
		break;
	case "anim_top_delay":
		anim_top_delay = ReadFloat(strValue);
		break;
	case "anim_bottom":
		anim_bottom = ReadInt(strValue);
		break;
	case "anim_bottom_time":
		anim_bottom_time = ReadFloat(strValue);
		break;
	/* AMMO 1 */
	case "glock_mag":
		glock_mag = ReadInt(strValue);
		break;
	case "mp5_mag":
		mp5_mag = ReadInt(strValue);
		break;
	case "python_mag":
		python_mag = ReadInt(strValue);
		break;
	case "shotgun_mag":
		shotgun_mag = ReadInt(strValue);
		break;
	case "crossbow_mag":
		crossbow_mag = ReadInt(strValue);
		break;
	case "rpg_mag":
		rpg_mag = ReadInt(strValue);
		break;
	case "satchel_chg":
		satchel_chg = ReadInt(strValue);
		break;
	/* AMMO 2 */
	case "ammo_9mm":
		ammo_9mm = ReadInt(strValue);
		break;
	case "ammo_357":
		ammo_357 = ReadInt(strValue);
		break;
	case "ammo_buckshot":
		ammo_buckshot = ReadInt(strValue);
		break;
	case "ammo_bolt":
		ammo_bolt = ReadInt(strValue);
		break;
	case "ammo_rocket":
		ammo_rocket = ReadInt(strValue);
		break;
	case "ammo_uranium":
		ammo_uranium = ReadInt(strValue);
		break;
	case "ammo_handgrenade":
		ammo_handgrenade = ReadInt(strValue);
		break;
	case "ammo_satchel":
		ammo_satchel = ReadInt(strValue);
		break;
	case "ammo_tripmine":
		ammo_tripmine = ReadInt(strValue);
		break;
	case "ammo_snark":
		ammo_snark = ReadInt(strValue);
		break;
	case "ammo_hornet":
		ammo_hornet = ReadInt(strValue);
		break;
	/* AMMO 3 */
	case "ammo_m203_grenade":
		ammo_m203_grenade = ReadInt(strValue);
		break;
	case "ammo_gauss_volume":
		ammo_gauss_volume = ReadInt(strValue);
		break;
	case "ammo_rpg_state":
		ammo_rpg_state = ReadInt(strValue);
		break;
	case "mode_tempstate":
		mode_tempstate = ReadInt(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
player::EvaluateEntity(void)
{
	/* the generic client attributes */
	NSClientPlayer::EvaluateEntity();

	/* animation */
	if (ATTR_CHANGED(anim_bottom) || ATTR_CHANGED(anim_bottom_time))
		SendFlags |= PLAYER_BOTTOMFRAME;
	if (ATTR_CHANGED(anim_top) || ATTR_CHANGED(anim_top_time) || ATTR_CHANGED(anim_top_delay))
		SendFlags |= PLAYER_TOPFRAME;

	/* ammo 1 type updates */
	if (ATTR_CHANGED(glock_mag))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(mp5_mag))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(python_mag))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(shotgun_mag))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(crossbow_mag))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(rpg_mag))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(satchel_chg))
		SendFlags |= PLAYER_AMMO1;

	/* ammo 2 type updates */
	if (ATTR_CHANGED(ammo_9mm))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_357))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_buckshot))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_bolt))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_rocket))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_uranium))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_handgrenade))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_satchel))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_tripmine))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_snark))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_hornet))
		SendFlags |= PLAYER_AMMO2;

	if (ATTR_CHANGED(ammo_m203_grenade))
		SendFlags |= PLAYER_AMMO3;
	if (ATTR_CHANGED(ammo_gauss_volume))
		SendFlags |= PLAYER_AMMO3;
	if (ATTR_CHANGED(ammo_rpg_state))
		SendFlags |= PLAYER_AMMO3;
	if (ATTR_CHANGED(mode_tempstate))
		SendFlags |= PLAYER_AMMO3;

	SAVE_STATE(glock_mag);
	SAVE_STATE(mp5_mag);
	SAVE_STATE(python_mag);
	SAVE_STATE(shotgun_mag);
	SAVE_STATE(crossbow_mag);
	SAVE_STATE(rpg_mag);
	SAVE_STATE(satchel_chg);
	SAVE_STATE(ammo_9mm);
	SAVE_STATE(ammo_357);
	SAVE_STATE(ammo_buckshot);
	SAVE_STATE(ammo_bolt);
	SAVE_STATE(ammo_rocket);
	SAVE_STATE(ammo_uranium);
	SAVE_STATE(ammo_handgrenade);
	SAVE_STATE(ammo_satchel);
	SAVE_STATE(ammo_tripmine);
	SAVE_STATE(ammo_snark);
	SAVE_STATE(ammo_hornet);

	SAVE_STATE(ammo_m203_grenade);
	SAVE_STATE(ammo_gauss_volume);
	SAVE_STATE(ammo_rpg_state);
	SAVE_STATE(mode_tempstate);

	SAVE_STATE(anim_top);
	SAVE_STATE(anim_top_delay);
	SAVE_STATE(anim_top_time);
	SAVE_STATE(anim_bottom);
	SAVE_STATE(anim_bottom_time);
}

/*
=================
player::SendEntity
=================
*/
float
player::SendEntity(entity ePEnt, float fChanged)
{
	/* don't broadcast invisible players */
	if (IsFakeSpectator() && ePEnt != this)
		return (0);
	if (!GetModelindex() && ePEnt != this)
		return (0);

	/* other players don't need to know about these attributes */
	if (ePEnt != self && ePEnt.classname != "spectator") {
		fChanged &= ~PLAYER_ITEMS;
		fChanged &= ~PLAYER_HEALTH;
		fChanged &= ~PLAYER_ARMOR;
		fChanged &= ~PLAYER_VIEWOFS;
		fChanged &= ~PLAYER_AMMO1;
		fChanged &= ~PLAYER_AMMO2;
		fChanged &= ~PLAYER_AMMO3;
	}

	WriteByte(MSG_ENTITY, ENT_PLAYER);
	WriteFloat(MSG_ENTITY, fChanged);

	/* the generic client attributes */
	NSClientPlayer::SendEntity(ePEnt, fChanged);

	if (fChanged & PLAYER_TOPFRAME) {
		WriteByte(MSG_ENTITY, anim_top);
		WriteFloat(MSG_ENTITY, anim_top_time);
		WriteFloat(MSG_ENTITY, anim_top_delay);
	}
	if (fChanged & PLAYER_BOTTOMFRAME) {
		WriteByte(MSG_ENTITY, anim_bottom);
		WriteFloat(MSG_ENTITY, anim_bottom_time);
	}

	if (fChanged & PLAYER_AMMO1) {
		WriteByte(MSG_ENTITY, glock_mag);
		WriteByte(MSG_ENTITY, mp5_mag);
		WriteByte(MSG_ENTITY, python_mag);
		WriteByte(MSG_ENTITY, shotgun_mag);
		WriteByte(MSG_ENTITY, crossbow_mag);
		WriteByte(MSG_ENTITY, rpg_mag);
		WriteByte(MSG_ENTITY, satchel_chg);
	}

	if (fChanged & PLAYER_AMMO2) {
		WriteByte(MSG_ENTITY, ammo_9mm);
		WriteByte(MSG_ENTITY, ammo_357);
		WriteByte(MSG_ENTITY, ammo_buckshot);
		WriteByte(MSG_ENTITY, ammo_bolt);
		WriteByte(MSG_ENTITY, ammo_rocket);
		WriteByte(MSG_ENTITY, ammo_uranium);
		WriteByte(MSG_ENTITY, ammo_handgrenade);
		WriteByte(MSG_ENTITY, ammo_satchel);
		WriteByte(MSG_ENTITY, ammo_tripmine);
		WriteByte(MSG_ENTITY, ammo_snark);
		WriteByte(MSG_ENTITY, ammo_hornet);
	}

	if (fChanged & PLAYER_AMMO3) {
		WriteByte(MSG_ENTITY, ammo_m203_grenade);
		WriteByte(MSG_ENTITY, ammo_gauss_volume);
		WriteByte(MSG_ENTITY, ammo_rpg_state);
		WriteByte(MSG_ENTITY, mode_tempstate);
	}

	return (1);
}
#endif

void
player::player(void)
{
	print("foobar!!!!!\n");
}
