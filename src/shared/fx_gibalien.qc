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
string g_agibs[] = {
	"models/agibs.mdl",
	"models/agibs.mdl",
	"models/agibs.mdl",
	"models/agibs.mdl",
	"models/agibs.mdl"
};

void
FX_GibAlien_Init(void)
{
	for (int i = 0; i < g_agibs.length; i++)
		precache_model(g_agibs[i]);

	precache_sound("common/bodysplat.wav");
}
#endif

void
FX_GibAlien(vector vecOrigin, vector vecDir, float flForce)
{
#ifdef SERVER
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_GIBALIEN);
	WriteCoord(MSG_MULTICAST, vecOrigin[0]);
	WriteCoord(MSG_MULTICAST, vecOrigin[1]);
	WriteCoord(MSG_MULTICAST, vecOrigin[2]);
	WriteCoord(MSG_MULTICAST, vecDir[0]);
	WriteCoord(MSG_MULTICAST, vecDir[1]);
	WriteCoord(MSG_MULTICAST, vecDir[2]);
	WriteFloat(MSG_MULTICAST, flForce);
	msg_entity = __NULL__;
	multicast(vecOrigin, MULTICAST_PVS);
#else
	static void Gib_Remove(void) {
		remove(self);
	}
	static void Gib_Touch(void)
	{
		if (serverkeyfloat("*bspversion") == BSPVER_HL)
			Decals_Place(self.origin, sprintf("{yblood%d", floor(random(1,7))));
		else {
			decal_pickwall(self, self.origin);
			pointparticles(DECAL_BLOOD, g_tracedDecal.endpos, g_tracedDecal.normal, 1);
		}
	}

	if (cvar("violence_agibs") <= 0) {
		return;
	}

	makevectors(vecDir);
	vecDir = v_forward;

	for (int i = 0; i < 5; i++) {
		vector vel = vecDir;
		vel += random(-1,1) * v_right;
		vel += random(-1,1) * v_up;
		vel *= flForce;
		vel += [0,0,80];

		entity gibb = spawn();
		setmodel(gibb, g_agibs[i]);
		setorigin(gibb, vecOrigin);
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
	pointsound(vecOrigin, "common/bodysplat.wav", 1, ATTN_NORM);
#endif
} 
