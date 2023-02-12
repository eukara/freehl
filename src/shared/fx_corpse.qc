/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

#ifdef SERVER
#define CORPSES_MAX 16
entity g_bodies;

void
FX_Corpse_Init(void)
{
	entity next = spawn(NSRenderableEntity);
	g_bodies = next;

	for ( int i = 0; i <= CORPSES_MAX; i++ ) {
		next.classname = "corpse";
		next.owner = spawn(NSRenderableEntity);
		
		if ( i == CORPSES_MAX ) {
			next.owner = g_bodies;
		} else {
			next = next.owner;
		}
	}
}

entity
FX_Corpse_Next(void)
{
	entity r = g_bodies;
	g_bodies = g_bodies.owner;
	return r;
}

entity
FX_Corpse_Spawn(player pl, float anim)
{
	NSRenderableEntity body_next = (NSRenderableEntity)FX_Corpse_Next();
	setorigin(body_next, pl.origin + [0,0,32]);
	body_next.SetMovetype(MOVETYPE_TOSS);
	body_next.SetSolid(SOLID_CORPSE);
	setmodel(body_next, pl.model);
	setsize(body_next, VEC_HULL_MIN, VEC_HULL_MAX);
	body_next.SetModelindex(pl.modelindex);
	body_next.SetAngles(pl.angles);
	body_next.velocity = (pl.velocity) + [0,0,120];
	body_next.colormap = pl.colormap;
	body_next.SetFrame(anim);
	return (entity)body_next;
}
#endif
