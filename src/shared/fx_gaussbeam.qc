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
var float TRAIL_GAUSSBEAM;

void FX_GaussBeam(vector, vector, int, entity);

void
FX_GaussBeam_Init(void)
{
	TRAIL_GAUSSBEAM = particleeffectnum("weapon_gauss.beam");
	precache_model("sprites/yelflare1.spr");
	precache_model("sprites/yelflare2.spr");
	Sound_Precache("fx.gaussbeam");
}

void
FX_GaussBeam_Parse(void)
{
	vector pos, angle;
	int beams;
	entity eowner;

	pos[0] = readcoord();
	pos[1] = readcoord();
	pos[2] = readcoord();

	angle[0] = readcoord();
	angle[1] = readcoord();
	angle[2] = readcoord();
	beams = (int)readbyte();
	
	eowner = findfloat(world, ::entnum, readentitynum());

	FX_GaussBeam(pos, angle, beams, eowner);
}

void
FX_GaussBeam_Piece(vector vecPos, vector vecFlyDir)
{
	static float FX_GaussBeam_Piece_Fade(void) {
		dynamiclight_add(self.origin, 256 * self.alpha, [1.0,0.5,0]);

		self.alpha -= frametime * 0.25;

		if (self.alpha <= 0.0f) {
			remove(self);
		} else {
			addentity(self);
		}

		return (PREDRAW_NEXT);
	}
	static float FX_GaussBeam_SubPiece_Fade(void) {
		self.alpha -= frametime * 0.25;

		if (self.alpha <= 0.0f) {
			remove(self);
		} else {
			addentity(self);
		}

		return (PREDRAW_NEXT);
	}

	entity piece = spawn();
	setorigin(piece, vecPos);
	setmodel(piece, "sprites/yelflare1.spr");
	piece.movetype = MOVETYPE_NONE;
	piece.solid = SOLID_NOT;
	piece.colormod = [1.0,0.5,0.0];
	piece.drawmask = MASK_ENGINE;
	piece.velocity = vecFlyDir;
	piece.alpha = 1.0f;
	piece.predraw = FX_GaussBeam_Piece_Fade;
	piece.effects = EF_ADDITIVE;
	Decals_Place(vecPos, sprintf("{shot%d", floor(random(1,6))));

	float r = random();

	Sound_PlayAt(vecPos, "fx.gaussbeam");

	for (int i = 0; i < 4; i++) {
		entity sub = spawn();
		setorigin(sub, vecPos);
		setmodel(sub, "sprites/yelflare2.spr");
		setsize(sub,[-2,-2,-2], [2,2,2]);
		sub.movetype = MOVETYPE_BOUNCE;
		sub.solid = SOLID_NOT;
		sub.colormod = [1.0,0.5,0.0];
		sub.drawmask = MASK_ENGINE;
		sub.velocity[0] = random()*100;
		sub.velocity[1] = random()*100;
		sub.velocity[2] = random()*100;
		sub.alpha = 1.0f;
		sub.gravity = 0.1f;
		sub.predraw = FX_GaussBeam_SubPiece_Fade;
		sub.effects = EF_ADDITIVE;
	}
}
#endif

void
FX_GaussBeam(vector vecPos, vector vecAngle, int numBeams, entity eOwner)
{
#ifdef SERVER
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_GAUSSBEAM);
	WriteCoord(MSG_MULTICAST, vecPos[0]); 
	WriteCoord(MSG_MULTICAST, vecPos[1]); 
	WriteCoord(MSG_MULTICAST, vecPos[2]);
	WriteFloat(MSG_MULTICAST, vecAngle[0]); 
	WriteFloat(MSG_MULTICAST, vecAngle[1]); 
	WriteFloat(MSG_MULTICAST, vecAngle[2]);
	WriteByte(MSG_MULTICAST, numBeams);
	WriteEntity(MSG_MULTICAST, eOwner);

	msg_entity = self;
	multicast(vecPos, MULTICAST_PVS);
#else
	vector vecSrc;
	vector vecEndPos;
	vector vecDir;
	vector vecCurPlane;
	vector vecCurPos;
	int totalBeams = numBeams;

	makevectors(vecAngle);
	vecDir = v_forward;
	vecSrc = vecPos;
	vecEndPos = vecSrc + v_forward * 1024;
	traceline(vecSrc, vecEndPos, FALSE, eOwner);
	vecCurPlane = trace_plane_normal;
	vecCurPos = trace_endpos;
	trailparticles(TRAIL_GAUSSBEAM, eOwner, vecSrc + (v_right * 8) + (v_up * -12), trace_endpos);
	FX_GaussBeam_Piece(trace_endpos, vecDir * -1);
	Decals_Place(trace_endpos, "{gaussshot1");

	makevectors(vecAngle);
	vecDir = v_forward;
	trace_plane_normal = vecCurPlane;
	trace_endpos = vecCurPos;

	while (numBeams > 0) {
		vector newDir;
		trace_plane_normal = vecCurPlane;
		trace_endpos = vecCurPos;
		newDir = vecDir - 2 * (vecDir * trace_plane_normal) * trace_plane_normal;
		vecDir = newDir;
		vecSrc = trace_endpos + (vecDir * -1);
		vecEndPos = trace_endpos + (vecDir * 8192);
		traceline(vecSrc, vecEndPos, FALSE, eOwner);
		vecCurPlane = trace_plane_normal;
		vecCurPos = trace_endpos;

		trailparticles(TRAIL_GAUSSBEAM, eOwner, vecSrc, trace_endpos);
		FX_GaussBeam_Piece(trace_endpos, vecDir);
		numBeams--;

#if 1
		if (serverkeyfloat("*bspversion") == BSPVER_HL)
			if (getsurfacetexture(trace_ent, getsurfacenearpoint(trace_ent, trace_endpos)) != "sky") {
				Decals_Place(trace_endpos, "{gaussshot1");
			} else {
				break;
			}
#endif
	}

#endif
}

