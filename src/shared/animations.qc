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

.float baselerpfrac;
.float lerpfrac;
.float frame_time;
.float frame_old;
.float fWasCrouching;
.float frame2time;
.float frame2;
.float baseframe2time;
.float baseframe1time;
.float baseframe2;

// For lerping, sigh
.float frame_last;
.float baseframe_last;
.float subblendfrac;
.float subblend2frac;

void Animation_Print(string sWow) {
#ifdef CLIENT
	print(sprintf("[DEBUG] %s", sWow));
#else 
	bprint(PRINT_HIGH, sprintf("SSQC: %s", sWow) );
#endif	
}

var int autocvar_bone_spinebone = 0;
var int autocvar_bone_baseframe = 0;
var int autocvar_bone_frame = 0;
/*
=================
Animation_PlayerUpdate

Called every frame to update the animation sequences
depending on what the player is doing
=================
*/
void
Animation_PlayerUpdate(void)
{
	self.basebone = gettagindex(self, "Bip01 Spine1");

	// TODO: Make this faster
	if (self.frame_time < time) {
		player pl = (player)self;
		self.frame = Weapons_GetAim(pl.activeweapon);
		self.frame_old = self.frame;
	}

	/* in order to appear jumping, we want to not be on ground, 
	 * but also make sure we're not just going down a ramp */
	if (!(self.flags & FL_ONGROUND) && (self.velocity[2] > 0 || self.baseframe == ANIM_JUMP)) {
		self.baseframe = ANIM_JUMP;
	} else if (vlen(self.velocity) == 0) {
		if (self.flags & FL_CROUCHING) {
			self.baseframe = ANIM_CROUCHIDLE;
		} else {
			self.baseframe = ANIM_IDLE;
		}
	} else if (vlen(self.velocity) < 150) {
		if (self.flags & FL_CROUCHING) {
			self.baseframe = ANIM_CRAWL;
		} else {
			self.baseframe = ANIM_WALK;
		}
	} else if (vlen(self.velocity) > 150) {
		if (self.flags & FL_CROUCHING) {
			self.baseframe = ANIM_CRAWL;
		} else {
			self.baseframe = ANIM_RUN;
		}
	}

	// Lerp it down!
	if (self.lerpfrac > 0) {
		self.lerpfrac -= frametime * 5;
		if (self.lerpfrac < 0) {
			self.lerpfrac = 0;
		}
	}

	if (self.baselerpfrac > 0) {
		self.baselerpfrac -= frametime * 5;
		if (self.baselerpfrac < 0) {
			self.baselerpfrac = 0;
		}
	}

	if (self.frame != self.frame_last) {
		//Animation_Print(sprintf("New Frame: %d, Last Frame: %d\n", self.frame, self.frame_last));
		
		// Move everything over to frame 2
		self.frame2time = self.frame1time;
		self.frame2 = self.frame_last;
		
		// Set frame_last to avoid this being called again
		self.frame_last = self.frame;
		
		self.lerpfrac = 1.0f;
		self.frame1time = 0.0f;
	}
	
	if (self.baseframe != self.baseframe_last) {
		//Animation_Print(sprintf("New Baseframe: %d, Last Baseframe: %d\n", self.baseframe, self.baseframe_last));
		
		// Move everything over to frame 2
		self.baseframe2time = self.baseframe1time;
		self.baseframe2 = self.baseframe_last;
		
		// Set frame_last to avoid this being called again
		self.baseframe_last = self.baseframe;
		
		self.baselerpfrac = 1.0f;
		self.baseframe1time = 0.0f;
	}
	
	self.subblend2frac = self.angles[0];

	self.angles[0] = self.angles[2] = 0;
	
	if (!(self.flags & FL_ONGROUND)) {
		/*self.frame = ANIM_JUMP;*/
	}
	
	// Force the code above to update if we switched positions
	if (self.fWasCrouching != (self.flags & FL_CROUCHING)) {
		self.frame_old = 0;
		self.frame_time = 0;
		self.fWasCrouching = (self.flags & FL_CROUCHING);
	}

#ifndef CLIENT
	// On the CSQC it's done in Player.c
	self.subblendfrac = 
	self.subblend2frac = self.v_angle[0] / 90;
#endif
}

/*
=================
Animation_PlayerTop

Changes the animation sequence for the upper body part
=================
*/
void
Animation_PlayerTop(float fFrame)
{
#ifndef CLIENT
	self.frame = fFrame;
	self.frame_old = fFrame;
#endif
}

void
Animation_PlayerTopTemp(float fFrame, float fTime)
{
#ifndef CLIENT
	self.frame = fFrame;
	self.frame_time = time + fTime;
	self.SendFlags |= PLAYER_FRAME;
#endif
}
