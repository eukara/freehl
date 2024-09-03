/*
 * Copyright (c) 2024 Marco Cawthorne <marco@icculus.org>
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

#pragma PROGS_DAT  "dm.dat"

#include "../../../../../src/server/mapC.h"

entity lastSpawn;
string g_strTeamList;
const string mp_teamlist_fallback = "scientist;hgrunt";
var string autocvar_mp_teamlist = mp_teamlist_fallback;

bool
IsTeamplay(void)
{
	return getCvarInt("mp_teamplay") ? (true) : (false);
}

bool
AllowFlashlight(void)
{
	return getCvarInt("mp_flashlight") ? (true) : (false);
}

void
CodeCallback_StartGameType(void)
{
	//MOTD_LoadDefault();
	
	setServerInfo("scorepoints", "0");

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

		setServerInfo("teams", itos(c));

		/* initialize all dem teams */
		for (int i = 0; i < c; i++) {
			setServerInfo(sprintf("team_%i", i+1i), argv(i));
			setServerInfo(sprintf("teamscore_%i", i+1i), "0");
		}
	} else {
		setServerInfo("teams", "0");
	}
}

void
CodeCallback_PlayerSpawn(void)
{
	string playerModel;

	changeClass(self, "player_mp");

	if (IsTeamplay() == true) {
		float teamCount = tokenizebyseparator(g_strTeamList, ";");
		float playerTeam = self.team;
		string teamModel;

		/* not part of a team? pick one of the ones we have */
		/* TODO: this should sort us into the lowest team */
		if (playerTeam == 0) {
			playerTeam = 1 + floor(random(0, teamCount)); /* teams start at 1 after all */
			sendInput(self, "SetTeam", ftos(playerTeam), self);
		}

		teamModel = argv(playerTeam - 1);
		playerModel = sprintf("models/player/%s/%s.mdl", teamModel, teamModel);
	} else {
		/* interpret the 'model' InfoKey */
		playerModel = getUserInfo(self, "model");

		if (playerModel != "") {
			playerModel = sprintf("models/player/%s/%s.mdl", playerModel, playerModel);
		}
	}

	/* fallback is always models/player.mdl for Half-Life */
	if (playerModel == "" || fileExists(playerModel) == false) {
		playerModel = "models/player.mdl";
	}

	self.modelindex = getmodelindex(playerModel); /* keep OG size */
	lastSpawn = getSpawnpoint("info_player_deathmatch");
	setorigin(self, lastSpawn.origin);
}

void
CodeCallback_PlayerDisconnect(void)
{

}

bool
CodeCallback_PlayerRequestRespawn(void)
{
	CodeCallback_PlayerSpawn();
	return (true);
}

void
CodeCallback_PlayerDamage(entity inflictor, entity attacker)
{

}

void
CodeCallback_PlayerKilled(entity inflictor, entity attacker, string weapon)
{
	obituary(self.netname, attacker.netname, weapon, "");

	/* death-counter */
	self.deaths++;

	/* update score-counter */
	if (isPlayer(attacker)) {
		if (self == attacker) {
			attacker.frags--;
		} else {
			attacker.frags++;
		}
	}
}

bool
CodeCallback_ClientCommand(string command)
{
	float commandArgs = tokenize(command);

	switch (argv(0)) {
	case "chooseteam":
		string teamName = argv(1);

		/* wrong mode */
		if (IsTeamplay() == false) {
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
				sendInput(self, "SetTeam", newTeam, self);
				sendInput(self, "Damage", "1000", self);
				break;
			}
		}
		break;
	default:
		return (false);
	}

	return (true);
}

bool
CodeCallback_ImpulseCommand(float impulseNum)
{
	switch (impulseNum) {
	case 100:
		if (AllowFlashlight() == true) {
			sendInput(self, "UseItem", "item_suit", self);
		}
		break;
	default:
		return (false);
	}

	return (true);
}
