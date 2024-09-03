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
Game_InitRules(void)
{
	Player_Precache();
	FX_Corpse_Init();
	
	if (cvar("sv_playerslots") == 1 || cvar("coop") == 1) {
		g_grMode = NSGameRules::InitFromProgs("maps/singleplayer.dat");
	} else {
		g_grMode = NSGameRules::InitFromProgs("maps/mp/gametypes/dm.dat");
	}
}

void
Game_Worldspawn(void)
{
	Sound_Precache("Player.FlashLightOff");
	Sound_Precache("Player.FlashLightOn");
	Sound_Precache("item_weaponbox.Pickup");
	precache_model("models/player.mdl");
	precache_model("models/w_weaponbox.mdl");
}
