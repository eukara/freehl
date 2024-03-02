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

/*QUAKED item_suit (0 0 0.8) (-16 -16 0) (16 16 36) SUIT_LONGINTRO

HALF-LIFE (1998) ENTITY

HEV Suit
Provides the player with armor, a flashlight and a Heads-Up-Display.

When SUIT_LONGINTRO is set, the intro dialog will be longer.

*/

class item_suit:NSRenderableEntity
{
	string m_strOnPlayerTouch;

	void(void) item_suit;

	virtual void(void) Spawned;
	virtual void(entity) Touch;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
};

void
item_suit::Touch(entity eToucher)
{
	if (other.classname != "player") {
		return;
	}

	player pl = (player)other;

	if (pl.g_items & ITEM_SUIT) {
		return;
	}

	Logging_Pickup(other, this, __NULL__);
	StartSound("fvox/bell.wav", CHAN_ITEM, 0, true);
	StartSound("fvox/hev_logon.wav", CHAN_VOICE, 0, true);

	pl.g_items |= ITEM_SUIT;
	m_iValue = TRUE;

	if (HasTriggerTarget() == false) {
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
item_suit::Respawn(void)
{
	/* we need to delay the DropToFloor() by at least a frame.
	   otherwise they may just fall through an entity (func_wall, func_train etc.)
	   that came after this entity in the lump. */
	static void AdjustSpawnPos(void) {
		RestoreAngles();
		SetOrigin(GetSpawnOrigin());
		DropToFloor();
		SetMovetype(MOVETYPE_TOSS);
	}

	if (cvar_string("fs_game") == "bshift") {
		Destroy();
		return;
	}

	SetSolid(SOLID_TRIGGER);
	SetOrigin(GetSpawnOrigin());
	SetMovetype(MOVETYPE_TOSS);
	SetModel(GetSpawnModel());
	SetSize(VEC_HULL_MIN + [0,0,36], VEC_HULL_MAX + [0,0,36]);
	m_iValue = FALSE;

	if (!real_owner && time > 30.0f) {
		StartSoundDef("item.respawn", CHAN_ITEM, true);
	}

	ScheduleThink(AdjustSpawnPos, 0.0f);
}

void
item_suit::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "OnPlayerTouch":
		setValue = strreplace(",", ",_", setValue);
		m_strOnPlayerTouch = strcat(m_strOnPlayerTouch, ",_", setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}

void
item_suit::Spawned(void)
{
	super::Spawned();

	precache_sound("items/suitchargeok1.wav");
	precache_sound("fvox/hev_logon.wav");
	precache_sound("fvox/bell.wav");
	Sound_Precache("item.respawn");

	if (m_strOnPlayerTouch)
		m_strOnPlayerTouch = CreateOutput(m_strOnPlayerTouch);
}

void
item_suit::item_suit(void)
{
	model = "models/w_suit.mdl";
}
