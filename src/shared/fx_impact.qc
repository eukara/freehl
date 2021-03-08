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
var int FX_IMPACT_BLACKBITS;
var int FX_IMPACT_SMOKE_BROWN;
var int FX_IMPACT_SMOKE_GREY;
var int FX_IMPACT_SPARK;

var int DECAL_IMPACT_DEFAULT;
var int DECAL_IMPACT_ALIEN;
var int DECAL_IMPACT_FLESH;
var int DECAL_IMPACT_FOLIAGE;
var int DECAL_IMPACT_COMPUTER;
var int DECAL_IMPACT_DIRT;
var int DECAL_IMPACT_VENT;
var int DECAL_IMPACT_GRATE;
var int DECAL_IMPACT_METAL;
var int DECAL_IMPACT_GLASS;
var int DECAL_IMPACT_SAND;
var int DECAL_IMPACT_SLOSH;
var int DECAL_IMPACT_SNOW;
var int DECAL_IMPACT_TILE;
var int DECAL_IMPACT_WOOD;
var int DECAL_IMPACT_CONCRETE;

void
FX_Impact_Init(void)
{
	Sound_Precache("sfx_impact.default");
	Sound_Precache("sfx_impact.alien");
	Sound_Precache("sfx_impact.flesh");
	Sound_Precache("sfx_impact.foliage");
	Sound_Precache("sfx_impact.computer");
	Sound_Precache("sfx_impact.dirt");
	Sound_Precache("sfx_impact.vent");
	Sound_Precache("sfx_impact.grate");
	Sound_Precache("sfx_impact.metal");
	Sound_Precache("sfx_impact.glass");
	Sound_Precache("sfx_impact.sand");
	Sound_Precache("sfx_impact.slosh");
	Sound_Precache("sfx_impact.snow");
	Sound_Precache("sfx_impact.tile");
	Sound_Precache("sfx_impact.wood");
	Sound_Precache("sfx_impact.concrete");

	FX_IMPACT_BLACKBITS = particleeffectnum("fx_impact.blackbits");
	FX_IMPACT_SMOKE_GREY = particleeffectnum("fx_impact.smoke_grey");
	FX_IMPACT_SMOKE_BROWN = particleeffectnum("fx_impact.smoke_brown");
	FX_IMPACT_SPARK = particleeffectnum("fx_impact.spark");

	/* engine-side particle system decals for non HL1 BSP */
	DECAL_IMPACT_DEFAULT = particleeffectnum("decal_impact.default");
	DECAL_IMPACT_ALIEN = particleeffectnum("decal_impact.alien");
	DECAL_IMPACT_FLESH = particleeffectnum("decal_impact.flesh");
	DECAL_IMPACT_FOLIAGE = particleeffectnum("decal_impact.foliage");
	DECAL_IMPACT_COMPUTER = particleeffectnum("decal_impact.computer");
	DECAL_IMPACT_DIRT = particleeffectnum("decal_impact.dirt");
	DECAL_IMPACT_VENT = particleeffectnum("decal_impact.vent");
	DECAL_IMPACT_GRATE = particleeffectnum("decal_impact.grate");
	DECAL_IMPACT_METAL = particleeffectnum("decal_impact.metal");
	DECAL_IMPACT_GLASS = particleeffectnum("decal_impact.glass");
	DECAL_IMPACT_SAND = particleeffectnum("decal_impact.sand");
	DECAL_IMPACT_SLOSH = particleeffectnum("decal_impact.slosh");
	DECAL_IMPACT_SNOW = particleeffectnum("decal_impact.snow");
	DECAL_IMPACT_TILE = particleeffectnum("decal_impact.tile");
	DECAL_IMPACT_WOOD = particleeffectnum("decal_impact.wood");
	DECAL_IMPACT_CONCRETE = particleeffectnum("decal_impact.concrete");
}
#endif

void
FX_Impact(int iType, vector vecPos, vector vNormal)
{
#ifdef SERVER
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_IMPACT);
	WriteByte(MSG_MULTICAST, (float)iType);
	WriteCoord(MSG_MULTICAST, vecPos[0]); 
	WriteCoord(MSG_MULTICAST, vecPos[1]); 
	WriteCoord(MSG_MULTICAST, vecPos[2]);
	WriteCoord(MSG_MULTICAST, vNormal[0]); 
	WriteCoord(MSG_MULTICAST, vNormal[1]); 
	WriteCoord(MSG_MULTICAST, vNormal[2]);
	msg_entity = self;
	multicast(vecPos, MULTICAST_PVS);
