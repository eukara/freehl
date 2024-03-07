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

const string mp_teamlist_fallback = "robo;hgrunt";
var string autocvar_mp_teamlist = mp_teamlist_fallback;

bool
HLMultiplayerRules::IsMultiplayer(void)
{
	return true;
}

bool
HLMultiplayerRules::PlayerRequestRespawn(NSClientPlayer bp)
{
	if (bp.TimeSinceDeath() > 0.5f) {
		bp.ScheduleThink(PutClientInServer, 0.0f);
		return true;
	}

	return false;
}

bool
HLMultiplayerRules::IsTeamplay(void)
{
	return cvar("mp_teamplay") == 1 ? true : false;
}

void
HLMultiplayerRules::InitPostEnts(void)
{
	MOTD_LoadDefault();
	
	forceinfokey(world, "scorepoints", "0");

	if (IsTeamplay() == true) {
		int c;

		/* get the segments from our cvar */
		m_strTeamList = autocvar_mp_teamlist;
		c = tokenizebyseparator(m_strTeamList, ";");

		/* if we've got less than 2 teams, use the fallback... */
		if (c < 2) {
			m_strTeamList = mp_teamlist_fallback;
			c = tokenizebyseparator(m_strTeamList, ";");
		}

		forceinfokey(world, "teams", itos(c));

		/* initialize all dem teams */
		for (int i = 0; i < c; i++) {
			forceinfokey(world, sprintf("team_%i", i+1i), argv(i));
			forceinfokey(world, sprintf("teamscore_%i", i+1i), "0");
		}
	} else {
		forceinfokey(world, "teams", "0");
	}
}

void
HLMultiplayerRules::FrameStart(void)
{
	if (cvar("timelimit"))
	if (time >= (cvar("timelimit") * 60)) {
		IntermissionStart();
	}

	IntermissionCycle();
}

void
HLMultiplayerRules::CheckRules(void)
{
	/* last person who killed somebody has hit the limit */
	if (cvar("fraglimit"))
	if (g_dmg_eAttacker.frags >= cvar("fraglimit"))
		IntermissionStart();
}

void
HLMultiplayerRules::PlayerDeath(NSClientPlayer pl)
{
	/* obituary networking */
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_OBITUARY);
	WriteString(MSG_MULTICAST, (g_dmg_eAttacker.netname) ? g_dmg_eAttacker.netname : g_dmg_eAttacker.classname);
	WriteString(MSG_MULTICAST, pl.netname);
	WriteByte(MSG_MULTICAST, g_dmg_iWeapon);
	WriteByte(MSG_MULTICAST, 0);
	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL);

	Plugin_PlayerObituary(g_dmg_eAttacker, g_dmg_eTarget, g_dmg_iWeapon, g_dmg_iHitBody, g_dmg_iDamage);

	/* death-counter */
	pl.deaths++;
	pl.SetInfoKey("*deaths", ftos(pl.deaths));

	/* update score-counter */
	if (pl.flags & FL_CLIENT || pl.flags & FL_MONSTER)
	if (g_dmg_eAttacker.flags & FL_CLIENT) {
		if (pl == g_dmg_eAttacker)
			g_dmg_eAttacker.frags--;
		else
			g_dmg_eAttacker.frags++;
	}

#ifdef VALVE
	/* explode all satchels */
	s_satchel_detonate((entity)pl);
	/* drop their posessions into a weaponbox item */
	weaponbox_spawn((player)pl);
#endif

	/* either gib, or make a corpse */
	if (pl.health < -50) {
		vector gibDir = vectoangles(pl.origin - g_dmg_eAttacker.origin);
		float gibStrength = g_dmg_iDamage * 2.0f;
		BreakModel_Entity(pl, gibDir, gibStrength);
	} else {
		float deathAnimation = ANIM_DIESIMPLE;

		switch (g_dmg_iHitBody) {
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
			bool isFacing = pl.IsFacingPosition(g_dmg_vecLocation);

			/* we still want a change to play ANIM_DIESIMPLE */
			if (random() < 0.5)
			if (isFacing == false) {
				deathAnimation = ANIM_DIEFORWARD;
			} else {
				deathAnimation = random() < 0.5 ? ANIM_DIEBACKWARDS1 : ANIM_DIEBACKWARDS1;
			}

			break;
		}

		NSEntity newCorpse = (NSEntity)FX_Corpse_Spawn((player)pl, deathAnimation);

		/* if we were crouching, adjust the bbox (thx 2 lack of crouch death animation) */
		if (pl.flags & FL_CROUCHING) {
			newCorpse.SetSize(VEC_HULL_MIN, [16, 16, -16]);
		}
	}

	/* now let's make the real client invisible */
	pl.Death();
	pl.SetTakedamage(DAMAGE_NO);
	pl.gflags &= ~GF_FLASHLIGHT;
	pl.gflags &= ~GF_EGONBEAM;

	pl.StartSoundDef("Player.Death", CHAN_AUTO, true);

	/* force respawn */
	if (cvar("mp_forcerespawn") == 1) {
		pl.ScheduleThink(PutClientInServer, 4.0f);
	}

	/* have we gone over the fraglimit? */
	CheckRules();
}

