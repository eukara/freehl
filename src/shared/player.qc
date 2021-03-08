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

/* all potential SendFlags bits we can possibly send */
enumflags
{
	PLAYER_KEEPALIVE,
	PLAYER_MODELINDEX,
	PLAYER_ORIGIN,
	PLAYER_ORIGIN_Z,
	PLAYER_ANGLES_X,
	PLAYER_ANGLES_Y,
	PLAYER_ANGLES_Z,
	PLAYER_VELOCITY,
	PLAYER_VELOCITY_Z,
	PLAYER_FLAGS,
	PLAYER_WEAPON,
	PLAYER_ITEMS,
	PLAYER_HEALTH,
	PLAYER_ARMOR,
	PLAYER_MOVETYPE,
	PLAYER_VIEWOFS,
	PLAYER_BASEFRAME,
	PLAYER_FRAME,
	PLAYER_AMMO1,
	PLAYER_AMMO2,
	PLAYER_AMMO3,
	PLAYER_UNUSED1,
	PLAYER_UNUSED2
};

/* ammo 1 type updates */
enumflags
{
	AMMO1_GLOCK,
	AMMO1_MP5,
	AMMO1_PYTHON,
	AMMO1_SHOTGUN,
	AMMO1_CROSSBOW,
	AMMO1_RPG,
	AMMO1_SATCHEL
};

/* ammo 2 type updates */
enumflags
{
	AMMO2_9MM,
	AMMO2_357,
	AMMO2_BUCKSHOT,
	AMMO2_BOLT,
	AMMO2_ROCKET,
	AMMO2_URANIUM,
	AMMO2_HANDGRENADE,
	AMMO2_SATCHEL,
	AMMO2_TRIPMINE,
	AMMO2_SNARK,
	AMMO2_HORNET,
};

enumflags
{
	AMMO3_M203_GRENADE,
	AMMO3_SHOTGUN_STATE,
	AMMO3_GAUSS_STATE,
	AMMO3_GAUSS_VOLUME,
	AMMO3_EGON_STATE,
	AMMO3_RPG_STATE,
	AMMO3_HANDGRENADE_STATE
};

noref int input_sequence;
class player:base_player
{
	/* Weapon specific */
	int glock_mag;
	int glock_mag_net;
	int mp5_mag;
	int  mp5_mag_net;
	int python_mag;
	int  python_mag_net;
	int shotgun_mag;
	int  shotgun_mag_net;
	int crossbow_mag;
	int  crossbow_mag_net;
	int rpg_mag;
	int  rpg_mag_net;
	int satchel_chg;
	int  satchel_chg_net;

	int ammo_9mm;
	int  ammo_9mm_net;
	int ammo_357;
	int  ammo_357_net;
	int ammo_buckshot;
	int  ammo_buckshot_net;
	int ammo_bolt;
	int  ammo_bolt_net;
	int ammo_rocket;
	int  ammo_rocket_net;
	int ammo_uranium;
	int  ammo_uranium_net;
	int ammo_handgrenade;
	int  ammo_handgrenade_net;
	int ammo_satchel;
	int  ammo_satchel_net;
	int ammo_tripmine;
	int  ammo_tripmine_net;
	int ammo_snark;
	int  ammo_snark_net;
	int ammo_hornet;
	int  ammo_hornet_net;

	int ammo_m203_grenade;
	int  ammo_m203_grenade_net;
	int ammo_gauss_volume;
	int  ammo_gauss_volume_net;
	int ammo_rpg_state;
	int  ammo_rpg_state_net;
	int mode_tempstate;
	int  mode_tempstate_net;

#ifdef CLIENT
	/* External model */
	entity p_model;
	int p_hand_bone;
	int p_model_bone;
	float lastweapon;

	virtual void(void) gun_offset;
	virtual void(void) draw;
	virtual float() predraw;
	virtual void(void) postdraw;
	virtual void(float) ReceiveEntity;
	virtual void(void) PredictPreFrame;
	virtual void(void) PredictPostFrame;
#else
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
#endif
};