#else
	/* decals */
	if (serverkeyfloat("*bspversion") == BSPVER_HL) {
		switch (iType) {
		case IMPACT_GLASS:
			Decals_Place(vecPos, sprintf("{break%d", floor(random(1,4))));
			break;
		case IMPACT_MELEE:
			Decals_Place(vecPos, sprintf("{shot%d", floor(random(1,6))));
			break;
		default:
			Decals_Place(vecPos, sprintf("{bigshot%d", floor(random(1,6))));
			break;
		}
	} else {
		switch (iType) {
		case IMPACT_GLASS:
			pointparticles(DECAL_IMPACT_GLASS, vecPos, vNormal, 1);
			break;
		case IMPACT_WOOD:
			pointparticles(DECAL_IMPACT_WOOD, vecPos, vNormal, 1);
			break;
		case IMPACT_METAL:
			pointparticles(DECAL_IMPACT_METAL, vecPos, vNormal, 1);
			break;
		case IMPACT_FLESH:
			pointparticles(DECAL_IMPACT_FLESH, vecPos, vNormal, 1);
			break;
		default:
			pointparticles(DECAL_IMPACT_DEFAULT, vecPos, vNormal, 1);
			break;
		}
	}

	switch (iType) {
	case IMPACT_MELEE:
	case IMPACT_EXPLOSION:
		break;
	case IMPACT_GLASS:
		pointparticles(FX_IMPACT_BLACKBITS, vecPos, vNormal, 1);
		break;
	case IMPACT_WOOD:
		pointparticles(FX_IMPACT_SPARK, vecPos, vNormal, 1);
		pointparticles(FX_IMPACT_BLACKBITS, vecPos, vNormal, 1);
		pointparticles(FX_IMPACT_SMOKE_BROWN, vecPos, vNormal, 1);
		break;
	case IMPACT_METAL:
		pointparticles(FX_IMPACT_SPARK, vecPos, vNormal, 1);
		pointparticles(FX_IMPACT_BLACKBITS, vecPos, vNormal, 1);
		break;
	case IMPACT_FLESH:
		FX_Blood(vecPos, vNormal);
		break;
	default:
		pointparticles(FX_IMPACT_SPARK, vecPos, vNormal, 1);
		pointparticles(FX_IMPACT_BLACKBITS, vecPos, vNormal, 1);
		pointparticles(FX_IMPACT_SMOKE_GREY, vecPos, vNormal, 1);
		break;
	}

	switch (iType) {
	case IMPACT_ALIEN:
		Sound_PlayAt(vecPos, "sfx_impact.alien");
		break;
	case IMPACT_COMPUTER:
		Sound_PlayAt(vecPos, "sfx_impact.computer");
		break;
	case IMPACT_CONCRETE:
		Sound_PlayAt(vecPos, "sfx_impact.concrete");
		break;
	case IMPACT_DIRT:
		Sound_PlayAt(vecPos, "sfx_impact.dirt");
		break;
	case IMPACT_FLESH:
		Sound_PlayAt(vecPos, "sfx_impact.flesh");
		break;
	case IMPACT_FOLIAGE:
		Sound_PlayAt(vecPos, "sfx_impact.foliage");
		break;
	case IMPACT_GLASS:
		Sound_PlayAt(vecPos, "sfx_impact.glass");
		break;
	case IMPACT_GRATE:
		Sound_PlayAt(vecPos, "sfx_impact.grate");
		break;
	case IMPACT_METAL:
		Sound_PlayAt(vecPos, "sfx_impact.metal");
		break;
	case IMPACT_SLOSH:
		Sound_PlayAt(vecPos, "sfx_impact.slosh");
		break;
	case IMPACT_SNOW:
		Sound_PlayAt(vecPos, "sfx_impact.snow");
		break;
	case IMPACT_TILE:
		Sound_PlayAt(vecPos, "sfx_impact.tile");
		break;
	case IMPACT_VENT:
		Sound_PlayAt(vecPos, "sfx_impact.vent");
		break;
	case IMPACT_WOOD:
		Sound_PlayAt(vecPos, "sfx_impact.wood");
		break;
	default:
		Sound_PlayAt(vecPos, "sfx_impact.default");
		break;
	}
#endif
} 
