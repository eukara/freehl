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
GamePMove_WaterMove(player target)
{
	if (target.movetype == MOVETYPE_NOCLIP) {
		return;
	}

#ifdef SERVER
	if (target.health < 0) {
		return;
	}

	/* we've just exited water */
	if (target.waterlevel != 3) {
		if (target.underwater_time < time) {
			Sound_Play(target, CHAN_BODY, "player.gasplight");
		} else if (target.underwater_time < time + 9) {
			Sound_Play(target, CHAN_BODY, "player.gaspheavy");
		}
		target.underwater_time = time + 12;
	} else if (target.underwater_time < time) {
		/* we've been underwater... for too long. */
		if (target.pain_time < time) {
			Damage_Apply(target, world, 5, DMG_DROWN, 0);
			target.pain_time = time + 1;
		}
	}
#endif

	if (!target.waterlevel){
		if (target.flags & FL_INWATER) {
#ifdef SERVER
			Sound_Play(target, CHAN_BODY, "player.waterexit");
#endif
			target.flags &= ~FL_INWATER;
		}
		return;
	}

#ifdef SERVER
	if (target.watertype == CONTENT_LAVA) {
		if (target.pain_time < time) {
			target.pain_time = time + 0.2;
			Damage_Apply(target, world, 10*target.waterlevel, DMG_BURN, 0);
		}
	} else if (target.watertype == CONTENT_SLIME) {
		if (target.pain_time < time) {
			target.pain_time = time + 1;
			Damage_Apply(target, world, 4*target.waterlevel, DMG_ACID, 0);
		}
	}
#endif

	if (!(target.flags & FL_INWATER)) {
#ifdef SERVER
		Sound_Play(target, CHAN_BODY, "player.waterenter");
		target.pain_time = 0;
#endif
		target.flags |= FL_INWATER;
	}
}
 
