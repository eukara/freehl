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
var int FX_EXPLOSION_MAIN;
var int FX_EXPLOSION_BS;

void
FX_Explosion_Init(void)
{
	Sound_Precache("fx.explosion");
	precache_model("sprites/fexplo.spr");
	FX_EXPLOSION_MAIN = particleeffectnum("fx_explosion.main");
	FX_EXPLOSION_BS = particleeffectnum("fx_explosion.blacksmoke");
}
#endif

void
FX_Explosion(vector vecPos)
{
#ifdef SERVER
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_EXPLOSION);
	WriteCoord(MSG_MULTICAST, vecPos[0]); 
	WriteCoord(MSG_MULTICAST, vecPos[1]); 
	WriteCoord(MSG_MULTICAST, vecPos[2]);
	msg_entity = self;
	multicast(vecPos, MULTICAST_PVS);
#else
	Decals_Place(vecPos, sprintf("{scorch%d", floor(random(1,4))));
	vecPos[2] += 48;
	env_sprite eExplosion = spawn(env_sprite);
	setorigin(eExplosion, vecPos);
	setmodel(eExplosion, "sprites/fexplo.spr");
	Sound_Play(eExplosion, CHAN_WEAPON, "fx.explosion");

	//eExplosion.think = FX_Explosion_Animate;
	eExplosion.effects = EF_ADDITIVE;
	eExplosion.drawmask = MASK_ENGINE;
	eExplosion.maxframe = modelframecount(eExplosion.modelindex);
	eExplosion.loops = 0;
	eExplosion.framerate = 20;
	eExplosion.nextthink = time + 0.05f;

	pointparticles(FX_EXPLOSION_MAIN, vecPos, [0,0,0], 1);
	pointparticles(FX_EXPLOSION_BS, vecPos, [0,0,0], 1);
#endif
}

