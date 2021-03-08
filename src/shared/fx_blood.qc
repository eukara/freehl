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
		if (serverkeyfloat("*bspversion") == BSPVER_HL)
			Decals_Place(self.origin, sprintf("{blood%d", floor(random(1,9))));
		else {
			decal_pickwall(self, self.origin);
			pointparticles(DECAL_BLOOD, g_tracedDecal.endpos, g_tracedDecal.normal, 1);
		}
	}

	if (cvar("violence_hblood") <= 0) {
		return;
	}

	env_sprite eBlood = spawn(env_sprite);
	setorigin(eBlood, pos);
	setmodel(eBlood, "sprites/bloodspray.spr");

	eBlood.drawmask = MASK_ENGINE;
	eBlood.maxframe = modelframecount(eBlood.modelindex);
	eBlood.loops = 0;
	eBlood.scale = 1.0f;

#ifdef GS_RENDERFX
	eBlood.m_vecRenderColor = color;
#else
	eBlood.colormod = color;
#endif

	eBlood.framerate = 20;
	eBlood.nextthink = time + 0.05f;

	for (int i = 0; i < 3; i++) {
		env_sprite ePart = spawn(env_sprite);
		setorigin(ePart, pos);
		setmodel(ePart, "sprites/blood.spr");
		ePart.movetype = MOVETYPE_BOUNCE;
		ePart.gravity = 0.5f;
		ePart.scale = 0.5f;
		ePart.drawmask = MASK_ENGINE;
		ePart.maxframe = modelframecount(ePart.modelindex);
		ePart.loops = 0;

#ifdef GS_RENDERFX
		ePart.m_vecRenderColor = color;
#else
		ePart.colormod = color;
#endif
		ePart.framerate = 15;
		ePart.nextthink = time + 0.1f;
		ePart.velocity = randomvec() * 64;
		ePart.touch = Blood_Touch;
		ePart.solid = SOLID_BBOX;
		/* ignore player physics */
		ePart.dimension_solid = 1;
		ePart.dimension_hit = 1;
		setsize(ePart, [0,0,0], [0,0,0]);
	}
#endif
}
