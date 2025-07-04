/*
 * Copyright (c) 2024-2025 Marco Cawthorne <marco@icculus.org>
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


string g_strTeamList;
const string mp_teamlist_fallback = "scientist;hgrunt";
var string autocvar_mp_teamlist = mp_teamlist_fallback;

bool
IsTeamplay(void)
{
	return cvars.GetBool("mp_teamplay");
}

bool
AllowFlashlight(void)
{
	return cvars.GetBool("mp_flashlight");
}

void
CodeCallback_Precache(void)
{
	motd.LoadDefault();
	precache.Entity("player_mp");
}

void
CodeCallback_StartGameType(void)
{
	if (IsTeamplay() == true) {
		int c;

		/* get the segments from our cvar */
		g_strTeamList = autocvar_mp_teamlist;
		c = tokenizebyseparator(g_strTeamList, ";");

		/* if we've got less than 2 teams, use the fallback... */
		if (c < 2) {
			g_strTeamList = mp_teamlist_fallback;
			c = tokenizebyseparator(g_strTeamList, ";");
		}

		/* initialize all dem teams */
		for (int i = 0; i < c; i++) {
			teams.SetUp(i+1, argv(i), [255,255,255], true);
			teams.SetSpawnPoint(i+1, "info_player_deathmatch");
		}
	} else {
		game.SetSpawnPoint("info_player_deathmatch");
	}

	for (entity s = world; (s = next.Item(s));) {
		string isWeapon = substring(s.classname, 0, 7);
		string isAmmo = substring(s.classname, 0, 5);

		if (isWeapon == "weapon_" || isAmmo == "ammo_") {
			ents.Input(s, "SetRespawnTime", "20.0f", world);
		} else {
			ents.Input(s, "SetRespawnTime", "30.0f", world);
		}
	}
}

float
HLDM_IndexForName(string modelName)
{
	float modelID = 0;

	if (modelName != "") {
		string playerModel = "";
		playerModel = sprintf("models/player/%s/%s.mdl", modelName, modelName);
		modelID = getmodelindex(playerModel);
	}

	if (modelID) {
		return (modelID);
	}

	return getmodelindex("models/player.mdl");
}

void
HLDM_PlayerSpawn(entity playerEntity)
{
	string playerModel;

	ents.ChangeToClass(playerEntity, "player_mp");

	if (teams.TeamCount() >= 1) {
		float teamCount = tokenizebyseparator(g_strTeamList, ";");
		float playerTeam = playerEntity.team;
		string teamModel;

		/* not part of a team? pick one of the ones we have */
		/* TODO: this should sort us into the lowest team */
		if (playerTeam == 0) {
			playerTeam = 1 + floor(random(0, teamCount)); /* teams start at 1 after all */
			ents.Input(playerEntity, "SetTeam", ftos(playerTeam), playerEntity);
		}

		teamModel = argv(playerTeam - 1);
		playerModel = sprintf("models/player/%s/%s.mdl", teamModel, teamModel);
	} else {
		/* interpret the 'model' InfoKey */
		playerModel = userinfo.GetString(playerEntity, "model");

		if (playerModel != "") {
			playerModel = sprintf("models/player/%s/%s.mdl", playerModel, playerModel);
		}
	}

	/* fallback is always models/player.mdl for Half-Life */
	if (playerModel == "" || exists.InVFS(playerModel) == false) {
		playerModel = "models/player.mdl";
	}

	playerEntity.modelindex = getmodelindex(playerModel); /* keep OG size */
	game.TeleportToSpawn(playerEntity);
}

void
CodeCallback_PlayerSpawn(entity playerEntity)
{
	if (teams.TeamCount() <= 0)  {
		HLDM_PlayerSpawn(playerEntity);
	} else {
		ents.ChangeToClass(playerEntity, "spectator");
		game.TeleportToSpawn(playerEntity);
	}
}


void
CodeCallback_PlayerDisconnect(entity playerEntity)
{

}

bool
CodeCallback_PlayerRequestRespawn(entity playerEntity)
{
	if (is.Alive(playerEntity) == false) {
		HLDM_PlayerSpawn(playerEntity);
	}

	return (true);
}

void
CodeCallback_PlayerDamage(entity playerEntity, entity inflictor, entity attacker)
{

}

bool
CodeCallback_CallRequestTeam(entity playerEntity, int teamNum)
{
	ents.Input(playerEntity, "SetTeam", itos(teamNum), playerEntity);
	ents.Input(playerEntity, "Damage", "1000", playerEntity);
	return (true);
}

void
CodeCallback_PlayerKilled(entity playerEntity, entity inflictor, entity attacker, string weapon)
{
	int fragLimit = cvars.GetInteger("fraglimit");

	combat.Obituary(playerEntity.netname, attacker.netname, weapon, "");

	/* death-counter */
	playerEntity.deaths++;

	/* update score-counter */
	if (is.Player(attacker)) {
		if (playerEntity == attacker) {
			attacker.frags--;
		} else {
			attacker.frags++;
		}
	}

	if (fragLimit >= 1) {
		if (attacker.frags >= fragLimit) {
			game.LoadNextMap();
		}
	}
}

bool
CodeCallback_ClientCommand(entity playerEntity, string command)
{
	float commandArgs = tokenize(command);

	switch (argv(0)) {
	case "chooseteam":
		string teamName = argv(1);

		/* wrong mode */
		if (teams.TeamCount() <= 0)  {
			break;
		}

		/* no team defined */
		if (!teamName) {
			break;
		}

		float c = tokenizebyseparator(g_strTeamList, ";");

		for (float i = 0; i < c; i++) {
			if (argv(i) == teamName) {
				string newTeam = ftos(i + 1);
				ents.Input(playerEntity, "SetTeam", newTeam, playerEntity);
				ents.Input(playerEntity, "Damage", "1000", playerEntity);
				break;
			}
		}
		break;
	case "join":
		string className = argv(1);
		if (is.Alive(playerEntity) == true) {
			break;
		}

		if (STRING_SET(className)) {
			ents.ChangeToClass(playerEntity, strcat("player_", className));
			game.TeleportToSpawn(playerEntity);
		} else {
			HLDM_PlayerSpawn(playerEntity);
		}

		break;
	default:
		return (false);
	}

	return (true);
}

bool
CodeCallback_ImpulseCommand(entity playerEntity, float impulseNum)
{
	switch (impulseNum) {
	case 100:
		if (AllowFlashlight() == true) {
			ents.Input(playerEntity, "UseItem", "item_suit", playerEntity);
		}
		break;
	default:
		return (false);
	}

	return (true);
}
