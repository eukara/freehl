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

#pragma PROGS_DAT  "../../zpak001.pk3dir/progs/invasion.dat"

#include "../../../src/server/api.h"

var string autocvar_invasion_monsterClass = "monster_zombie";
var int autocvar_invasion_monsterCount = 5;

void
WaveTimer_Tick(void)
{
	int monsterCount = actor.TotalActors();

	/* spawn a new monster */
	if (monsterCount < autocvar_invasion_monsterCount) {
		entity zombie = ents.Create(autocvar_invasion_monsterClass, [0,0,0]);
		game.TeleportToSpawn(zombie);
		ents.Input(zombie, "HordeOn", "", world);
	}

	self.nextthink = time + 2.0f;
}

bool
AllowFlashlight(void)
{
	return cvars.GetBool("mp_flashlight");
}

void
CodeCallback_StartGameType(void)
{
	ents.Precache(autocvar_invasion_monsterClass);
	motd.LoadDefault();
	game.SetSpawnPoint("info_player_deathmatch");
	cvars.SetBool("coop", true);

	teams.SetUp(1, "Military", [0, 255, 0], false);
	teams.SetUp(2, "Aliens", [255, 0, 0], false);
	teams.SetUp(3, "Players", [255, 255, 255], false);
	teams.SetSpawnPoint(1, "info_player_deathmatch");
	teams.SetSpawnPoint(2, "info_player_deathmatch");
	teams.SetSpawnPoint(3, "info_player_deathmatch");

	entity tick = spawn();
	tick.think = WaveTimer_Tick;
	tick.nextthink = time + 1.0f;
}

void
CodeCallback_PlayerSpawn(void)
{
	string playerModel;

	ents.ChangeToClass(self, "player_mp");
	ents.Input(self, "SetTeam", "3", world);

	/* interpret the 'model' InfoKey */
	playerModel = userinfo.GetString(self, "model");

	if (playerModel != "") {
		playerModel = sprintf("models/player/%s/%s.mdl", playerModel, playerModel);
	}

	/* fallback is always models/player.mdl for Half-Life */
	if (!STRING_SET(playerModel) || exists.InVFS(playerModel) == false) {
		playerModel = "models/player.mdl";
	}

	self.modelindex = getmodelindex(playerModel); /* keep OG size */
	game.TeleportToSpawn(self);
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
	combat.Obituary(self.netname, attacker.netname, weapon, "");

	/* death-counter */
	self.deaths++;

	/* update score-counter */
	if (ents.isPlayer(attacker)) {
		if (self == attacker) {
			attacker.frags--;
		} else {
			attacker.frags++;
		}
	} else if (ents.isSentient(attacker)) {
		teams.AddScore(attacker.team, 1);
	}
}

void
CodeCallback_NPCKilled(entity inflictor, entity attacker, string weapon)
{
	combat.Obituary(self.netname, attacker.netname, weapon, "");

	/* update score-counter */
	if (ents.isPlayer(attacker)) {
		if (self == attacker) {
			attacker.frags--;
		} else {
			attacker.frags++;
		}
	}
}

bool
CodeCallback_ImpulseCommand(float impulseNum)
{
	switch (impulseNum) {
	case 100:
		if (AllowFlashlight() == true) {
			ents.Input(self, "UseItem", "item_suit", self);
		}
		break;
	default:
		return (false);
	}

	return (true);
}
