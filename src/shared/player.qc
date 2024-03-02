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

#include "skeleton.h"

/* all custom SendFlags bits we can possibly send */
enumflags
{
	PLAYER_TOPFRAME = PLAYER_CUSTOMFIELDSTART,
	PLAYER_BOTTOMFRAME,
	PLAYER_AMMO1,
	PLAYER_AMMO2,
	PLAYER_AMMO3,
	PLAYER_UNUSED5,
	PLAYER_UNUSED6,
	PLAYER_UNUSED7
};

class player:NSClientPlayer
{
	void(void) player;

	/* animation */
	PREDICTED_INT(anim_top)
	PREDICTED_FLOAT(anim_top_time)
	PREDICTED_FLOAT(anim_top_delay)
	PREDICTED_INT(anim_bottom)
	PREDICTED_FLOAT(anim_bottom_time)

	/* ammo 1 */
	PREDICTED_INT(glock_mag)
	PREDICTED_INT(mp5_mag)
	PREDICTED_INT(python_mag)
	PREDICTED_INT(shotgun_mag)
	PREDICTED_INT(crossbow_mag)
	PREDICTED_INT(rpg_mag)
	PREDICTED_INT(satchel_chg)

	/* ammo 2 */
	PREDICTED_INT(ammo_9mm)
	PREDICTED_INT(ammo_357)
	PREDICTED_INT(ammo_buckshot)
	PREDICTED_INT(ammo_bolt)
	PREDICTED_INT(ammo_rocket)
	PREDICTED_INT(ammo_uranium)
	PREDICTED_INT(ammo_handgrenade)
	PREDICTED_INT(ammo_satchel)
	PREDICTED_INT(ammo_tripmine)
	PREDICTED_INT(ammo_snark)
	PREDICTED_INT(ammo_hornet)

	/* ammo 3 */
	PREDICTED_INT(ammo_m203_grenade)
	PREDICTED_INT(ammo_gauss_volume)
	PREDICTED_INT(ammo_rpg_state)
	PREDICTED_INT(mode_tempstate)

	virtual void Physics_Jump(void);
	virtual void UpdatePlayerAnimation(float);

#ifdef CLIENT
	virtual void UpdatePlayerAttachments(bool);
	virtual void ReceiveEntity(float,float);
	virtual void PredictPreFrame(void);
	virtual void PredictPostFrame(void);
	virtual void UpdateAliveCam(void);
#else
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity, float);
	virtual void Save(float);
	virtual void Restore(string,string);
#endif
};

void
player::player(void)
{
	anim_top = 0;
	anim_top_time = 0;
	anim_top_delay = 0;
	anim_bottom = 0;
	anim_bottom_time = 0;
	glock_mag = 0;
	mp5_mag = 0;
	python_mag = 0;
	shotgun_mag = 0;
	crossbow_mag = 0;
	rpg_mag = 0;
	satchel_chg = 0;
	ammo_9mm = 0;
	ammo_357 = 0;
	ammo_buckshot = 0;
	ammo_bolt = 0;
	ammo_rocket = 0;
	ammo_uranium = 0;
	ammo_handgrenade = 0;
	ammo_satchel = 0;
	ammo_tripmine = 0;
	ammo_snark = 0;
	ammo_hornet = 0;
	ammo_m203_grenade = 0;
	ammo_gauss_volume = 0;
	ammo_rpg_state = 0;
	mode_tempstate = 0;
}

void Animation_PlayerUpdate(player); 
void Animation_TimerUpdate(player, float); 

void
player::UpdatePlayerAnimation(float timelength)
{
	/* calculate our skeletal progression */
	Animation_PlayerUpdate(this);
	/* advance animation timers */
	Animation_TimerUpdate(this, timelength);
}

#ifdef CLIENT
void Camera_RunPosBob(vector angles, __inout vector camera_pos);
void Camera_StrafeRoll(__inout vector camera_angle);
void Shake_Update(NSClientPlayer);

