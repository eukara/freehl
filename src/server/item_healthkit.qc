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

/*QUAKED item_healthkit (0 0 0.8) (-16 -16 0) (16 16 36)

HALF-LIFE (1998) ENTITY

Healthkit item.
Adds 20 of health to the player.

*/
class item_healthkit:CBaseEntity
{
	void(void) item_healthkit;
	virtual void(void) Respawn;
	virtual void(void) touch;
};

void item_healthkit::touch(void)
{
	if (other.classname != "player") {
		return;
	}

	if (other.health >= other.max_health) {
		return;
	}

	Damage_Apply(other, this, -20, 0, DMG_GENERIC);
	Sound_Play(this, CHAN_ITEM, "item.healthkit");
	Logging_Pickup(other, this, __NULL__);

	if (real_owner || cvar("sv_playerslots") == 1) {
		remove(self);
	} else {
		Hide();
		think = Respawn;
		nextthink = time + 20.0f;
	}
}

void item_healthkit::Respawn(void)
{
	SetSolid(SOLID_TRIGGER);
	SetMovetype(MOVETYPE_TOSS);
	SetSize([-16,-16,0],[16,16,16]);
	SetOrigin(m_oldOrigin);
	SetModel(m_oldModel);
	//botinfo = BOTINFO_HEALTH;

	think = __NULL__;
	nextthink = -1;

	if (!real_owner)
		Sound_Play(this, CHAN_ITEM, "item.respawn");

	droptofloor();
}

void item_healthkit::item_healthkit(void)
{
	Sound_Precache("item.healthkit");
	Sound_Precache("item.respawn");
	model = "models/w_medkit.mdl";
	CBaseEntity::CBaseEntity();
	item_healthkit::Respawn();
}
