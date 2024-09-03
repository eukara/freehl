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

#pragma PROGS_DAT  "singleplayer.dat"

#include "../../../src/server/mapC.h"

void
CodeCallback_StartGameType(void)
{
}

void
CodeCallback_PlayerSpawn(void)
{
	changeClass(self, "player");

	entity lastSpawn = getSpawnpoint("info_player_start");
	setorigin(self, lastSpawn.origin);
}

bool
CodeCallback_PlayerRequestRespawn(void)
{
	localcmd("load quick\n");
	return (true);
}


bool
CodeCallback_ImpulseCommand(float impulseNum)
{
	switch (impulseNum) {
	case 100:
		sendInput(self, "UseItem", "item_suit", self);
		break;
	case 101:
		sendInput(self, "SetHealth", "100", self);
		sendInput(self, "SetArmor", "100", self);
		sendInput(self, "GiveItem", "item_suit", self);
		sendInput(self, "GiveItem", "weapon_357", self);
		sendInput(self, "GiveItem", "weapon_9mmAR", self);
		sendInput(self, "GiveItem", "weapon_9mmhandgun", self);
		sendInput(self, "GiveItem", "weapon_crossbow", self);
		sendInput(self, "GiveItem", "weapon_crowbar", self);
		sendInput(self, "GiveItem", "weapon_egon", self);
		sendInput(self, "GiveItem", "weapon_gauss", self);
		sendInput(self, "GiveItem", "weapon_handgrenade", self);
		sendInput(self, "GiveItem", "weapon_hornetgun", self);
		sendInput(self, "GiveItem", "weapon_rpg", self);
		sendInput(self, "GiveItem", "weapon_satchel", self);
		sendInput(self, "GiveItem", "weapon_shotgun", self);
		sendInput(self, "GiveItem", "weapon_snark", self);
		sendInput(self, "GiveItem", "weapon_tripmine", self);
		sendInput(self, "GiveAmmo", "ammo_9mm 255", self);
		sendInput(self, "GiveAmmo", "ammo_357 255", self);
		sendInput(self, "GiveAmmo", "ammo_buckshot 255", self);
		sendInput(self, "GiveAmmo", "ammo_bolt 255", self);
		sendInput(self, "GiveAmmo", "ammo_rocket 255", self);
		sendInput(self, "GiveAmmo", "ammo_uranium 255", self);
		sendInput(self, "GiveAmmo", "ammo_handgrenade 255", self);
		sendInput(self, "GiveAmmo", "ammo_satchel 255", self);
		sendInput(self, "GiveAmmo", "ammo_tripmine 255", self);
		sendInput(self, "GiveAmmo", "ammo_snark 255", self);
		sendInput(self, "GiveAmmo", "ammo_hornet 255", self);
		sendInput(self, "GiveAmmo", "ammo_m203_grenade 255", self);
		break;
	default:
		return (false);
	}

	return (true);
}