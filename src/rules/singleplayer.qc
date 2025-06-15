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
		ents.Input(playerEntity, "UseItem", "item_suit", playerEntity);
		break;
	case 101:
		ents.Input(playerEntity, "SetHealth", "100", world);
		ents.Input(playerEntity, "SetArmor", "100", world);
		ents.Input(playerEntity, "GiveItem", "item_suit", world);
		ents.Input(playerEntity, "GiveItem", "weapon_357", world);
		ents.Input(playerEntity, "GiveItem", "weapon_9mmAR", world);
		ents.Input(playerEntity, "GiveItem", "weapon_9mmhandgun", world);
		ents.Input(playerEntity, "GiveItem", "weapon_crossbow", world);
		ents.Input(playerEntity, "GiveItem", "weapon_crowbar", world);
		ents.Input(playerEntity, "GiveItem", "weapon_egon", world);
		ents.Input(playerEntity, "GiveItem", "weapon_gauss", world);
		ents.Input(playerEntity, "GiveItem", "weapon_handgrenade", world);
		ents.Input(playerEntity, "GiveItem", "weapon_hornetgun", world);
		ents.Input(playerEntity, "GiveItem", "weapon_rpg", world);
		ents.Input(playerEntity, "GiveItem", "weapon_satchel", world);
		ents.Input(playerEntity, "GiveItem", "weapon_shotgun", world);
		ents.Input(playerEntity, "GiveItem", "weapon_snark", world);
		ents.Input(playerEntity, "GiveItem", "weapon_tripmine", world);
		ents.Input(playerEntity, "GiveAmmo", "ammo_9mm 255", world);
		ents.Input(playerEntity, "GiveAmmo", "ammo_357 255", world);
		ents.Input(playerEntity, "GiveAmmo", "ammo_buckshot 255", world);
		ents.Input(playerEntity, "GiveAmmo", "ammo_bolt 255", world);
		ents.Input(playerEntity, "GiveAmmo", "ammo_rocket 255", world);
		ents.Input(playerEntity, "GiveAmmo", "ammo_uranium 255", world);
		ents.Input(playerEntity, "GiveAmmo", "ammo_handgrenade 255", world);
		ents.Input(playerEntity, "GiveAmmo", "ammo_satchel 255", world);
		ents.Input(playerEntity, "GiveAmmo", "ammo_tripmine 255", world);
		ents.Input(playerEntity, "GiveAmmo", "ammo_snark 255", world);
		ents.Input(playerEntity, "GiveAmmo", "ammo_hornet 255", world);
		ents.Input(playerEntity, "GiveAmmo", "ammo_m203_grenade 255", world);
		break;
	default:
		return (false);
	}

	return (true);
}