void
player::UpdateAliveCam(void)
{
	vector cam_pos = GetEyePos();
	Camera_RunPosBob(view_angles, cam_pos);

	g_view.SetCameraOrigin(cam_pos);
	Camera_StrafeRoll(view_angles);
	g_view.SetCameraAngle(view_angles);

	if (vehicle) {
		NSVehicle veh = (NSVehicle)vehicle;

		if (veh.UpdateView)
			veh.UpdateView();
	} else if (health) {
		if (autocvar_pm_thirdPerson == TRUE) {
			makevectors(view_angles);
			vector vStart = [pSeat->m_vecPredictedOrigin[0], pSeat->m_vecPredictedOrigin[1], pSeat->m_vecPredictedOrigin[2] + 16] + (v_right * 4);
			vector vEnd = vStart + (v_forward * -48) + [0,0,16] + (v_right * 4);
			traceline(vStart, vEnd, FALSE, this);
			g_view.SetCameraOrigin(trace_endpos + (v_forward * 5));
		}
	}

	Shake_Update(this);
	g_view.AddPunchAngle(punchangle);
}

.string oldmodel;
string Weapons_GetPlayermodel(player, int);

void
player::UpdatePlayerAttachments(bool visible)
{
	/* draw the flashlight */
	if (gflags & GF_FLASHLIGHT) {
		vector src;
		vector ang;
		
		if (entnum != player_localentnum) {
			src = origin + view_ofs;
			ang = v_angle;
		} else {
			src = pSeat->m_vecPredictedOrigin + view_ofs;
			ang = view_angles;
		}

		makevectors(ang);
		traceline(src, src + (v_forward * 8096), MOVE_NORMAL, this);

		if (serverkeyfloat("*bspversion") == BSPVER_HL) {
			dynamiclight_add(trace_endpos + (trace_plane_normal * 4), 128, [1,1,1]);
		} else {
			float p = dynamiclight_add(src, 512, [1,1,1], 0, "textures/flashlight");
			dynamiclight_set(p, LFIELD_ANGLES, ang);
			dynamiclight_set(p, LFIELD_FLAGS, 3);
		}
	}

	/* FIXME: this needs to be incorporated and simplified, now that we can handle it all in-class */
	if (!visible)
		return;

	/* what's the current weapon model supposed to be anyway? */
	p_model.oldmodel = Weapons_GetPlayermodel(this, activeweapon);

	/* we changed weapons, update skeletonindex */
	if (p_model.model != p_model.oldmodel) {
		/* free memory */
		if (p_model.skeletonindex)
			skel_delete(p_model.skeletonindex);

		/* set the new model and mark us updated */
		setmodel(p_model, p_model.oldmodel);
		p_model.model = p_model.oldmodel;
		
		/* set the new skeletonindex */
		p_model.skeletonindex = skel_create(p_model.modelindex);

		/* hack this thing in here FIXME: this should be done when popping in/out of a pvs */
		if (autocvar(cl_himodels, 1, "Use high-quality thisayer models over lower-definition ones"))
			setcustomskin(this, "", "geomset 0 2\n");
		else
			setcustomskin(this, "", "geomset 0 1\n");
	}

	/* follow thisayer at all times */
	setorigin(p_model, origin);
	p_model.angles = angles;
	skel_build(p_model.skeletonindex, p_model, p_model.modelindex,0, 0, -1);

	/* we have to loop through all valid bones of the weapon model and match them
	 * to the thisayer one */
	for (float i = 0; i < g_pbones.length; i++) {
		vector bpos;
		float pbone = gettagindex(this, g_pbones[i]);
		float wbone = gettagindex(p_model, g_pbones[i]);

		/* if the bone doesn't ignore in either skeletal mesh, ignore */
		if (wbone <= 0 || pbone <= 0)
			continue;

		bpos = gettaginfo(this, pbone);
		
		/* the most expensive bit */
		skel_set_bone_world(p_model, wbone, bpos, v_forward, v_right, v_up);
	}
}

