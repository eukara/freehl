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

void Weapons_Draw(player pl);

void
CSEv_PlayerSwitchWeapon_i(int w)
{
	player pl = (player)self;

	if (pl.activeweapon != w) {
		pl.activeweapon = w;
		Weapons_Draw(pl);
	}
}

void
Player_Precache(void)
{
	searchhandle pm;
	pm = search_begin("models/player/*/*.mdl", TRUE, TRUE);
	for (int i = 0; i < search_getsize(pm); i++) {
		precache_model(search_getfilename(pm, i));
	}
	search_end(pm);
}
