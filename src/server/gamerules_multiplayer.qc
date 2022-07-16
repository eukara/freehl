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

var string autocvar_mp_teamlist = "robo;hgrunt";
const string mp_teamlist_fallback = "robo;hgrunt";

bool
HLMultiplayerRules::IsMultiplayer(void)
{
	return true;
}

bool
HLMultiplayerRules::IsTeamplay(void)
{
	return cvar("mp_teamplay") == 1 ? true : false;
}

void
HLMultiplayerRules::InitPostEnts(void)
{
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
	forceinfokey(pl, "*deaths", ftos(pl.deaths));

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
		FX_GibHuman(pl.origin, vectoangles(pl.origin - g_dmg_eAttacker.origin), g_dmg_iDamage * 2.0f);
	} else {
		FX_Corpse_Spawn((player)pl, ANIM_DIESIMPLE);
	}

	/* now let's make the real client invisible */
	pl.Death();
	pl.takedamage = DAMAGE_NO;
	pl.gflags &= ~GF_FLASHLIGHT;
	pl.gflags &= ~GF_EGONBEAM;

	Sound_Play(pl, CHAN_AUTO, "player.die");

	/* force respawn */
	pl.think = PutClientInServer;
	pl.nextthink = time + 4.0f;

	/* have we gone over the fraglimit? */
	CheckRules();
}

void
HLMultiplayerRules::PlayerSpawn(NSClientPlayer pp)
{
	player pl = (player)pp;
	/* this is where the mods want to deviate */
	entity spot;

	pl.classname = "player";
	pl.health = pl.max_health = 100;
	pl.takedamage = DAMAGE_YES;
	pl.SetSolid(SOLID_SLIDEBOX);
	pl.SetMovetype(MOVETYPE_WALK);
	pl.flags = FL_CLIENT;
	pl.viewzoom = 1.0;
	pl.model = "models/player.mdl";
	string mymodel = infokey(pl, "model");

	if (mymodel) {
		mymodel = sprintf("models/player/%s/%s.mdl", mymodel, mymodel);
		if (whichpack(mymodel)) {
			pl.model = mymodel;
		}
	}
	setmodel(pl, pl.model);

	setsize(pl, VEC_HULL_MIN, VEC_HULL_MAX);
	pl.velocity = [0,0,0];
	pl.gravity = __NULL__;
	pl.frame = 1;
	//pl.SendEntity = Player_SendEntity;
	pl.SendFlags = UPDATE_ALL;
	pl.customphysics = Empty;
	pl.iBleeds = TRUE;
	forceinfokey(pl, "*spec", "0");
	forceinfokey(pl, "*dead", "0");
	forceinfokey(pl, "*deaths", ftos(pl.deaths));

	LevelNewParms();
	LevelDecodeParms(pl);

#if defined (VALVE) || defined (GEARBOX)
	pl.g_items = ITEM_CROWBAR | ITEM_GLOCK | ITEM_SUIT;
	pl.activeweapon = WEAPON_GLOCK;
	pl.glock_mag = 18;
	pl.ammo_9mm = 44;

	if (IsTeamplay() == true) {
		int c = tokenizebyseparator(m_strTeamList, ";");

		/* not part of a team? pick one of the ones we have */
		/* TODO: this should sort us into the lowest team */
		if (pl.team == 0) {
			pl.team = 1 + floor(random(0, c));
			forceinfokey(pl, "*team", sprintf("%d", pl.team));
		}

		/* assign our player model */
		mymodel = sprintf("models/player/%s/%s.mdl", argv(pl.team - 1), argv(pl.team - 1));

		if (whichpack(mymodel))
			pl.model = mymodel;

		setmodel(pl, pl.model);
	}
#endif

	spot = Spawn_SelectRandom("info_player_deathmatch");
	setorigin(pl, spot.origin);
	pl.angles = spot.angles;
	Weapons_RefreshAmmo(pl);

	Client_FixAngle(pl, pl.angles);
}

bool
HLMultiplayerRules::ConsoleCommand(NSClientPlayer pp, string cmd)
{
	tokenize(cmd);

	switch (argv(0)) {
	case "bot_add":
		bot pete = (bot)Bot_AddQuick();
		Bot_RandomColormap(pete);
		searchhandle pm = search_begin("models/player/*/*.mdl", TRUE, TRUE);
		int r = floor(random(0, search_getsize(pm)));
		string mdl = substring(search_getfilename(pm, r), 0, -5);
		tokenizebyseparator(mdl, "/");
		forceinfokey(pete, "model", argv(2));
		search_end(pm);
		break;
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
	return (false);
}

void
HLMultiplayerRules::HLMultiplayerRules(void)
{
	/* these lines do nothing but tell the server to register those cvars */
	autocvar(timelimit, 15, "Timelimit for multiplayer rounds");
	autocvar(fraglimit, 15, "Points limit for multiplayer rounds");
}

void
CSEv_HLDM_Chooseteam_s(string teamname)
{
	HLGameRules rules = (HLGameRules)g_grMode;
	player pl = (player)self;

	if (!teamname)
		return;
	if (rules.IsMultiplayer() == false)
		return;
	if (rules.IsTeamplay() == false)
		return;
	if (pl.health <= 0)
		return;

	HLMultiplayerRules mprules = (HLMultiplayerRules)rules;
	int c = tokenizebyseparator(mprules.m_strTeamList, ";");

	for (int i = 0; i < c; i++) {
		if (argv(i) == teamname) {
			pl.team = (float)i + 1;
			forceinfokey(pl, "*team", sprintf("%d", pl.team));
			Damage_Apply(pl, pl, 100, 0, DMG_SKIP_ARMOR);
			return;
		}
	}
}
