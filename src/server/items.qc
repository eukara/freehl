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

void item_pickup::Touch(entity eToucher)
{
	if (eToucher.classname != "player") {
		return;
	}

	/* don't remove if AddItem fails */
	if (Weapons_AddItem((player)eToucher, id, m_iClip) == FALSE) {
		return;
	}

	Logging_Pickup(eToucher, this, __NULL__);
	Sound_Play(other, CHAN_ITEM, "weapon.pickup");

	UseTargets(eToucher, TRIG_TOGGLE, m_flDelay);

	if (real_owner || m_iWasDropped == 1 || cvar("sv_playerslots") == 1) {
		Destroy();
	} else {
		Disappear();
		ScheduleThink(PickupRespawn, 30.0f);
	}
}

void item_pickup::SetItem(int i)
{
	id = i;
	m_oldModel = Weapons_GetWorldmodel(id);
	SetModel(GetSpawnModel());
	SetSize([-16,-16,0], [16,16,16]);
}

void item_pickup::SetFloating(int i)
{
	m_bFloating = rint(bound(0, m_bFloating, 1));
}

void
item_pickup::PickupRespawn(void)
{
	Respawn();
	Sound_Play(this, CHAN_ITEM, "item.respawn");
}

void item_pickup::Respawn(void)
{
	/* we need to delay the DropToFloor() by at least a frame.
	   otherwise they may just fall through an entity (func_wall, func_train etc.)
	   that came after this entity in the lump. */
	static void AdjustSpawnPos(void) {
		RestoreAngles();
		SetOrigin(GetSpawnOrigin());

		if (!m_bFloating) {
			DropToFloor();
			SetMovetype(MOVETYPE_TOSS);
		}
	}

	SetOrigin(GetSpawnOrigin());
	SetSolid(SOLID_TRIGGER);
	botinfo = BOTINFO_WEAPON;

	/* At some points, the item id might not yet be set */
	if (GetSpawnModel()) {
		SetModel(GetSpawnModel());
	}

	SetSize([-16,-16,0], [16,16,16]);
	ScheduleThink(AdjustSpawnPos, 0.0f);
}

void
item_pickup::Spawned(void)
{
	super::Spawned();

	Sound_Precache("item.respawn");
	Sound_Precache("weapon.pickup");
}

void item_pickup::item_pickup(void)
{
}
