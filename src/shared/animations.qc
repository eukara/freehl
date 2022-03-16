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

.float subblend2frac;
.float subblendfrac;
.float baseframe1time;
.float bonecontrol1;
.float bonecontrol2;
.float bonecontrol3;
.float bonecontrol4;

void Animation_Print(string sWow) {
#ifdef CLIENT
	print(sprintf("[DEBUG] %s", sWow));
#else 
	bprint(PRINT_HIGH, sprintf("SSQC: %s", sWow) );
#endif	
}

void
Animation_TimerUpdate(player pl, float ftime)
{
	makevectors([0, pl.v_angle[1], 0]);

	/* top animation is always just being incremented */
	pl.anim_top_time += ftime;
	pl.anim_top_delay -= ftime;

	/* we may be walking backwards, thus decrement bottom */
	if (dotproduct(pl.velocity, v_forward) < 0) {
		pl.anim_bottom_time -= ftime;
	} else {
		pl.anim_bottom_time += ftime;
	}
}

/*
=================
Animation_PlayerUpdate

Called every frame to update the animation sequences
depending on what the player is doing
=================
*/
void
Animation_PlayerUpdate(player pl)
{
	pl.basebone = gettagindex(pl, "Bip01 Spine1");

	if (pl.anim_top_delay <= 0.0f) {
		pl.anim_top = Weapons_GetAim(pl, pl.activeweapon);
	}

	if (vlen(pl.velocity) == 0) {
		if (pl.flags & FL_CROUCHING) {
			pl.anim_bottom = ANIM_CROUCHIDLE;
		} else {
			pl.anim_bottom = ANIM_IDLE;
		}
	} else if (vlen(pl.velocity) < 150) {
		if (pl.flags & FL_CROUCHING) {
			pl.anim_bottom = ANIM_CRAWL;
		} else {
			pl.anim_bottom = ANIM_WALK;
		}
	} else if (vlen(pl.velocity) > 150) {
		if (pl.flags & FL_CROUCHING) {
			pl.anim_bottom = ANIM_CRAWL;
		} else {
			pl.anim_bottom = ANIM_RUN;
		}
	}

	pl.frame = pl.anim_top;
	pl.frame1time = pl.anim_top_time;
	pl.baseframe = pl.anim_bottom;
	pl.baseframe1time = pl.anim_bottom_time;

	/* hack, we can't play the animations in reverse the normal way */
	if (pl.frame1time < 0.0f) {
		pl.frame1time = 10.0f;
	}

	makevectors([0, pl.v_angle[1], 0]);
	float fCorrect = dotproduct(pl.velocity, v_right) * 0.25f;

	/* Turn torso */
	pl.bonecontrol1 = fCorrect;
	pl.bonecontrol2 = pl.bonecontrol1 * 0.5;
	pl.bonecontrol3 = pl.bonecontrol2 * 0.5;
	pl.bonecontrol4 = pl.bonecontrol3 * 0.5;

	/* Correct the legs */
	pl.angles[1] = pl.v_angle[1] - fCorrect;
	pl.angles[0] = pl.angles[2] = 0;

	pl.subblendfrac = 
	pl.subblend2frac = pl.v_angle[0] / 90;
}

void
Animation_PlayerTop(player pl, float topanim, float timer)
{
	pl.anim_top = topanim;
	pl.anim_top_time = 0.0f;
	pl.anim_top_delay = timer;
}

void
Animation_PlayerBottom(player pl, float botanim, float timer)
{
	pl.anim_bottom = botanim;
}
