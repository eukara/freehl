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

int
ClientGame_EntityUpdate(float id, float new)
{
	switch (id) {
	case ENT_TRIPMINE:
		NSENTITY_READENTITY(HLTripmine, new)
		break;
	case ENT_WEAPON:
		NSENTITY_READENTITY(HLWeapon, new)
		break;
	case ENT_PLAYER:
#ifdef GEARBOX
		NSENTITY_READENTITY(OP4Player, new)
#elif SCIHUNT
		NSENTITY_READENTITY(SHPlayer, new)
#else
		NSENTITY_READENTITY(HLPlayer, new)
#endif
		break;
	default:
		return (0);
	}

	return (1);
}
