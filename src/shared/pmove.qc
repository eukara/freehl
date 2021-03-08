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

#define PHY_JUMP_CHAINWINDOW	0.5
#define PHY_JUMP_CHAIN		100
#define PHY_JUMP_CHAINDECAY	50

.float waterlevel;
.float watertype;

float GamePMove_Maxspeed(player target)
{
	return (target.flags & FL_CROUCHING) ? 135 : 270;
}

void GamePMove_Fall(player target, float impactspeed)
{
	if (impactspeed > 580) {
#ifdef SERVER
		float fFallDamage = (impactspeed - 580) * (100 / (1024 - 580));
		Damage_Apply(target, world, fFallDamage, 0, DMG_FALL);
		Sound_Play(target, CHAN_VOICE, "player.fall");
#endif
		target.punchangle += [15,0,(input_sequence & 1) ? 15 : -15];
	} else if (impactspeed > 400) {
		target.punchangle += [15,0,0];
#ifdef SERVER
		Sound_Play(target, CHAN_VOICE, "player.lightfall");
#endif
	}
}

void GamePMove_Jump(player target)
{
	float flJumptimeDelta;
	float flChainBonus;

	if (target.waterlevel >= 2) {
		if (target.watertype == CONTENT_WATER) {
			target.velocity[2] = 100;
		} else if (target.watertype == CONTENT_SLIME) {
			target.velocity[2] = 80;
		} else {
			target.velocity[2] = 50;
		}
	} else {
		/* Half-Life: Longjump module */
		if (target.flags & FL_CROUCHING && target.g_items & 0x00008000i) {
			target.velocity = v_forward * 512;
			target.velocity[2] += 100;
		}
		target.velocity[2] += 240;
	}

	if (target.jumptime > 0) {
		flJumptimeDelta = 0 - (target.jumptime - PHY_JUMP_CHAINWINDOW);
		flChainBonus = PHY_JUMP_CHAIN - (((PHY_JUMP_CHAINWINDOW - (PHY_JUMP_CHAINWINDOW - flJumptimeDelta)) * 2) * PHY_JUMP_CHAINDECAY);
		target.velocity[2] += flChainBonus;
	}
	target.jumptime = PHY_JUMP_CHAINWINDOW;
}
