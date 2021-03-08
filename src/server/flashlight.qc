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

void Flashlight_Toggle(void)
{
	if (cvar("sv_playerslots") != 1) {
		if (cvar("mp_flashlight") != 1) {
			return;
		}
	}

#ifdef VALVE
	player pl = (player)self;
	if (!(pl.g_items & ITEM_SUIT)) {
		return;
	}
#endif

	if (self.health <= 0) {
		return;
	}

	if (self.gflags & GF_FLASHLIGHT) {
		self.gflags &= ~GF_FLASHLIGHT;
	} else {
		self.gflags |= GF_FLASHLIGHT;
	}
	sound(self, CHAN_ITEM, "items/flashlight1.wav", 1, ATTN_IDLE);
}
