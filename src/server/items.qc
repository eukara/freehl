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

void item_pickup::touch(void)
{
	if (other.classname != "player") {
		return;
	}

	/* don't remove if AddItem fails */
	if (Weapons_AddItem((player)other, id, m_iClip) == FALSE) {
		return;
	}

	Logging_Pickup(other, this, __NULL__);
	Sound_Play(other, CHAN_ITEM, "weapon.pickup");

	UseTargets(other, TRIG_TOGGLE, m_flDelay);

	if (real_owner || m_iWasDropped == 1 || cvar("sv_playerslots") == 1) {
		remove(self);
	} else {
		Hide();
		think = Respawn;
		nextthink = time + 30.0f;
	}
}

void item_pickup::SetItem(int i)
{
	id = i;
	m_oldModel = Weapons_GetWorldmodel(id);
	SetModel(m_oldModel);
}

void item_pickup::SetFloating(int i)
{
	m_bFloating = rint(bound(0, m_bFloating, 1));
}

void item_pickup::Respawn(void)
{
	SetSolid(SOLID_TRIGGER);
	SetOrigin(m_oldOrigin);

	/* At some points, the item id might not yet be set */
	if (m_oldModel) {
		SetModel(m_oldModel);
	}

	SetSize([-16,-16,0], [16,16,16]);

	think = __NULL__;
	nextthink = -1;

	if (!m_iWasDropped && cvar("sv_playerslots") > 1) {
		if (!real_owner)
			Sound_Play(this, CHAN_ITEM, "item.respawn");

		m_iClip = -1;
	}

	if (!m_bFloating) {
		droptofloor();
		SetMovetype(MOVETYPE_TOSS);
	}
}

void item_pickup::item_pickup(void)
{
	Sound_Precache("item.respawn");
	Sound_Precache("weapon.pickup");
	CBaseTrigger::CBaseTrigger();
	Respawn();
}
