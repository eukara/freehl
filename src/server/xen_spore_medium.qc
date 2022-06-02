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

/*QUAKED xen_spore_medium (0 0.8 0.8) (-16 -16 0) (16 16 72)

HALF-LIFE (1998) ENTITY

Medium Xen Spore

-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/fungus.mdl"
*/
class xen_spore_medium:NSRenderableEntity
{
	void(void) xen_spore_medium;

	virtual void(void) Respawn;
};

void
xen_spore_medium::Respawn(void)
{
	SetSolid(SOLID_SLIDEBOX);
	SetMovetype(MOVETYPE_WALK);
	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());
}

void
xen_spore_medium::xen_spore_medium(void)
{
	model = "models/fungus.mdl";
}
