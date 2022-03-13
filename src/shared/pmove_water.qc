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
player::Physics_WaterMove(void)
{
	if (movetype == MOVETYPE_NOCLIP) {
		return;
	}

#ifdef SERVER
	if (health < 0) {
		return;
	}

	/* we've just exited water */
	if (waterlevel != 3) {
		if (underwater_time < time) {
			Sound_Play(this, CHAN_BODY, "player.gasplight");
		} else if (underwater_time < time + 9) {
			Sound_Play(this, CHAN_BODY, "player.gaspheavy");
		}
		underwater_time = time + 12;
	} else if (underwater_time < time) {
		/* we've been underwater... for too long. */
		if (pain_time < time) {
			Damage_Apply(this, world, 5, DMG_DROWN, 0);
			pain_time = time + 1;
		}
	}
#endif

	if (!waterlevel){
		if (flags & FL_INWATER) {
#ifdef SERVER
			Sound_Play(this, CHAN_BODY, "player.waterexit");
#endif
			flags &= ~FL_INWATER;
		}
		return;
	}

#ifdef SERVER
	if (watertype == CONTENT_LAVA) {
		if (pain_time < time) {
			pain_time = time + 0.2;
			Damage_Apply(this, world, 10*waterlevel, DMG_BURN, 0);
		}
	} else if (watertype == CONTENT_SLIME) {
		if (pain_time < time) {
			pain_time = time + 1;
			Damage_Apply(this, world, 4*waterlevel, DMG_ACID, 0);
		}
	}
#endif

	if (!(flags & FL_INWATER)) {
#ifdef SERVER
		Sound_Play(this, CHAN_BODY, "player.waterenter");
		pain_time = 0;
#endif
		flags |= FL_INWATER;
	}

	/* we might need to apply extra-velocity to get out of water-volumes */
	if (waterlevel >= 2) {
		Physics_WaterJump();
	}
}
