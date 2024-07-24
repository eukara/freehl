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
	//corpse.frame = ANIM_DIESIMPLE;
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
	pl.EnableBleeding();

	if (startspot != "") {
		LevelDecodeParms(pl);
		pl.SetOrigin(Landmark_GetSpot());
		pl.Physics_Run();
	} else {
		entity spawnPoint;
		LevelNewParms();
		spawnPoint = find(world, ::classname, "info_player_start");
		pl.Transport(spawnPoint.origin, spawnPoint.angles);
		pl.Physics_Run();
	}

	Client_FixAngle(pl, pl.angles);
} 

bool
HLSingleplayerRules::ImpulseCommand(NSClient pl, float num)
{
	switch (num) {
	case 101:
		pl.SetHealth(100);
		pl.SetMaxHealth(100);
		pl.SetArmor(100);
		pl.GiveItem("item_suit");
		pl.GiveItem("weapon_357");
		pl.GiveItem("weapon_9mmAR");
		pl.GiveItem("weapon_9mmhandgun");
		pl.GiveItem("weapon_crossbow");
		pl.GiveItem("weapon_crowbar");
		pl.GiveItem("weapon_egon");
		pl.GiveItem("weapon_gauss");
		pl.GiveItem("weapon_handgrenade");
		pl.GiveItem("weapon_hornetgun");
		pl.GiveItem("weapon_rpg");
		pl.GiveItem("weapon_satchel");
		pl.GiveItem("weapon_shotgun");
		pl.GiveItem("weapon_snark");
		pl.GiveItem("weapon_tripmine");
		pl.GiveAmmo(ammoNumForName("ammo_9mm"), 255);
		pl.GiveAmmo(ammoNumForName("ammo_357"), 255);
		pl.GiveAmmo(ammoNumForName("ammo_buckshot"), 255);
		pl.GiveAmmo(ammoNumForName("ammo_bolt"), 255);
		pl.GiveAmmo(ammoNumForName("ammo_rocket"), 255);
		pl.GiveAmmo(ammoNumForName("ammo_uranium"), 255);
		pl.GiveAmmo(ammoNumForName("ammo_handgrenade"), 255);
		pl.GiveAmmo(ammoNumForName("ammo_satchel"), 255);
		pl.GiveAmmo(ammoNumForName("ammo_tripmine"), 255);
		pl.GiveAmmo(ammoNumForName("ammo_snark"), 255);
		pl.GiveAmmo(ammoNumForName("ammo_hornet"), 255);
		pl.GiveAmmo(ammoNumForName("ammo_m203_grenade"), 255);
#ifdef GEARBOX
		pl.GiveItem("weapon_displacer");
		pl.GiveItem("weapon_eagle");
		pl.GiveItem("weapon_grapple");
		pl.GiveItem("weapon_knife");
		pl.GiveItem("weapon_m249");
		pl.GiveItem("weapon_penguin");
		pl.GiveItem("weapon_pipewrench");
		pl.GiveItem("weapon_shockrifle");
		pl.GiveItem("weapon_sniperrifle");
		pl.GiveItem("weapon_sporelauncher");
		pl.GiveAmmo(ammoNumForName("ammo_556"), 255);
		pl.GiveAmmo(ammoNumForName("ammo_762"), 255);
		pl.GiveAmmo(ammoNumForName("ammo_spore"), 255);
		pl.GiveAmmo(ammoNumForName("ammo_shock"), 255);
		pl.GiveAmmo(ammoNumForName("ammo_penguin"), 255);
#endif
		break;
	default:
		return super::ImpulseCommand(pl, num);
	}

	return true;
}
