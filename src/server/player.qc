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

/*
====================
UseWorkaround
====================
*/
void
UseWorkaround(entity eTarget)
{
	eActivator = self;
	entity eOldSelf = self;
	self = eTarget;
	self.PlayerUse();
	self = eOldSelf;
}

void
UnUseWorkaround(entity eTarget)
{
	eActivator = self;
	entity eOldSelf = self;
	self = eTarget;
	if (self.PlayerUseUnpressed)
		self.PlayerUseUnpressed();
	self = eOldSelf;
}

/*
====================
Player_UseDown
====================
*/
void
Player_UseDown(void)
{
	vector vecSrc;
	player pl = (player)self;

	if (self.health <= 0) {
		return;
	} else if (!(self.flags & FL_USE_RELEASED)) {
		return;
	}

	makevectors(self.v_angle);
	vecSrc = self.origin + self.view_ofs;

	int oldmask = self.hitcontentsmaski;
	self.hitcontentsmaski = CONTENTBITS_POINTSOLID;
	traceline(vecSrc, vecSrc + (v_forward * 64), MOVE_HITMODEL, self);
	self.hitcontentsmaski = oldmask;


	if (trace_ent.PlayerUse) {
		self.flags &= ~FL_USE_RELEASED;

		UseWorkaround(trace_ent);
		pl.last_used = trace_ent;

		/* Some entities want to support Use spamming */
		if (!(self.flags & FL_USE_RELEASED)) {
			sound(self, CHAN_ITEM, "common/wpn_select.wav", 0.25, ATTN_IDLE);
		}
	} else {
		sound(self, CHAN_ITEM, "common/wpn_denyselect.wav", 0.25, ATTN_IDLE);
		self.flags &= ~FL_USE_RELEASED;
	}
}

/*
====================
Player_UseUp
====================
*/
void
Player_UseUp(void) {
	player pl = (player)self;
	if (!(self.flags & FL_USE_RELEASED)) {
		UnUseWorkaround(pl.last_used);
		pl.last_used = world;
		self.flags |= FL_USE_RELEASED;
	}
}

void Weapons_Draw(void);

void
CSEv_PlayerSwitchWeapon_i(int w)
{
	player pl = (player)self;

	if (pl.activeweapon != w) {
		pl.activeweapon = w;
		Weapons_Draw();
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