#ifdef CLIENT
void Weapons_AmmoUpdate(entity);
/*
=================
player::ReceiveEntity
=================
*/
void
player::ReceiveEntity(float new)
{
	float fl;
	if (new == FALSE) {
		/* Go through all the physics code between the last received frame
		 * and the newest frame and keep the changes this time around instead
		 * of rolling back, because we'll apply the new server-verified values
		 * right after anyway. */
		/* FIXME: splitscreen */
		if (entnum == player_localentnum) {
			/* FIXME: splitscreen */
			pSeat = &g_seats[0];

			for (int i = sequence+1; i <= servercommandframe; i++) {
				/* ...maybe the input state is too old? */
				if (!getinputstate(i)) {
					break;
				}
				input_sequence = i;
				PMove_Run();
			}

			/* any differences in things that are read below are now
			 * officially from prediction misses. */
		}
	}

	/* seed for our prediction table */
	sequence = servercommandframe;

	fl = readfloat();

	/* HACK: we need to make this more reliable */
	if (fl == UPDATE_ALL) {
		/* we respawned */
		gravity = __NULL__;
	}

	if (fl & PLAYER_MODELINDEX)
		modelindex = readshort();

	if (fl & PLAYER_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
	}

	if (fl & PLAYER_ORIGIN_Z)
		origin[2] = readcoord();
	if (fl & PLAYER_ANGLES_X)
		pitch = readfloat();
	if (fl & PLAYER_ANGLES_Y)
		angles[1] = readfloat();
	if (fl & PLAYER_ANGLES_Z)
		angles[2] = readfloat();

	if (fl & PLAYER_VELOCITY) {
		velocity[0] = readcoord();
		velocity[1] = readcoord();
	}

	if (fl & PLAYER_VELOCITY_Z)
		velocity[2] = readcoord();
	if (fl & PLAYER_FLAGS) {
		flags = readfloat();
		gflags = readfloat();
	}
	if (fl & PLAYER_WEAPON)
		activeweapon = readbyte();
	if (fl & PLAYER_ITEMS)
		g_items = (__variant)readfloat();
	if (fl & PLAYER_HEALTH)
		health = readbyte();
	if (fl & PLAYER_ARMOR)
		armor = readbyte();
	if (fl & PLAYER_MOVETYPE)
		movetype = readbyte();
	if (fl & PLAYER_VIEWOFS)
		view_ofs[2] = readfloat();
	if (fl & PLAYER_BASEFRAME)
		baseframe = readbyte();
	if (fl & PLAYER_FRAME) {
		frame = readbyte();
		frame1time = 0.0f;
		frame2time = 0.0f;
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

	if (fl & PLAYER_AMMO1 || fl & PLAYER_AMMO2 || fl & PLAYER_AMMO3)
		Weapons_AmmoUpdate(this);

	setorigin(this, origin);
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
	glock_mag_net = glock_mag;
	mp5_mag_net = mp5_mag;
	python_mag_net = python_mag;
	shotgun_mag_net = shotgun_mag;
	crossbow_mag_net = crossbow_mag;
	rpg_mag_net = rpg_mag;
	satchel_chg_net = satchel_chg;
	ammo_9mm_net = ammo_9mm;
	ammo_357_net = ammo_357;
	ammo_buckshot_net = ammo_buckshot;
	ammo_bolt_net = ammo_bolt;
	ammo_rocket_net = ammo_rocket;
	ammo_uranium_net = ammo_uranium;
	ammo_handgrenade_net = ammo_handgrenade;
	ammo_satchel_net = ammo_satchel;
	ammo_tripmine_net = ammo_tripmine;
	ammo_snark_net = ammo_snark;
	ammo_hornet_net = ammo_hornet;

	ammo_m203_grenade_net = ammo_m203_grenade;
	ammo_gauss_volume_net = ammo_gauss_volume;
	ammo_rpg_state_net = ammo_rpg_state;
	mode_tempstate_net = mode_tempstate;
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
	glock_mag = glock_mag_net;
	mp5_mag = mp5_mag_net;
	python_mag = python_mag_net;
	shotgun_mag = shotgun_mag_net;
	crossbow_mag = crossbow_mag_net;
	rpg_mag = rpg_mag_net;
	satchel_chg = satchel_chg_net;
	ammo_9mm = ammo_9mm_net;
	ammo_357 = ammo_357_net;
	ammo_buckshot = ammo_buckshot_net;
	ammo_m203_grenade = ammo_m203_grenade_net;
	ammo_bolt = ammo_bolt_net;
	ammo_rocket = ammo_rocket_net;
	ammo_uranium = ammo_uranium_net;
	ammo_handgrenade = ammo_handgrenade_net;
	ammo_satchel = ammo_satchel_net;
	ammo_tripmine = ammo_tripmine_net;
	ammo_snark = ammo_snark_net;
	ammo_hornet = ammo_hornet_net;

	ammo_m203_grenade = ammo_m203_grenade_net;
	ammo_gauss_volume = ammo_gauss_volume_net;
	ammo_rpg_state = ammo_rpg_state_net;
	mode_tempstate = mode_tempstate_net;
}

#else
void
player::EvaluateEntity(void)
{
	SendFlags |= PLAYER_KEEPALIVE;

	if (old_modelindex != modelindex)
		SendFlags |= PLAYER_MODELINDEX;

	if (old_origin[0] != origin[0])
		SendFlags |= PLAYER_ORIGIN;

	if (old_origin[1] != origin[1])
		SendFlags |= PLAYER_ORIGIN;

	if (old_origin[2] != origin[2])
		SendFlags |= PLAYER_ORIGIN_Z;

	if (old_angles[0] != v_angle[0])
		SendFlags |= PLAYER_ANGLES_X;

	if (old_angles[1] != angles[1])
		SendFlags |= PLAYER_ANGLES_Y;

	if (old_angles[2] != angles[2])
		SendFlags |= PLAYER_ANGLES_Z;

	if (old_velocity[0] != velocity[0])
		SendFlags |= PLAYER_VELOCITY;

	if (old_velocity[1] != velocity[1])
		SendFlags |= PLAYER_VELOCITY;

	if (old_velocity[2] != velocity[2])
		SendFlags |= PLAYER_VELOCITY_Z;

	if (old_flags != flags)
		SendFlags |= PLAYER_FLAGS;

	if (old_gflags != gflags)
		SendFlags |= PLAYER_FLAGS;

	if (old_activeweapon != activeweapon)
		SendFlags |= PLAYER_WEAPON;

	if (old_items != g_items)
		SendFlags |= PLAYER_ITEMS;

	if (old_health != health)
		SendFlags |= PLAYER_HEALTH;

	if (old_armor != armor)
		SendFlags |= PLAYER_ARMOR;

	if (old_movetype != movetype)
		SendFlags |= PLAYER_MOVETYPE;

	if (old_viewofs != view_ofs[2])
		SendFlags |= PLAYER_VIEWOFS;

	if (old_baseframe != baseframe)
		SendFlags |= PLAYER_BASEFRAME;

	if (old_frame != frame)
		SendFlags |= PLAYER_FRAME;

	/* ammo 1 type updates */
	if (glock_mag != glock_mag_net) {
		SendFlags |= PLAYER_AMMO1;
	}
	if (mp5_mag != mp5_mag_net) {
		SendFlags |= PLAYER_AMMO1;
	}
	if (python_mag != python_mag_net) {
		SendFlags |= PLAYER_AMMO1;
	}
	if (shotgun_mag != shotgun_mag_net) {
		SendFlags |= PLAYER_AMMO1;
	}
	if (crossbow_mag != crossbow_mag_net) {
		SendFlags |= PLAYER_AMMO1;
	}
	if (rpg_mag != rpg_mag_net) {
		SendFlags |= PLAYER_AMMO1;
	}
	if (satchel_chg != satchel_chg_net) {
		SendFlags |= PLAYER_AMMO1;
	}

	/* ammo 2 type updates */
	if (ammo_9mm != ammo_9mm_net) {
		SendFlags |= PLAYER_AMMO2;
	}
	if (ammo_357 != ammo_357_net) {
		SendFlags |= PLAYER_AMMO2;
	}
	if (ammo_buckshot != ammo_buckshot_net) {
		SendFlags |= PLAYER_AMMO2;
	}
	if (ammo_bolt != ammo_bolt_net) {
		SendFlags |= PLAYER_AMMO2;
	}
	if (ammo_rocket != ammo_rocket_net) {
		SendFlags |= PLAYER_AMMO2;
	}
	if (ammo_uranium != ammo_uranium_net) {
		SendFlags |= PLAYER_AMMO2;
	}
	if (ammo_handgrenade != ammo_handgrenade_net) {
		SendFlags |= PLAYER_AMMO2;
	}
	if (ammo_satchel != ammo_satchel_net) {
		SendFlags |= PLAYER_AMMO2;
	}
	if (ammo_tripmine != ammo_tripmine_net) {
		SendFlags |= PLAYER_AMMO2;
	}
	if (ammo_snark != ammo_snark_net) {
		SendFlags |= PLAYER_AMMO2;
	}
	if (ammo_hornet != ammo_hornet_net) {
		SendFlags |= PLAYER_AMMO2;
	}

	if (ammo_m203_grenade != ammo_m203_grenade_net) {
		SendFlags |= PLAYER_AMMO3;
	}
	if (ammo_gauss_volume != ammo_gauss_volume_net) {
		SendFlags |= PLAYER_AMMO3;
	}
	if (ammo_rpg_state != ammo_rpg_state_net) {
		SendFlags |= PLAYER_AMMO3;
	}
	if (mode_tempstate != mode_tempstate_net) {
		SendFlags |= PLAYER_AMMO3;
	}

	old_modelindex = modelindex;
	old_origin = origin;
	old_angles = angles;
	old_angles[0] = v_angle[0];
	old_velocity = velocity;
	old_flags = flags;
	old_gflags = gflags;
	old_activeweapon = activeweapon;
	old_items = g_items;
	old_health = health;
	old_armor = armor;
	old_movetype = movetype;
	old_viewofs = view_ofs[2];
	old_baseframe = baseframe;
	old_frame = frame;

	glock_mag_net = glock_mag;
	mp5_mag_net = mp5_mag;
	python_mag_net = python_mag;
	shotgun_mag_net = shotgun_mag;
	crossbow_mag_net = crossbow_mag;
	rpg_mag_net = rpg_mag;
	satchel_chg_net = satchel_chg;

	ammo_9mm_net = ammo_9mm;
	ammo_357_net = ammo_357;
	ammo_buckshot_net = ammo_buckshot;
	ammo_m203_grenade_net = ammo_m203_grenade;
	ammo_bolt_net = ammo_bolt;
	ammo_rocket_net = ammo_rocket;
	ammo_uranium_net = ammo_uranium;
	ammo_handgrenade_net = ammo_handgrenade;
	ammo_satchel_net = ammo_satchel;
	ammo_tripmine_net = ammo_tripmine;
	ammo_snark_net = ammo_snark;
	ammo_hornet_net = ammo_hornet;

	ammo_m203_grenade_net = ammo_m203_grenade;
	ammo_gauss_volume_net = ammo_gauss_volume;
	ammo_rpg_state_net = ammo_rpg_state;
	mode_tempstate_net = mode_tempstate;
}

/*
=================
player::SendEntity
=================
*/
float
player::SendEntity(entity ePEnt, float fChanged)
{
	if (health <= 0 && ePEnt != this) {
		return FALSE;
	}

	if (clienttype(ePEnt) != CLIENTTYPE_REAL) {
		return FALSE;
	}

	if (ePEnt != self) {
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

	/* really trying to get our moneys worth with 23 bits of mantissa */
	if (fChanged & PLAYER_MODELINDEX)
		WriteShort(MSG_ENTITY, modelindex);
	if (fChanged & PLAYER_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
	}
	if (fChanged & PLAYER_ORIGIN_Z)
		WriteCoord(MSG_ENTITY, origin[2]);
	if (fChanged & PLAYER_ANGLES_X)
		WriteFloat(MSG_ENTITY, v_angle[0]);
	if (fChanged & PLAYER_ANGLES_Y)
		WriteFloat(MSG_ENTITY, angles[1]);
	if (fChanged & PLAYER_ANGLES_Z)
		WriteFloat(MSG_ENTITY, angles[2]);
	if (fChanged & PLAYER_VELOCITY) {
		WriteCoord(MSG_ENTITY, velocity[0]);
		WriteCoord(MSG_ENTITY, velocity[1]);
	}
	if (fChanged & PLAYER_VELOCITY_Z)
		WriteCoord(MSG_ENTITY, velocity[2]);
	if (fChanged & PLAYER_FLAGS) {
		WriteFloat(MSG_ENTITY, flags);
		WriteFloat(MSG_ENTITY, gflags);
	}
	if (fChanged & PLAYER_WEAPON)
		WriteByte(MSG_ENTITY, activeweapon);
	if (fChanged & PLAYER_ITEMS)
		WriteFloat(MSG_ENTITY, (__variant)g_items);
	if (fChanged & PLAYER_HEALTH)
		WriteByte(MSG_ENTITY, bound(0, health, 255));
	if (fChanged & PLAYER_ARMOR)
		WriteByte(MSG_ENTITY, armor);
	if (fChanged & PLAYER_MOVETYPE)
		WriteByte(MSG_ENTITY, movetype);
	if (fChanged & PLAYER_VIEWOFS)
		WriteFloat(MSG_ENTITY, view_ofs[2]);
	if (fChanged & PLAYER_BASEFRAME)
		WriteByte(MSG_ENTITY, baseframe);
	if (fChanged & PLAYER_FRAME)
		WriteByte(MSG_ENTITY, frame);

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

	return TRUE;
}
#endif