void
HLMultiplayerRules::PlayerSpawn(NSClientPlayer pp)
{
	player pl = (player)pp;
	string playerModel;
	/* this is where the mods want to deviate */
	entity spot;

	pl.classname = "player";
	pl.SetMaxHealth(100);
	pl.SetHealth(100);
	pl.SetTakedamage(DAMAGE_YES);
	pl.SetSolid(SOLID_SLIDEBOX);
	pl.SetMovetype(MOVETYPE_WALK);
	pl.AddFlags(FL_CLIENT);
	pl.viewzoom = 1.0;

	/* player model selection */
	if (IsTeamplay() == true) {
		int teamCount = tokenizebyseparator(m_strTeamList, ";");
		int playerTeam = (int)pl.GetTeam();

		/* not part of a team? pick one of the ones we have */
		/* TODO: this should sort us into the lowest team */
		if (playerTeam == 0) {
			playerTeam = 1i + (int)floor(random(0, (float)teamCount)); /* teams start at 1 after all */
			pl.SetTeam(playerTeam);
		}

		/* assign our player model */
		playerModel = sprintf("models/player/%s/%s.mdl", argv(playerTeam - 1i), argv(playerTeam - 1i));
	} else {
		/* interpret the 'model' InfoKey */
		playerModel = pl.GetInfoKey("model");

		if (playerModel) {
			playerModel = sprintf("models/player/%s/%s.mdl", playerModel, playerModel);
		}
	}

	/* fallback is always models/player.mdl for Half-Life */
	if not (whichpack(playerModel)) {
		playerModel = "models/player.mdl";
	}
	
	pl.SetModel(playerModel);
	pl.SetSize(VEC_HULL_MIN, VEC_HULL_MAX);
	pl.ClearVelocity();
	pl.gravity = __NULL__;
	pl.SetFrame(1);
	pl.SendFlags = UPDATE_ALL;
	pl.SetInfoKey("*spec", "0");
	pl.SetInfoKey("*dead", "0");
	pl.SetInfoKey("*deaths", ftos(pl.deaths));
	pl.SetPropData("actor_human");
	pl.SetCanBleed(true);

	LevelNewParms();
	LevelDecodeParms(pl);

#if defined (VALVE) || defined (GEARBOX)
	pl.g_items = ITEM_CROWBAR | ITEM_GLOCK | ITEM_SUIT;
	pl.activeweapon = WEAPON_GLOCK;
	pl.glock_mag = 18;
	pl.ammo_9mm = 44;
#endif

	spot = Spawn_SelectRandom("info_player_deathmatch");
	pl.Transport(spot.origin, spot.angles);
	Weapons_RefreshAmmo(pl);
	Client_FixAngle(pl, pl.angles);
}

bool
HLMultiplayerRules::ConsoleCommand(NSClientPlayer pp, string cmd)
{
	tokenize(cmd);

	switch (argv(0)) {
	case "jumptest":
		makevectors(pp.v_angle);
		traceline(pp.origin + pp.view_ofs, pp.origin + pp.view_ofs + v_forward * 1024, FALSE, pp);
		pp.velocity = Route_GetJumpVelocity(pp.origin, trace_endpos, pp.gravity);
		break;
	default:
		return (false);
	}

	return (true);
}

bool
HLMultiplayerRules::MonstersSpawn(void)
{
	return (autocvar(mp_allowmonsters, 0)) ? true : false;
}

void
HLMultiplayerRules::HLMultiplayerRules(void)
{
	/* these lines do nothing but tell the server to register those cvars */
	autocvar(timelimit, 15, "Timelimit for multiplayer rounds");
	autocvar(fraglimit, 15, "Points limit for multiplayer rounds");
}

void
CSEv_HLDM_Chooseteam_s(string teamName)
{
	HLGameRules rules = (HLGameRules)g_grMode;
	player pl = (player)self;

	if (!teamName)
		return;
	if (rules.IsMultiplayer() == false)
		return;
	if (rules.IsTeamplay() == false)
		return;
	if (pl.IsDead() == true)
		return;

	HLMultiplayerRules mprules = (HLMultiplayerRules)rules;
	int c = tokenizebyseparator(mprules.m_strTeamList, ";");

	for (int i = 0; i < c; i++) {
		if (argv(i) == teamName) {
			pl.SetTeam((float)i + 1);
			Damage_Apply(pl, pl, 100, 0, DMG_SKIP_ARMOR);
			return;
		}
	}
}
