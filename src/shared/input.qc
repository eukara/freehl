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

void
Game_Input(player pl)
{
#ifdef SERVER
	CGameRules rules = (CGameRules)g_grMode;

	if (rules.m_iIntermission) {
		rules.IntermissionEnd();
		return;
	}

	if (input_buttons & INPUT_BUTTON5)
		pl.InputUse_Down(); 
	else
		pl.InputUse_Up(); 

	if (pl.impulse == 100)
		Flashlight_Toggle();

	if (cvar("sv_cheats") == 1) {
		if (pl.impulse == 101) {
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
		}
	}

	pl.impulse = 0;
#endif

	NSVehicle veh = (NSVehicle)pl.vehicle;
	bool canfire = true;
	if (veh)
		if (veh.PreventPlayerFire() == true)
			canfire = false;

	if (canfire == false)
		return;

	if (input_buttons & INPUT_BUTTON0)
		Weapons_Primary(pl);
	else if (input_buttons & INPUT_BUTTON4)
		Weapons_Reload(pl);
	else if (input_buttons & INPUT_BUTTON3)
		Weapons_Secondary(pl);
	else
		Weapons_Release(pl);
}
