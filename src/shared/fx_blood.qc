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

#ifdef CLIENT
var float PARTICLE_BLOOD;
var int DECAL_BLOOD;

void
FX_Blood_Init(void)
{
	precache_model("sprites/bloodspray.spr");
	precache_model("sprites/blood.spr");
	PARTICLE_BLOOD = particleeffectnum("part_blood");
	DECAL_BLOOD = particleeffectnum("decal_blood.effect");
}
#endif

void
FX_Blood(vector pos, vector color)
{
#ifdef SERVER
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_BLOOD);
	WriteCoord(MSG_MULTICAST, pos[0]);
	WriteCoord(MSG_MULTICAST, pos[1]);
	WriteCoord(MSG_MULTICAST, pos[2]);
	WriteByte(MSG_MULTICAST, color[0] * 255);
	WriteByte(MSG_MULTICAST, color[1] * 255);
	WriteByte(MSG_MULTICAST, color[2] * 255);
	msg_entity = self;
	multicast(pos, MULTICAST_PVS);
#else
	static void Blood_Touch(void)
	{
		if (self.think != NSEntity::Destroy) {
		if (serverkeyfloat("*bspversion") == BSPVER_HL)
			Decals_Place(self.origin, sprintf("{blood%d", floor(random(1,9))));
		else {
			decal_pickwall(self, self.origin);
			pointparticles(DECAL_BLOOD, g_tracedDecal.endpos, g_tracedDecal.normal, 1);
		}
		}

		self.think = NSEntity::Destroy;
		self.nextthink = time + 5.0f;
	}
	static void ABlood_Touch(void)
	{
		if (self.think != NSEntity::Destroy) {
		if (serverkeyfloat("*bspversion") == BSPVER_HL)
			Decals_Place(self.origin, sprintf("{yblood%d", floor(random(1,9))));
		else {
			decal_pickwall(self, self.origin);
			pointparticles(DECAL_BLOOD, g_tracedDecal.endpos, g_tracedDecal.normal, 1);
		}
		}

		self.think = NSEntity::Destroy;
		self.nextthink = time + 5.0f;
	}

	if (cvar("violence_hblood") <= 0) {
		return;
	}

	env_sprite eBlood = spawn(env_sprite);
	eBlood.SetOrigin(pos);
	eBlood.SetModel("sprites/bloodspray.spr");
	eBlood.SetMaxFrame(modelframecount(eBlood.modelindex));
	eBlood.SetFramerate(20);
	eBlood.SetLoopFlag(false);
	eBlood.SetScale(0.25f);
	eBlood.SetRenderColor(color);
	eBlood.SetRenderMode(RM_COLOR);
	eBlood.SetRenderAmt(1.0f);
	eBlood.nextthink = time + 0.05f;

	for (int i = 0; i < 3; i++) {
		NSRenderableEntity ePart = spawn(NSRenderableEntity);
		ePart.SetOrigin(pos);
		ePart.SetModel("sprites/blood.spr");
		ePart.SetMovetype(MOVETYPE_BOUNCE);
		ePart.SetGravity(0.5f);
		ePart.SetScale(0.25f);
		ePart.SetFrame((random() < 0.5) ? 0 : 1);
		ePart.SetRenderColor(color);
		ePart.SetRenderMode(RM_COLOR);
		ePart.SetRenderAmt(1.0f);
		ePart.SetVelocity(randomvec() * 96 + [0,0,64]);
		ePart.SetSolid(SOLID_BBOX);
		ePart.SetSize([0,0,0], [0,0,0]);

		if (color[1] != 0 && color[2] != 0)
			ePart.touch = ABlood_Touch;
		else
			ePart.touch = Blood_Touch;

		/* ignore player physics */
		ePart.dimension_solid = 1;
		ePart.dimension_hit = 1;
		ePart.hitcontentsmaski = 0;
	}
#endif
}