void Weapons_AmmoUpdate(entity);
void HUD_AmmoNotify_Check(player pl);
void HUD_ItemNotify_Check(player pl);
/*
=================
player::ReceiveEntity
=================
*/
void
player::ReceiveEntity(float new, float flChanged)
{
	/* the generic client attributes */
	NSClientPlayer::ReceiveEntity(new, flChanged);

	/* animation */
	READENTITY_BYTE(anim_top, PLAYER_TOPFRAME)
	READENTITY_FLOAT(anim_top_time, PLAYER_TOPFRAME)
	READENTITY_FLOAT(anim_top_delay, PLAYER_TOPFRAME)
	READENTITY_BYTE(anim_bottom, PLAYER_BOTTOMFRAME)
	READENTITY_FLOAT(anim_bottom_time, PLAYER_BOTTOMFRAME)

	READENTITY_BYTE(glock_mag, PLAYER_AMMO1)
	READENTITY_BYTE(mp5_mag, PLAYER_AMMO1)
	READENTITY_BYTE(python_mag, PLAYER_AMMO1)
	READENTITY_BYTE(shotgun_mag, PLAYER_AMMO1)
	READENTITY_BYTE(crossbow_mag, PLAYER_AMMO1)
	READENTITY_BYTE(rpg_mag, PLAYER_AMMO1)
	READENTITY_BYTE(satchel_chg, PLAYER_AMMO1)

	READENTITY_BYTE(ammo_9mm, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_357, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_buckshot, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_bolt, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_rocket, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_uranium, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_handgrenade, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_satchel, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_tripmine, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_snark, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_hornet, PLAYER_AMMO2)

	READENTITY_BYTE(ammo_m203_grenade, PLAYER_AMMO3)
	READENTITY_BYTE(ammo_gauss_volume, PLAYER_AMMO3)
	READENTITY_BYTE(ammo_rpg_state, PLAYER_AMMO3)
	READENTITY_BYTE(mode_tempstate, PLAYER_AMMO3)

	setorigin(this, origin);

	/* these only concern the current player */
	CSQC_UpdateSeat();
	if (this != pSeat->m_ePlayer)
		return;

	/* do not notify us of updates when spawning initially */
	if (flChanged == UPDATE_ALL)
		PredictPreFrame();

	if (flChanged & PLAYER_AMMO1 || flChanged & PLAYER_AMMO2 || flChanged & PLAYER_AMMO3) {
		Weapons_AmmoUpdate(this);
		HUD_AmmoNotify_Check(this);
	}

	if (flChanged & PLAYER_ITEMS || flChanged & PLAYER_HEALTH)
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

	SAVE_STATE(anim_top)
	SAVE_STATE(anim_top_delay)
	SAVE_STATE(anim_top_time)
	SAVE_STATE(anim_bottom)
	SAVE_STATE(anim_bottom_time)

	SAVE_STATE(glock_mag)
	SAVE_STATE(mp5_mag)
	SAVE_STATE(python_mag)
	SAVE_STATE(shotgun_mag)
	SAVE_STATE(crossbow_mag)
	SAVE_STATE(rpg_mag)
	SAVE_STATE(satchel_chg)

	SAVE_STATE(ammo_9mm)
	SAVE_STATE(ammo_357)
	SAVE_STATE(ammo_buckshot)
	SAVE_STATE(ammo_bolt)
	SAVE_STATE(ammo_rocket)
	SAVE_STATE(ammo_uranium)
	SAVE_STATE(ammo_handgrenade)
	SAVE_STATE(ammo_satchel)
	SAVE_STATE(ammo_tripmine)
	SAVE_STATE(ammo_snark)
	SAVE_STATE(ammo_hornet)

	SAVE_STATE(ammo_m203_grenade)
	SAVE_STATE(ammo_gauss_volume)
	SAVE_STATE(ammo_rpg_state)
	SAVE_STATE(mode_tempstate)
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

	ROLL_BACK(anim_top)
	ROLL_BACK(anim_top_delay)
	ROLL_BACK(anim_top_time)
	ROLL_BACK(anim_bottom)
	ROLL_BACK(anim_bottom_time)

	ROLL_BACK(glock_mag)
	ROLL_BACK(mp5_mag)
	ROLL_BACK(python_mag)
	ROLL_BACK(shotgun_mag)
	ROLL_BACK(crossbow_mag)
	ROLL_BACK(rpg_mag)
	ROLL_BACK(satchel_chg)

	ROLL_BACK(ammo_9mm)
	ROLL_BACK(ammo_357)
	ROLL_BACK(ammo_buckshot)
	ROLL_BACK(ammo_m203_grenade)
	ROLL_BACK(ammo_bolt)
	ROLL_BACK(ammo_rocket)
	ROLL_BACK(ammo_uranium)
	ROLL_BACK(ammo_handgrenade)
	ROLL_BACK(ammo_satchel)
	ROLL_BACK(ammo_tripmine)
	ROLL_BACK(ammo_snark)
	ROLL_BACK(ammo_hornet)

	ROLL_BACK(ammo_m203_grenade)
	ROLL_BACK(ammo_gauss_volume)
	ROLL_BACK(ammo_rpg_state)
	ROLL_BACK(mode_tempstate)
}

