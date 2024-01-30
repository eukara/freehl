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

class item_weaponbox:NSRenderableEntity
{
	int ammo_9mm;
	int ammo_357;
	int ammo_buckshot;
	int ammo_m203_grenade;
	int ammo_bolt;
	int ammo_rocket;
	int ammo_uranium;
	int ammo_handgrenade;
	int ammo_satchel;
	int ammo_tripmine;
	int ammo_snark;
	int ammo_hornet;
	int weapon_items;

#ifdef GEARBOX
	int ammo_556;
	int ammo_penguin;
	int ammo_762;
	int ammo_spore;
	int ammo_shock;
#endif

	void(void) item_weaponbox;

	virtual void(void) Spawned;
	virtual void(entity) Touch;
	virtual void(player) setup;
};

void
item_weaponbox::Touch(entity eToucher)
{
	if (eToucher.classname != "player") {
		return;
	}

	player pl = (player)eToucher;
	Logging_Pickup(eToucher, this, __NULL__);
	StartSoundDef("item_weaponbox.Pickup", CHAN_ITEM, true);

	pl.ammo_9mm += ammo_9mm;
	pl.ammo_357 += ammo_357;
	pl.ammo_buckshot += ammo_buckshot;
	pl.ammo_m203_grenade += ammo_m203_grenade;
	pl.ammo_bolt += ammo_bolt;
	pl.ammo_rocket += ammo_rocket;
	pl.ammo_uranium += ammo_uranium;
	pl.ammo_handgrenade += ammo_handgrenade;
	pl.ammo_satchel += ammo_satchel;
	pl.ammo_tripmine += ammo_tripmine;
	pl.ammo_snark += ammo_snark;
	pl.ammo_hornet += ammo_hornet;

#ifdef GEARBOX
	pl.ammo_556 += ammo_556;
	pl.ammo_762 += ammo_762;
	pl.ammo_spore += ammo_spore;
	pl.ammo_shock += ammo_shock;
	pl.ammo_penguin += ammo_penguin;

	pl.ammo_556 = min(pl.ammo_556, MAX_A_556);
	pl.ammo_penguin = min(pl.ammo_penguin, MAX_A_PENGUIN);
	pl.ammo_762 = min(pl.ammo_762, MAX_A_762);
	pl.ammo_spore = min(pl.ammo_spore, MAX_A_SPORE);
	pl.ammo_shock = min(pl.ammo_shock, MAX_A_SHOCK);
#endif

	/* cull */
	pl.ammo_9mm = min(pl.ammo_9mm, MAX_A_9MM);
	pl.ammo_357 = min(pl.ammo_357, MAX_A_357);
	pl.ammo_buckshot = min(pl.ammo_buckshot, MAX_A_BUCKSHOT);
	pl.ammo_m203_grenade = min(pl.ammo_m203_grenade, MAX_A_M203_GRENADE);
	pl.ammo_bolt = min(pl.ammo_bolt, MAX_A_BOLT);
	pl.ammo_rocket = min(pl.ammo_rocket, MAX_A_ROCKET);
	pl.ammo_uranium = min(pl.ammo_uranium, MAX_A_URANIUM);
	pl.ammo_handgrenade = min(pl.ammo_handgrenade, MAX_A_HANDGRENADE);
	pl.ammo_satchel = min(pl.ammo_satchel, MAX_A_SATCHEL);
	pl.ammo_tripmine = min(pl.ammo_tripmine, MAX_A_TRIPMINE);
	pl.ammo_snark = min(pl.ammo_snark, MAX_A_SNARK);
	pl.ammo_hornet = min(pl.ammo_hornet, MAX_A_HORNET);

	pl.g_items |= weapon_items;
	Weapons_RefreshAmmo(pl);

	Destroy();
}

void
item_weaponbox::setup(player pl)
{
	/* TODO: Should the magazine bits be transferred too? */
	ammo_9mm = pl.ammo_9mm;
	ammo_357 = pl.ammo_357;
	ammo_buckshot = pl.ammo_buckshot;
	ammo_m203_grenade = pl.ammo_m203_grenade;
	ammo_bolt = pl.ammo_bolt;
	ammo_rocket = pl.ammo_rocket;
	ammo_uranium = pl.ammo_uranium;
	ammo_handgrenade = pl.ammo_handgrenade;
	ammo_satchel = pl.ammo_satchel;
	ammo_tripmine = pl.ammo_tripmine;
	ammo_snark = pl.ammo_snark;
	ammo_hornet = pl.ammo_hornet;
	weapon_items = pl.g_items;

#ifdef GEARBOX
	ammo_556 = pl.ammo_556;
	ammo_762 = pl.ammo_762;
	ammo_spore = pl.ammo_spore;
	ammo_shock = pl.ammo_shock;
	ammo_penguin = pl.ammo_penguin;
#endif

	/* none of this! */
	if (ammo_satchel == 0 && pl.g_items & ITEM_SATCHEL)
		weapon_items &= ~ITEM_SATCHEL;
	if (ammo_handgrenade == 0 && pl.g_items & ITEM_HANDGRENADE)
		weapon_items &= ~ITEM_HANDGRENADE;
	if (ammo_snark == 0 && pl.g_items & ITEM_SNARK)
		weapon_items &= ~ITEM_SNARK;
	if (ammo_tripmine == 0 && pl.g_items & ITEM_TRIPMINE)
		weapon_items &= ~ITEM_TRIPMINE;

#ifdef GEARBOX
	if (ammo_tripmine == 0 && pl.g_items & ITEM_PENGUIN)
		weapon_items &= ~ITEM_PENGUIN;
#endif
}

void
item_weaponbox::Spawned(void)
{
	super::Spawned();

	SetModel("models/w_weaponbox.mdl");
	SetSize([-16,-16,0], [16,16,16]);
	SetSolid(SOLID_TRIGGER);
	SetMovetype(MOVETYPE_TOSS);
}

void
item_weaponbox::item_weaponbox(void)
{
	botinfo = BOTINFO_AMMO;
}

void
weaponbox_spawn(player spawner)
{
	item_weaponbox weaponbox = spawn(item_weaponbox);
	weaponbox.Spawned();
	weaponbox.SetOrigin(spawner.origin);
	weaponbox.setup(spawner);
}
