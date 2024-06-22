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

#define PMOVE_AIRSTEPHEIGHT 0
#define PMOVE_STEPHEIGHT 18
#define PMOVE_FRICTION 4
#define PMOVE_EDGEFRICTION 1
#define PMOVE_STOPSPEED 100
#define PMOVE_GRAVITY 800
#define PMOVE_AIRACCELERATE 10
#define PMOVE_WATERACCELERATE 10
#define PMOVE_ACCELERATE 10
#define PMOVE_STEP_WALKSPEED 270
#define PMOVE_STEP_CROUCHSPEED 90
#define PMOVE_BOXCENTER true
#define PMOVE_NORMAL_HEIGHT 72
#define PMOVE_NORMAL_VIEWHEIGHT 64
#define PMOVE_CROUCH_HEIGHT 36
#define PMOVE_CROUCH_VIEWHEIGHT 30

/* disable prone, run and lean */
#define PMOVE_STEP_RUNSPEED 0
#define PMOVE_PRONE_HEIGHT 0

void
HLPlayer::Physics_Jump(void)
{
	if (waterlevel >= 2) {
		if (watertype == CONTENT_WATER) {
			velocity[2] = 100;
		} else if (watertype == CONTENT_SLIME) {
			velocity[2] = 80;
		} else {
			velocity[2] = 50;
		}
	} else {
		/* Half-Life: Longjump module */
		if (IsCrouching() && HasItem("item_longjump")) {
			makevectors([0, v_angle[1], 0]);
			velocity = v_forward * 512;
			velocity[2] += 100;
		}
		if (flags & FL_ONGROUND)
			velocity[2] += 265;
	}
}
