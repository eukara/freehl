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

/*QUAKED item_armorvest (0 0 0.8) (-16 -16 0) (16 16 36) SUIT_LONGINTRO

HALF-LIFE (1998) ENTITY

HEV Suit
Provides the player with armor, a flashlight and a Heads-Up-Display.

When SUIT_LONGINTRO is set, the intro dialog will be longer.

*/

class item_armorvest:NSRenderableEntity
{
	string m_strOnPlayerTouch;

	void(void) item_armorvest;

	virtual void(void) Spawned;
	virtual void(entity) Touch;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
};

void
item_armorvest::Touch(entity eToucher)
{
	if (other.classname != "player") {
		return;
	}

	player pl = (player)other;
	if (pl.g_items & ITEM_SUIT) {
		return;
	}

	Logging_Pickup(other, this, __NULL__);
	pl.g_items |= ITEM_SUIT;
	m_iValue = TRUE;

	if (!target) {
		UseOutput(other, m_strOnPlayerTouch);
	} else {
		UseTargets(other, TRIG_TOGGLE, m_flDelay);
	}
	
	if (real_owner || cvar("sv_playerslots") == 1) {
		Destroy();
	} else {
		Disappear();
		ScheduleThink(Respawn, 30.0f);
	}
}

void
item_armorvest::Respawn(void)
{
	SetSolid(SOLID_TRIGGER);
	SetMovetype(MOVETYPE_TOSS);
	SetOrigin(GetSpawnOrigin());
	SetModel(GetSpawnModel());
	SetSize(VEC_HULL_MIN + [0,0,36], VEC_HULL_MAX + [0,0,36]);
	m_iValue = FALSE;

	ReleaseThink();

	if (!real_owner && time > 30.0f)
		Sound_Play(this, CHAN_ITEM, "item.respawn");

	DropToFloor();
}

void
item_armorvest::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "OnPlayerTouch":
		strValue = strreplace(",", ",_", strValue);
		m_strOnPlayerTouch = strcat(m_strOnPlayerTouch, ",_", strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}

void
item_armorvest::Spawned(void)
{
	super::Spawned();

	precache_model(model);

	if (m_strOnPlayerTouch)
		m_strOnPlayerTouch = CreateOutput(m_strOnPlayerTouch);
}

void
item_armorvest::item_armorvest(void)
{
	model = "models/barney_vest.mdl";
}
