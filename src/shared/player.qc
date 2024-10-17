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

#include "animations.h"

/* all custom SendFlags bits we can possibly send */
enumflags
{
	PLAYER_TOPFRAME = PLAYER_CUSTOMFIELDSTART,
	PLAYER_BOTTOMFRAME
};

class HLPlayer:NSClientPlayer
{
	void(void) HLPlayer;

	/* animation */
	PREDICTED_INT(anim_top)
	PREDICTED_FLOAT(anim_top_time)
	PREDICTED_FLOAT(anim_top_delay)
	PREDICTED_INT(anim_bottom)
	PREDICTED_FLOAT(anim_bottom_time)

	virtual void Physics_Jump(void);
	virtual void UpdatePlayerAnimation(float);

#ifdef CLIENT
	virtual void UpdatePlayerAttachments(bool);
	virtual void ReceiveEntity(float,float);
	virtual void PredictPreFrame(void);
	virtual void PredictPostFrame(void);
	virtual void UpdateAliveCam(void);
	virtual void ClientInputFrame(void);
#else
	virtual void Death(entity, entity, int, vector, int);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity, float);
	virtual void Save(float);
	virtual void Restore(string,string);
#endif
};

void Animation_PlayerTop(HLPlayer, float, float);
void Animation_PlayerBottom(HLPlayer, float, float);

void
HLPlayer::HLPlayer(void)
{
	anim_top = 0;
	anim_top_time = 0;
	anim_top_delay = 0;
	anim_bottom = 0;
	anim_bottom_time = 0;
}

void Animation_PlayerUpdate(HLPlayer); 
void Animation_TimerUpdate(HLPlayer, float); 

void
HLPlayer::UpdatePlayerAnimation(float timelength)
{
	/* calculate our skeletal progression */
	Animation_PlayerUpdate(this);
	/* advance animation timers */
	Animation_TimerUpdate(this, timelength);
}

#ifdef CLIENT
void
HLPlayer::ClientInputFrame(void)
{
	if (pSeatLocal->weaponSelectionHUD.Active()) {
		if (input_buttons & INPUT_PRIMARY) {
			pSeatLocal->weaponSelectionHUD.Trigger();
		} else if (input_buttons & INPUT_SECONDARY) {
			pSeatLocal->weaponSelectionHUD.Deactivate();
		}

		pSeat->m_flInputBlockTime = time + 0.2;
	}

	super::ClientInputFrame();
}

void Camera_RunPosBob(vector angles, __inout vector camera_pos);
void Camera_StrafeRoll(__inout vector camera_angle);
void Shake_Update(NSClientPlayer);

void
HLPlayer::UpdateAliveCam(void)
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
//string Weapons_GetPlayermodel(NSClientPlayer, int);

var bool autocvar_cg_flashlightClassic = true;
var float autocvar_r_shadow_realtime_dlight;

void
HLPlayer::UpdatePlayerAttachments(bool visible)
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

		if (autocvar_cg_flashlightClassic == true) {
			if (autocvar_r_shadow_realtime_dlight == 0) {
				dynamiclight_add(trace_endpos + (trace_plane_normal * 4), 128, [1,1,1]);
			} else {
				dynamiclight_add(trace_endpos + (trace_plane_normal * 48.0f), 96, [1,1,1]);
			}
		} else {
			float p = dynamiclight_add(src + (v_forward * 16), 512, [1,1,1], 0, "textures/flashlight");
			dynamiclight_set(p, LFIELD_ANGLES, ang);
			dynamiclight_set(p, LFIELD_FLAGS, 3);
		}
	}

	/* FIXME: this needs to be incorporated and simplified, now that we can handle it all in-class */
	if (!visible)
		return;

	/* what's the current weapon model supposed to be anyway? */
	p_model.oldmodel = 0;//Weapons_GetPlayermodel(this, activeweapon);

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

void HUD_AmmoNotify_Check(NSClientPlayer pl);
void HUD_ItemNotify_Check(NSClientPlayer pl);
/*
=================
HLPlayer::ReceiveEntity
=================
*/
void
HLPlayer::ReceiveEntity(float new, float flChanged)
{
	/* the generic client attributes */
	super::ReceiveEntity(new, flChanged);

	/* animation */
	READENTITY_BYTE(anim_top, PLAYER_TOPFRAME)
	READENTITY_FLOAT(anim_top_time, PLAYER_TOPFRAME)
	READENTITY_FLOAT(anim_top_delay, PLAYER_TOPFRAME)
	READENTITY_BYTE(anim_bottom, PLAYER_BOTTOMFRAME)
	READENTITY_FLOAT(anim_bottom_time, PLAYER_BOTTOMFRAME)

	setorigin(this, origin);

	/* these only concern the current HLPlayer */
	CSQC_UpdateSeat();
	if (this != pSeat->m_ePlayer)
		return;

	/* do not notify us of updates when spawning initially */
	if (flChanged == UPDATE_ALL)
		PredictPreFrame();

	if (flChanged & PLAYER_AMMOTYPES ) {
		HUD_AmmoNotify_Check(this);
	}

	if (flChanged & PLAYER_ITEMS || flChanged & PLAYER_HEALTH)
		HUD_ItemNotify_Check(this);
}

