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

/*QUAKED item_battery (0 0 0.8) (-16 -16 0) (16 16 36)

HALF-LIFE (1998) ENTITY

HEV Suit energy battery.
It adds the following energy values to the HEV Suit by default:
Skill 1 (Easy):   15
Skill 2 (Medium): 15
Skill 3 (Hard):   10

The values can be tweaked in the skill.cfg file.

-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/w_battery.mdl"
*/
class item_battery:NSRenderableEntity
{
	void(void) item_battery;

	virtual void(void) Spawned;
	virtual void(void) Respawn;
	virtual void(entity) Touch;
};

void item_battery::Touch(entity eToucher)
{
	if (eToucher.classname != "player") {
		return;
	}

	NSClientPlayer pl = (NSClientPlayer)eToucher;

	/* don't pick up if we don't have a suit */
	if (!(pl.g_items & ITEM_SUIT))
		return;

	/* maxxed out */
	if (pl.armor >= 100) {
		return;
	}

	/* Move this somewhere else? */
	pl.armor += Skill_GetValue("battery", 15);
	if (pl.armor > 100) {
		pl.armor = 100;
	}

	Logging_Pickup(eToucher, this, __NULL__);
	Sound_Play(eToucher, CHAN_ITEM, "item.battery");

	if (real_owner || cvar("sv_playerslots") == 1) {
		Destroy();
	} else {
		Disappear();
		ScheduleThink(Respawn, 30.0f);
	}
}

void item_battery::Respawn(void)
{
	SetSolid(SOLID_TRIGGER);
	SetMovetype(MOVETYPE_TOSS);
	SetOrigin(GetSpawnOrigin());
	SetModel(GetSpawnModel());
	SetSize([-16,-16,0],[16,16,16]);
	botinfo = BOTINFO_ARMOR;

	ReleaseThink();

	if (!real_owner && time > 30.0f)
		Sound_Play(this, CHAN_ITEM, "item.respawn");

	DropToFloor();
}

void
item_battery::Spawned(void)
{
	super::Spawned();

	Sound_Precache("item.battery");
	Sound_Precache("item.respawn");
}

void item_battery::item_battery(void)
{
	model = "models/w_battery.mdl";
}
