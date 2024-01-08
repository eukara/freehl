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

bool
HLSingleplayerRules::IsMultiplayer(void)
{
	return false;
}

void
HLSingleplayerRules::PlayerDeath(NSClientPlayer pl)
{
	pl.SetMovetype(MOVETYPE_NONE);
	pl.SetSolid(SOLID_NOT);
	pl.SetTakedamage(DAMAGE_NO);
	pl.SetHealth(0);
	pl.StartSoundDef("Player.Death", CHAN_AUTO, true);

	pl.gflags &= ~GF_FLASHLIGHT;
	pl.armor = pl.activeweapon = pl.g_items = pl.weapon = 0;

	if (cvar("coop") == 1) {
		pl.ScheduleThink(PutClientInServer, 4.0f);
	}

	/* so much damage we're gonna gib */
	if (pl.GetHealth() < -50) {
		//pl.Gib();
		//FX_GibHuman(pl.origin, vectoangles(pl.origin - g_dmg_eAttacker.origin), g_dmg_iDamage * 2.0f);
	}

	/* Let's handle corpses on the clientside */
	entity corpse = spawn();
	setorigin(corpse, pl.origin + [0,0,32]);
	setmodel(corpse, pl.model);
	setsize(corpse, VEC_HULL_MIN, VEC_HULL_MAX);
	corpse.movetype = MOVETYPE_TOSS;
	corpse.solid = SOLID_TRIGGER;
	corpse.modelindex = pl.modelindex;
	corpse.frame = ANIM_DIESIMPLE;
	corpse.angles = pl.angles;
	corpse.velocity = pl.velocity;
}

void
HLSingleplayerRules::PlayerSpawn(NSClientPlayer pl)
{
	string playerModel = "models/player.mdl";

	pl.classname = "player";
	pl.SetHealth(100);
	pl.SetMaxHealth(100);
	pl.SetTakedamage(DAMAGE_YES);
	pl.SetSolid(SOLID_SLIDEBOX);
	pl.SetMovetype(MOVETYPE_WALK);
	pl.AddFlags(FL_CLIENT);
	pl.viewzoom = 1.0;

	/* if in cooperative mode, we want to respect the player model */
	if (cvar("coop") == 1) {
		string testModel = infokey(pl, "model");
		if (testModel) {
			testModel = sprintf("models/player/%s/%s.mdl", testModel, testModel);
			if (whichpack(testModel)) {
				playerModel = testModel;
			}
		}
	}

	pl.SetModel(playerModel);
	pl.SetSize(VEC_HULL_MIN, VEC_HULL_MAX);
	pl.ClearVelocity();
	pl.SetInfoKey("*spec", "0");
	pl.SetInfoKey("*deaths", ftos(pl.deaths));
	pl.SetCanBleed(true);

	if (startspot != "") {
		LevelDecodeParms(pl);
		pl.SetOrigin(Landmark_GetSpot());
	} else {
		entity spawnPoint;
		LevelNewParms();
		spawnPoint = find(world, ::classname, "info_player_start");
		pl.Transport(spawnPoint.origin, spawnPoint.angles);
	}

	Weapons_RefreshAmmo(pl);
	Client_FixAngle(pl, pl.angles);
} 

bool
HLSingleplayerRules::ImpulseCommand(NSClient bp, float num)
{
	switch (num) {
	case 101:
		player pl = (player)bp;
		pl.SetHealth(100);
		pl.SetMaxHealth(100);
		pl.SetArmor(100);
		pl.g_items |= ITEM_SUIT;
		Weapons_AddItem(pl, WEAPON_CROWBAR, -1);
		Weapons_AddItem(pl, WEAPON_GLOCK, -1);
		Weapons_AddItem(pl, WEAPON_PYTHON, -1);
		Weapons_AddItem(pl, WEAPON_MP5, -1);
		Weapons_AddItem(pl, WEAPON_SHOTGUN, -1);
		Weapons_AddItem(pl, WEAPON_CROSSBOW, -1);
		Weapons_AddItem(pl, WEAPON_RPG, -1);
		Weapons_AddItem(pl, WEAPON_GAUSS, -1);
		Weapons_AddItem(pl, WEAPON_EGON, -1);
		Weapons_AddItem(pl, WEAPON_HORNETGUN, -1);
		Weapons_AddItem(pl, WEAPON_HANDGRENADE, -1);
		Weapons_AddItem(pl, WEAPON_SATCHEL, -1);
		Weapons_AddItem(pl, WEAPON_TRIPMINE, -1);
		Weapons_AddItem(pl, WEAPON_SNARK, -1);
		pl.ammo_m203_grenade = 10;
#ifdef GEARBOX
		Weapons_AddItem(pl, WEAPON_PIPEWRENCH, -1);
		Weapons_AddItem(pl, WEAPON_KNIFE, -1);
		Weapons_AddItem(pl, WEAPON_GRAPPLE, -1);
		Weapons_AddItem(pl, WEAPON_EAGLE, -1);
		Weapons_AddItem(pl, WEAPON_PENGUIN, -1);
		Weapons_AddItem(pl, WEAPON_M249, -1);
		Weapons_AddItem(pl, WEAPON_DISPLACER, -1);
		Weapons_AddItem(pl, WEAPON_SNIPERRIFLE, -1);
		Weapons_AddItem(pl, WEAPON_SPORELAUNCHER, -1);
		Weapons_AddItem(pl, WEAPON_SHOCKRIFLE, -1);
#endif
		break;
	default:
		return super::ImpulseCommand(bp, num);
	}

	return true;
}
