 /*
 * Copyright (c) 2016-2022 Marco Cawthorne <marco@icculus.org>
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

/*QUAKED weaponbox (0 0 0.8) (-16 -16 0) (16 16 32)

HALF-LIFE (1998) ENTITY

Ammo container. Used to delvier more than 1 singular ammo type, as well as
more precise control.

-------- KEYS --------
"targetname" : Name
"uranium"    : Amount of Uranium (Egon, Gauss) ammo to give
"357"        : Amount of 357 Python ammo to give
"9mm"        : Amount of 9mm Handgun/MP5 ammo to give
"ARgrenades" : Amount of MP5 grenades to give
"bolts"      : Amount of Crossbow bolts
"buckshot"   : Amount of Shotgun ammo to give
"rockets"    : Amount of RPG ammo to give
"556"        : (Oppossing Force only) Amount for the SAW Machine Gun
"762"        : (Oppossing Force only) Amount for the Sniper Rifle
"spore"      : (Oppossing Force only) Amount for the Spore Launcher


-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/models/w_weaponbox.mdl"
*/

class
weaponbox:item_weaponbox
{
	void(void) weaponbox;

	virtual void(string, string) SpawnKey;
};

void
weaponbox::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "uranium":
		ammo_uranium = stoi(strValue);
		break;
	case "357":
		ammo_357 = stoi(strValue);
		break;
	case "9mm":
		ammo_9mm = stoi(strValue);
		break;
	case "ARgrenades":
		ammo_m203_grenade = stoi(strValue);
		break;
	case "bolts":
		ammo_bolt = stoi(strValue);
		break;
	case "buckshot":
		ammo_buckshot = stoi(strValue);
		break;
	case "rockets":
		ammo_rocket = stoi(strValue);
		break;
#ifdef GEARBOX
	case "556":
		ammo_556 = stoi(strValue);
		break;
	case "762":
		ammo_762 = stoi(strValue);
		break;
	case "spore":
		ammo_spore = stoi(strValue);
		break;
#endif
	}
}

void
weaponbox::weaponbox(void)
{
	// do nothing
}