/*
=================
HLPlayer::PredictPostFrame

Save the last valid server values away in the _net variants of each field
so we can roll them back later.
=================
*/
void
HLPlayer::PredictPreFrame(void)
{
	/* the generic client attributes */
	super::PredictPreFrame();

	SAVE_STATE(anim_top)
	SAVE_STATE(anim_top_delay)
	SAVE_STATE(anim_top_time)
	SAVE_STATE(anim_bottom)
	SAVE_STATE(anim_bottom_time)
}

/*
=================
HLPlayer::PredictPostFrame

Where we roll back our values to the ones last sent/verified by the server.
=================
*/
void
HLPlayer::PredictPostFrame(void)
{
	/* the generic client attributes */
	super::PredictPostFrame();

	ROLL_BACK(anim_top)
	ROLL_BACK(anim_top_delay)
	ROLL_BACK(anim_top_time)
	ROLL_BACK(anim_bottom)
	ROLL_BACK(anim_bottom_time)
}

#else
void
HLPlayer::Save(float handle)
{
	super::Save(handle);

	SaveInt(handle, "anim_top", anim_top);
	SaveFloat(handle, "anim_top_time", anim_top_time);
	SaveFloat(handle, "anim_top_delay", anim_top_delay);
	SaveInt(handle, "anim_bottom", anim_bottom);
	SaveFloat(handle, "anim_bottom_time", anim_bottom_time);
}

void
HLPlayer::Restore(string strKey, string strValue)
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
	default:
		super::Restore(strKey, strValue);
	}
}

void
HLPlayer::EvaluateEntity(void)
{
	/* the generic client attributes */
	NSClientPlayer::EvaluateEntity();

	EVALUATE_FIELD(anim_top, PLAYER_TOPFRAME)
	EVALUATE_FIELD(anim_top_time, PLAYER_TOPFRAME)
	EVALUATE_FIELD(anim_top_delay, PLAYER_TOPFRAME)
	EVALUATE_FIELD(anim_bottom, PLAYER_BOTTOMFRAME)
	EVALUATE_FIELD(anim_bottom_time, PLAYER_BOTTOMFRAME)

}

entity FX_Corpse_Spawn(NSClientPlayer pl, float anim);
void
HLPlayer::Death(entity inflictor, entity attacker, int damagePoints, vector dir, int location)
{
	/* either gib, or make a corpse */
	if (GetHealth()< -50) {
		vector gibDir = vectoangles(GetOrigin() - attacker.origin);
		float gibStrength = damagePoints * 2.0f;
		BreakModel_Entity(this, gibDir, gibStrength);
	} else {
		float deathAnimation = ANIM_DIESIMPLE;

		switch (location) {
		case BODY_HEAD:
			deathAnimation = ANIM_DIEHEADSHOT;
			break;
		case BODY_CHEST:
			deathAnimation = ANIM_DIESPIN;
			break;
		case BODY_STOMACH:
			deathAnimation = ANIM_DIEGUTSHOT;
			break;
		default:
			bool isFacing = IsFacingPosition(GetOrigin() + (dir * 128));

			/* we still want a change to play ANIM_DIESIMPLE */
			if (random() < 0.5)
			if (isFacing == false) {
				deathAnimation = ANIM_DIEFORWARD;
			} else {
				deathAnimation = random() < 0.5 ? ANIM_DIEBACKWARDS1 : ANIM_DIEBACKWARDS1;
			}

			break;
		}

		NSEntity newCorpse = (NSEntity)FX_Corpse_Spawn(this, deathAnimation);

		/* if we were crouching, adjust the bbox (thx 2 lack of crouch death animation) */
		if (IsCrouching()) {
			newCorpse.SetSize(VEC_HULL_MIN, [16, 16, -16]);
		}
	}
	
	super::Death(inflictor,  attacker,  damagePoints,  dir,  location);
}

/*
=================
HLPlayer::SendEntity
=================
*/
float
HLPlayer::SendEntity(entity ePEnt, float flChanged)
{
	/* just-in-case. */
	if (IsPlayer() == false)
		return (0);

	/* don't broadcast invisible HLPlayers */
	if (IsFakeSpectator() && ePEnt != this)
		return (0);
	if (!GetModelindex() && ePEnt != this)
		return (0);

	flChanged = OptimiseChangedFlags(ePEnt, flChanged);

	/* the generic client attributes */
	NSClientPlayer::SendEntity(ePEnt, flChanged);

	SENDENTITY_BYTE(anim_top, PLAYER_TOPFRAME)
	SENDENTITY_FLOAT(anim_top_time, PLAYER_TOPFRAME)
	SENDENTITY_FLOAT(anim_top_delay, PLAYER_TOPFRAME)
	SENDENTITY_BYTE(anim_bottom, PLAYER_BOTTOMFRAME)
	SENDENTITY_FLOAT(anim_bottom_time, PLAYER_BOTTOMFRAME)

	return (1);
}
#endif

void
HLPlayer::Physics_Jump(void)
{
	if (waterlevel >= 2) {
		if (watertype == CONTENT_WATER) {
			velocity[2] = 100;
		} else if (watertype == CONTENT_SLIME) {
			velocity[2] = 80;
		} else {
			velocity[2] = 50;
		}
	} else {
		/* Half-Life: Longjump module */
		if (IsCrouching() && HasItem("item_longjump")) {
			makevectors([0, v_angle[1], 0]);
			velocity = v_forward * 512;
			velocity[2] += 100;
		}
		if (flags & FL_ONGROUND)
			velocity[2] += 265;
	}
}