#else
void
player::Save(float handle)
{
	super::Save(handle);

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

	EVALUATE_FIELD(anim_top, PLAYER_TOPFRAME)
	EVALUATE_FIELD(anim_top_time, PLAYER_TOPFRAME)
	EVALUATE_FIELD(anim_top_delay, PLAYER_TOPFRAME)
	EVALUATE_FIELD(anim_bottom, PLAYER_BOTTOMFRAME)
	EVALUATE_FIELD(anim_bottom_time, PLAYER_BOTTOMFRAME)

	EVALUATE_FIELD(glock_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(mp5_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(python_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(shotgun_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(crossbow_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(rpg_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(satchel_chg, PLAYER_AMMO1)

	EVALUATE_FIELD(ammo_9mm, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_357, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_buckshot, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_bolt, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_rocket, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_uranium, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_handgrenade, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_satchel, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_tripmine, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_snark, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_hornet, PLAYER_AMMO2)

	EVALUATE_FIELD(ammo_m203_grenade, PLAYER_AMMO3)
	EVALUATE_FIELD(ammo_gauss_volume, PLAYER_AMMO3)
	EVALUATE_FIELD(ammo_rpg_state, PLAYER_AMMO3)
	EVALUATE_FIELD(mode_tempstate, PLAYER_AMMO3)
}

/*
=================
player::SendEntity
=================
*/
float
player::SendEntity(entity ePEnt, float flChanged)
{
	/* just-in-case. */
	if (classname != "player")
		return (0);

	/* don't broadcast invisible players */
	if (IsFakeSpectator() && ePEnt != this)
		return (0);
	if (!GetModelindex() && ePEnt != this)
		return (0);

	flChanged = OptimiseChangedFlags(ePEnt, flChanged);

	WriteByte(MSG_ENTITY, ENT_PLAYER);
	WriteFloat(MSG_ENTITY, flChanged);

	/* the generic client attributes */
	NSClientPlayer::SendEntity(ePEnt, flChanged);

	SENDENTITY_BYTE(anim_top, PLAYER_TOPFRAME)
	SENDENTITY_FLOAT(anim_top_time, PLAYER_TOPFRAME)
	SENDENTITY_FLOAT(anim_top_delay, PLAYER_TOPFRAME)
	SENDENTITY_BYTE(anim_bottom, PLAYER_BOTTOMFRAME)
	SENDENTITY_FLOAT(anim_bottom_time, PLAYER_BOTTOMFRAME)

	SENDENTITY_BYTE(glock_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(mp5_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(python_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(shotgun_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(crossbow_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(rpg_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(satchel_chg, PLAYER_AMMO1)

	SENDENTITY_BYTE(ammo_9mm, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_357, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_buckshot, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_bolt, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_rocket, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_uranium, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_handgrenade, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_satchel, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_tripmine, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_snark, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_hornet, PLAYER_AMMO2)

	SENDENTITY_BYTE(ammo_m203_grenade, PLAYER_AMMO3)
	SENDENTITY_BYTE(ammo_gauss_volume, PLAYER_AMMO3)
	SENDENTITY_BYTE(ammo_rpg_state, PLAYER_AMMO3)
	SENDENTITY_BYTE(mode_tempstate, PLAYER_AMMO3)

	return (1);
}
#endif
