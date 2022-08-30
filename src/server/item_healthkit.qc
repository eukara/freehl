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

/*QUAKED item_healthkit (0 0 0.8) (-16 -16 0) (16 16 36)

HALF-LIFE (1998) ENTITY

Healthkit item.
Adds 20 of health to the player.

-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/w_medkit.mdl"
*/
class item_healthkit:NSRenderableEntity
{
	void(void) item_healthkit;

	virtual void(void) Spawned;
	virtual void(void) Respawn;
	virtual void(entity) Touch;
};

void item_healthkit::Touch(entity eToucher)
{
	if (eToucher.classname != "player") {
		return;
	}

	if (eToucher.health >= eToucher.max_health) {
		return;
	}

	Damage_Apply(eToucher, this, -20, 0, DMG_GENERIC);
	Sound_Play(this, CHAN_ITEM, "item.healthkit");
	Logging_Pickup(eToucher, this, __NULL__);

	if (real_owner || cvar("sv_playerslots") == 1) {
		Destroy();
	} else {
		Disappear();
		ScheduleThink(Respawn, 30.0f);
	}
}

void item_healthkit::Respawn(void)
{
	SetSolid(SOLID_TRIGGER);
	SetMovetype(MOVETYPE_TOSS);
	SetOrigin(GetSpawnOrigin());
	SetModel(GetSpawnModel());
	SetSize([-16,-16,0],[16,16,16]);
	botinfo = BOTINFO_HEALTH;

	ReleaseThink();

	if (!real_owner && time > 30.0f)
		Sound_Play(this, CHAN_ITEM, "item.respawn");

	DropToFloor();
}

void
item_healthkit::Spawned(void)
{
	super::Spawned();

	Sound_Precache("item.healthkit");
	Sound_Precache("item.respawn");
}

void item_healthkit::item_healthkit(void)
{
	model = "models/w_medkit.mdl";
}
