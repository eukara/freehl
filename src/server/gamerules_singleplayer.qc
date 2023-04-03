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
	pl.movetype = MOVETYPE_NONE;
	pl.solid = SOLID_NOT;
	pl.takedamage = DAMAGE_NO;
	pl.gflags &= ~GF_FLASHLIGHT;
	pl.armor = pl.activeweapon = pl.g_items = pl.weapon = 0;
	pl.health = 0;
	Sound_Play(pl, CHAN_AUTO, "player.die");

	if (cvar("coop") == 1) {
		pl.think = PutClientInServer;
		pl.nextthink = time + 4.0f;
	}

	if (pl.health < -50) {
		FX_GibHuman(pl.origin, vectoangles(pl.origin - g_dmg_eAttacker.origin), g_dmg_iDamage * 2.0f);
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
	pl.classname = "player";
	pl.health = pl.max_health = 100;
	pl.takedamage = DAMAGE_YES;
	pl.SetSolid(SOLID_SLIDEBOX);
	pl.SetMovetype(MOVETYPE_WALK);
	pl.flags = FL_CLIENT;
	pl.viewzoom = 1.0;
	pl.model = "models/player.mdl";


	if (cvar("coop") == 1) {
		string mymodel = infokey(pl, "model");
		if (mymodel) {
			mymodel = sprintf("models/player/%s/%s.mdl", mymodel, mymodel);
			if (whichpack(mymodel)) {
				pl.model = mymodel;
			}
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
	forceinfokey(pl, "*deaths", ftos(pl.deaths));

	/* this is where the mods want to deviate */
	entity spot;

	if (startspot != "") {
		dprint(sprintf("^3Gamerules_Spawn^7: Startspot is %s\n", startspot));
		LevelDecodeParms(pl);
		setorigin(pl, Landmark_GetSpot());
	} else {
		LevelNewParms();
		spot = find(world, ::classname, "info_player_start");
		setorigin(pl, spot.origin);
		pl.angles = spot.angles;
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
		pl.health = 100;
		pl.armor = 100;
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
