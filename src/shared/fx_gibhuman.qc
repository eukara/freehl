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
string g_hgibs[] = {
	"models/gib_b_bone.mdl",
	"models/gib_legbone.mdl",
	"models/gib_lung.mdl",
	"models/gib_skull.mdl",
	"models/gib_b_gib.mdl"
};

void
FX_GibHuman_Init(void)
{
	precache_model("models/gib_b_bone.mdl");
	precache_model("models/gib_legbone.mdl");
	precache_model("models/gib_lung.mdl");
	precache_model("models/gib_skull.mdl");
	precache_model("models/gib_b_gib.mdl");
	precache_sound("common/bodysplat.wav");
}
#endif

void
FX_GibHuman(vector pos)
{
#ifdef SERVER
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_GIBHUMAN);
	WriteCoord(MSG_MULTICAST, pos[0]); 
	WriteCoord(MSG_MULTICAST, pos[1]); 
	WriteCoord(MSG_MULTICAST, pos[2]);
	msg_entity = __NULL__;
	multicast(pos, MULTICAST_PVS);
#else
	static void Gib_Remove(void) {
		remove(self);
	}
	static void Gib_Touch(void)
	{
		if (serverkeyfloat("*bspversion") == BSPVER_HL)
			Decals_Place(self.origin, sprintf("{blood%d", floor(random(1,9))));
		else {
			decal_pickwall(self, self.origin);
			pointparticles(DECAL_BLOOD, g_tracedDecal.endpos, g_tracedDecal.normal, 1);
		}
	}

	if (cvar("violence_hgibs") <= 0) {
		return;
	}

	for (int i = 0; i < 5; i++) {
		vector vel;
		vel[0] = random(-128,128);
		vel[1] = random(-128,128);
		vel[2] = (300 + random() * 64);

		entity gibb = spawn();
		setmodel(gibb, g_hgibs[i]);
		setorigin(gibb, pos);
		gibb.movetype = MOVETYPE_BOUNCE;
		gibb.solid = SOLID_BBOX;
		setsize(gibb, [0,0,0], [0,0,0]);
		gibb.velocity = vel;
		gibb.avelocity = vectoangles(gibb.velocity);
		gibb.think = Gib_Remove;
		gibb.touch = Gib_Touch;
		gibb.nextthink = time + 5.0f;
		gibb.drawmask = MASK_ENGINE;
	}
	pointsound(pos, "common/bodysplat.wav", 1, ATTN_NORM);
#endif
} 
