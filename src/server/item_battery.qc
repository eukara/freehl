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

/*QUAKED item_battery (0 0 0.8) (-16 -16 0) (16 16 36)

HALF-LIFE (1998) ENTITY

HEV Suit energy battery.
It adds the following energy values to the HEV Suit by default:
Skill 1 (Easy):   15
Skill 2 (Medium): 15
Skill 3 (Hard):   10

The values can be tweaked in the skill.cfg file.

*/
class item_battery:CBaseEntity
{
	void(void) item_battery;
	virtual void(void) Respawn;
	virtual void(void) touch;
};

void item_battery::touch(void)
{
	if (other.classname != "player") {
		return;
	}

	base_player pl = (base_player)other;
	
	if (pl.armor >= 100) {
		return;
	}
	/* Move this somewhere else? */
	pl.armor += Skill_GetValue("battery", 15);
	if (pl.armor > 100) {
		pl.armor = 100;
	}

	Logging_Pickup(other, this, __NULL__);
	Sound_Play(other, CHAN_ITEM, "item.battery");

	if (real_owner || cvar("sv_playerslots") == 1) {
		remove(self);
	} else {
		Hide();
		think = Respawn;
		nextthink = time + 20.0f;
	}
}

void item_battery::Respawn(void)
{
	SetSolid(SOLID_TRIGGER);
	SetMovetype(MOVETYPE_TOSS);
	SetSize([-16,-16,0],[16,16,16]);
	SetOrigin(m_oldOrigin);
	SetModel(m_oldModel);
//	botinfo = BOTINFO_ARMOR;

	think = __NULL__;
	nextthink = -1;

	if (!real_owner)
		Sound_Play(this, CHAN_ITEM, "item.respawn");

	droptofloor();
}

void item_battery::item_battery(void)
{
	Sound_Precache("item.battery");
	Sound_Precache("item.respawn");
	model = "models/w_battery.mdl";
	CBaseEntity::CBaseEntity();
	item_healthkit::Respawn();
}
