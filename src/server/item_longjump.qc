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

/*QUAKED item_longjump (0 0 0.8) (-16 -16 0) (16 16 36)

HALF-LIFE (1998) ENTITY

Longjump module.
Allows the player to jump longer distance by holding crouch
and pressing jump.

*/
class item_longjump:CBaseTrigger
{
	string m_strOnPlayerTouch;

	void(void) item_longjump;

	virtual void(void) touch;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
};

void
item_longjump::touch(void)
{
	if (other.classname != "player") {
		return;
	}

	player pl = (player)other;
	if (pl.g_items & ITEM_LONGJUMP) {
		return;
	}

	Logging_Pickup(other, this, __NULL__);
	sound(other, CHAN_ITEM, "fvox/blip.wav", 1, ATTN_NORM);
	sound(other, CHAN_VOICE, "fvox/powermove_on.wav", 1, ATTN_NORM);
	pl.g_items |= ITEM_LONGJUMP;

	if (!target) {
		UseOutput(other, m_strOnPlayerTouch);
	} else {
		UseTargets(other, TRIG_TOGGLE, m_flDelay);
	}

	if (real_owner || cvar("sv_playerslots") == 1) {
		remove(self);
	} else {
		Hide();
		think = Respawn;
		nextthink = time + 30.0f;
	}
}

void
item_longjump::Respawn(void)
{
	SetSolid(SOLID_TRIGGER);
	SetMovetype(MOVETYPE_TOSS);
	SetSize([-16,-16,0],[16,16,16]);
	SetOrigin(m_oldOrigin);
	SetModel(m_oldModel);

	think = __NULL__;
	nextthink = -1;

	if (!real_owner)
		Sound_Play(this, CHAN_ITEM, "item.respawn");
}

void
item_longjump::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "OnPlayerTouch":
		strValue = strreplace(",", ",_", strValue);
		m_strOnPlayerTouch = strcat(m_strOnPlayerTouch, ",_", strValue);
		break;
	default:
		CBaseTrigger::SpawnKey(strKey, strValue);
		break;
	}
}

void
item_longjump::item_longjump(void)
{
	model = "models/w_longjump.mdl";
	precache_sound("items/suitchargeok1.wav");
	precache_sound("fvox/powermove_on.wav");
	precache_sound("fvox/blip.wav");
	CBaseTrigger::CBaseTrigger();
	Respawn();
}
