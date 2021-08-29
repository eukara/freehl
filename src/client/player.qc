/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

string g_pbones[] =
{
 "Bip01",
 "Bip01 Footsteps",
 "Bip01 Pelvis",
 "Bip01 L Leg",
 "Bip01 L Leg1",
 "Bip01 L Foot",
 "Bip01 L Toe0",
 "Bip01 L Toe01",
 "Bip01 L Toe02",
 "Dummy16",
 "Bip01 R Leg",
 "Bip01 R Leg1",
"Bip01 R Foot",
 "Bip01 R Toe0",
 "Bip01 R Toe01",
 "Bip01 R Toe02",
 "Dummy11",
 "Bip01 Spine",
 "Bip01 Spine1",
 "Bip01 Spine2",
 "Bip01 Spine3",
 "Bip01 Neck",
 "Bip01 Head",
 "Dummy21",
 "Dummy08",
 "Bone02",
 "Bone03",
 "Bone04",
 "Dummy05",
 "Bone09",
 "Bone10",
 "Dummy04",
 "Bone05",
 "Bone06",
 "Dummy03",
 "Bone07",
 "Bone08",
 "Dummy09",
 "Bone11",
 "Bone12",
"Dummy10",
 "Bone13",
 "Bone14",
 "Bone15",
 "Bip01 L Arm",
 "Bip01 L Arm1",
 "Bip01 L Arm2",
 "Bip01 L Hand",
 "Bip01 L Finger0",
 "Bip01 L Finger01",
 "Bip01 L Finger02",
 "Dummy06",
 "Bip01 L Finger1",
 "Bip01 L Finger11",
 "Bip01 L Finger12",
 "Dummy07",
 "Bip01 R Arm",
 "Bip01 R Arm1",
 "Bip01 R Arm2",
 "Bip01 R Hand",
 "Bip01 R Finger0",
 "Bip01 R Finger01",
 "Bip01 R Finger02",
 "Dummy01",
 "Bip01 R Finger1",
 "Bip01 R Finger11",
 "Bip01 R Finger12",
 "Dummy02",
 "Box02",
 "Bone08",
 "Bone15"
};

void
Player_HandleWeaponModel(base_player pp, float thirdperson)
{
	player pl = (player)pp;

	/* if we don't exist, create us */
	if (!pl.p_model) {
		pl.p_model = spawn();
	}

	/* only make it visible when it's a thirdperson drawcall */
	pl.p_model.drawmask = (thirdperson) ? MASK_ENGINE:0;

	/* let's not waste any time doing bone calculations then */
	if (pl.p_model.drawmask == 0)
		return;

	/* what's the current weapon model supposed to be anyway? */
	string wmodel = Weapons_GetPlayermodel(pl.activeweapon);

	/* we changed weapons, update skeletonindex */
	if (pl.p_model.model != wmodel) {
		/* free memory */
		if (pl.p_model.skeletonindex)
			skel_delete(pl.p_model.skeletonindex);

		/* set the new model and mark us updated */
		setmodel(pl.p_model, wmodel);
		pl.p_model.model = wmodel;
		
		/* set the new skeletonindex */
		pl.p_model.skeletonindex = skel_create(pl.p_model.modelindex);

		/* hack this thing in here FIXME: this should be done when popping in/out of a pvs */
		if (autocvar(cl_himodels, 1, "Use high-quality player models over lower-definition ones"))
			setcustomskin(self, "", "geomset 0 2\n");
		else
			setcustomskin(self, "", "geomset 0 1\n");
	}

	/* follow player at all times */
	setorigin(pl.p_model, pl.origin);
	pl.p_model.angles = pl.angles;
	skel_build(pl.p_model.skeletonindex, pl.p_model, pl.p_model.modelindex,0, 0, -1);

	/* we have to loop through all valid bones of the weapon model and match them
	 * to the player one */
	for (float i = 0; i < g_pbones.length; i++) {
		vector bpos;
		float pbone = gettagindex(pl, g_pbones[i]);
		float wbone = gettagindex(pl.p_model, g_pbones[i]);

		/* if the bone doesn't ignore in either skeletal mesh, ignore */
		if (wbone <= 0 || pbone <= 0)
			continue;

		bpos = gettaginfo(pl, pbone);
		
		/* the most expensive bit */
		skel_set_bone_world(pl.p_model, wbone, bpos, v_forward, v_right, v_up);
	}	
}

/* we need to call this when a player entity gets removed */
void
Player_DestroyWeaponModel(entity pp)
{
	player pl = (player)pp;
	if (pl.p_model)
		remove(pl.p_model);
}

void
Player_PreDraw(base_player pp, int thirdperson)
{
	player pl = (player)pp;

	/* Handle the flashlights... */
	Player_Flashlight(pl);

#ifdef VALVE
	if (thirdperson && pl.gflags & GF_EGONBEAM) {
		vector src;
		vector endpos;

		makevectors(pl.v_angle);
		src = pl.origin;
		endpos = pl.origin + (v_forward * 1024);
		traceline(src, endpos, MOVE_NORMAL, pl);
		w_egon_beamfx(gettaginfo(pl.p_model, 10), trace_endpos, pl);
	}
#endif

	pl.Physics_SetViewParms();
	Animation_PlayerUpdate((player)pl);
	Animation_TimerUpdate((player)pl, clframetime);
	Player_HandleWeaponModel(pl, thirdperson);
}
