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

#pragma PROGS_DAT  "../../progs/singleplayer.dat"

#include "../../../src/server/api.h"

void
CodeCallback_PlayerSpawn(entity playerEntity)
{
	ents.ChangeToClass(playerEntity, "player");
	game.TeleportToSpawn(playerEntity);
}

bool
CodeCallback_PlayerRequestRespawn(entity playerEntity)
{
	localcmd("load quick\n");
	return (true);
}

bool
CodeCallback_ImpulseCommand(entity playerEntity, float impulseNum)
{
	switch (impulseNum) {
	case 100:
		ents.Input(self, "UseItem", "item_suit", self);
		break;
	case 101:
		ents.Input(self, "SetHealth", "100", self);
		ents.Input(self, "SetArmor", "100", self);
		ents.Input(self, "GiveItem", "item_suit", self);
		ents.Input(self, "GiveItem", "weapon_357", self);
		ents.Input(self, "GiveItem", "weapon_9mmAR", self);
		ents.Input(self, "GiveItem", "weapon_9mmhandgun", self);
		ents.Input(self, "GiveItem", "weapon_crossbow", self);
		ents.Input(self, "GiveItem", "weapon_crowbar", self);
		ents.Input(self, "GiveItem", "weapon_egon", self);
		ents.Input(self, "GiveItem", "weapon_gauss", self);
		ents.Input(self, "GiveItem", "weapon_handgrenade", self);
		ents.Input(self, "GiveItem", "weapon_hornetgun", self);
		ents.Input(self, "GiveItem", "weapon_rpg", self);
		ents.Input(self, "GiveItem", "weapon_satchel", self);
		ents.Input(self, "GiveItem", "weapon_shotgun", self);
		ents.Input(self, "GiveItem", "weapon_snark", self);
		ents.Input(self, "GiveItem", "weapon_tripmine", self);
		ents.Input(self, "GiveAmmo", "ammo_9mm 255", self);
		ents.Input(self, "GiveAmmo", "ammo_357 255", self);
		ents.Input(self, "GiveAmmo", "ammo_buckshot 255", self);
		ents.Input(self, "GiveAmmo", "ammo_bolt 255", self);
		ents.Input(self, "GiveAmmo", "ammo_rocket 255", self);
		ents.Input(self, "GiveAmmo", "ammo_uranium 255", self);
		ents.Input(self, "GiveAmmo", "ammo_handgrenade 255", self);
		ents.Input(self, "GiveAmmo", "ammo_satchel 255", self);
		ents.Input(self, "GiveAmmo", "ammo_tripmine 255", self);
		ents.Input(self, "GiveAmmo", "ammo_snark 255", self);
		ents.Input(self, "GiveAmmo", "ammo_hornet 255", self);
		ents.Input(self, "GiveAmmo", "ammo_m203_grenade 255", self);
		break;
	default:
		return (false);
	}

	return (true);
}
