/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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
	if (cvar("sv_playerslots") == 1 || cvar("coop") == 1) {
		g_grMode = spawn(HLSingleplayerRules);
	} else {
		g_grMode = spawn(HLMultiplayerRules);
	}
}

void
Game_Worldspawn(void)
{
	Sound_Precache("ammo.pickup");
	Sound_Precache("ammo.respawn");
	Sound_Precache("player.die");
	Sound_Precache("player.fall");
	Sound_Precache("player.lightfall");

	precache_model("models/player.mdl");
	precache_model("models/w_weaponbox.mdl");
	Weapons_Init();
	Player_Precache();
}
