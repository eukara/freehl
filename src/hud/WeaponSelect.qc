/*
 * Copyright (c) 2024 Marco Cawthorne <marco@icculus.org>
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

void
HLWeaponSelect::HLWeaponSelect(void)
{
	m_selectedWeapon = __NULL__;
	m_flHUDWeaponSelectTime = 0.0f;
}

void
HLWeaponSelect::Event_Opened(void)
{
	localsound("common/wpn_hudon.wav");
}

void
HLWeaponSelect::Event_Closed(void)
{
	localsound("common/wpn_hudoff.wav");
}

void
HLWeaponSelect::Event_SelectionChanged(void)
{
	localsound("common/wpn_moveselect.wav");
}

void
HLWeaponSelect::Event_SelectionTriggered(void)
{
	localsound("common/wpn_select.wav");
}

bool
HLWeaponSelect::Active(void)
{
	return (m_flHUDWeaponSelectTime > time) ? (true) : (false);
}

void
HLWeaponSelect::Trigger(void)
{
	weapon.SelectWeapon(m_selectedWeapon);
	Deactivate();
}

void
HLWeaponSelect::Deactivate(void)
{
	m_selectedWeapon = __NULL__;
	m_flHUDWeaponSelectTime = 0.0f;
	Event_Closed();
}

void
HLWeaponSelect::Draw(void)
{
	if (m_flHUDWeaponSelectTime < time) {
		Deactivate();
		return;
	}

	if (!m_selectedWeapon) {
		return;
	}

	vector hudMins = screen.HUDMins();
	vector hudRes = screen.HUDSize();
	vector vecPos = hudMins + [16,16];
	float lastSlot = -1;
	float currentSlot;
	entity linkedList = __NULL__;

	/* since we have something in the inventory, start there */
	linkedList = m_firstWeapon;

	float totalWidth = 120;
	totalWidth += (weapon.GetSlot(m_lastWeapon) * 40);
	vecPos = hudMins + [hudRes[0] / 2 - (totalWidth / 2),16];

	/* iterate through the inventory*/
	while (linkedList) {
		/* only iterate over weapons */
		if (weapon.IsValid(linkedList) == true) {
			currentSlot = weapon.GetSlot(linkedList);

			/* new slot started, reset Y axis */
			if (lastSlot != currentSlot) {
				/* new slot, new offset */
				if (lastSlot == m_iWantSlot) {
					vecPos[0] += 120;
				} else {
					vecPos[0] += 40;
				}

				/* quick hack to re-adjust */
				if (lastSlot == -1) {
					vecPos[0] = hudMins[0] + (hudRes[0] / 2 - (totalWidth / 2));
				}

				/* slot number icon at the top */
				vecPos[1] = hudMins[1] + 16;

			}

			/* current slot = big bg rect, for every item */
			if (m_iWantSlot == currentSlot) {
				draw.RoundedBox(vecPos, [112, 80], [0,0,0], g_fg_alpha);
			} else {
				//
			}

			/* new slot started */
			if (lastSlot != currentSlot) {
				/* every slot number is accompanied by their own tiny bg rect */
				if (m_iWantSlot != currentSlot) {
					draw.RoundedBox(vecPos, [32, 32], [0,0,0], g_fg_alpha * autocvar_hlhud_bucketNumAlpha );
				}

				/* draw num on top of the bg */
				DrawSlotNum(vecPos + [8,8], currentSlot + 1);
			} else {
				/* draw a RT specific, faint box for every item in the other slots */
				if (m_iWantSlot != currentSlot) {
					draw.RoundedBox(vecPos, [32, 32], [0,0,0], g_fg_alpha * autocvar_hlhud_altBucket );
				}
			}

			lastSlot = currentSlot;

			/* selected slot VS unselected slot */
			if (m_iWantSlot == currentSlot) {

				if (linkedList == m_selectedWeapon) {
					draw.TextField(vecPos + [0, 8], [112, 80], weapon.GetSelectedIcon(linkedList), FONT_WEAPONICON_SEL, 0);
					draw.TextField(vecPos + [3, 60], [106, 14], weapon.GetTitle(linkedList), FONT_WEAPONTEXT, 0);
				} else {
					draw.TextField(vecPos + [0, 8], [112, 80], weapon.GetIcon(linkedList), FONT_WEAPONICON, 0);
				}
				vecPos[1] += 88;
			} else {
				vecPos[1] += 40;
			}
		}

		linkedList = weapon.GetNextWeaponRelativeTo(linkedList);
	}
}

void
HLWeaponSelect::DrawSlotNum(vector vecPos, float fValue)
{
	draw.Text(vecPos, sprintf("%d", fValue), FONT_WEAPONNUM);
}

void
HLWeaponSelect::SelectSlot(int wantedSlot, bool fastSwitch)
{
}

void
HLWeaponSelect::SelectNext(bool fastSwitch)
{
	entity currentWeapon = weapon.GetActiveWeapon();

	if (!currentWeapon) {
		return;
	}

	m_firstWeapon = weapon.GetFirstWeaponInInventory();
	m_lastWeapon = weapon.GetLastWeaponInInventory();

	if (!m_selectedWeapon) {
		m_selectedWeapon = weapon.GetNextWeaponRelativeTo(currentWeapon);
	} else {
		m_selectedWeapon = weapon.GetNextWeaponRelativeTo(m_selectedWeapon);
	}

	/* wrap around */
	if (!m_selectedWeapon) {
		m_selectedWeapon = m_firstWeapon;
		Event_Opened();
	} else {
		Event_SelectionChanged();
	}

	m_flHUDWeaponSelectTime = time + autocvar_hlhud_hideTime;
	m_iWantSlot = weapon.GetSlot(m_selectedWeapon);
	m_iWantSlotPos = weapon.GetSlotPos(m_selectedWeapon);
}

void
HLWeaponSelect::SelectPrevious(bool fastSwitch)
{
	entity currentWeapon = weapon.GetActiveWeapon();

	if (!currentWeapon) {
		return;
	}

	m_firstWeapon = weapon.GetFirstWeaponInInventory();
	m_lastWeapon = weapon.GetLastWeaponInInventory();

	if (!m_selectedWeapon) {
		m_selectedWeapon = weapon.GetPreviousWeaponRelativeTo(currentWeapon);
	} else {
		m_selectedWeapon = weapon.GetPreviousWeaponRelativeTo(m_selectedWeapon);
	}

	/* wrap around */
	if (!m_selectedWeapon) {
		m_selectedWeapon = m_firstWeapon;
	}

	if (m_flHUDWeaponSelectTime < time) {
		Event_Opened();
	} else {
		Event_SelectionChanged();
	}

	m_flHUDWeaponSelectTime = time + autocvar_hlhud_hideTime;
	m_iWantSlot = weapon.GetSlot(m_selectedWeapon);
	m_iWantSlotPos = weapon.GetSlotPos(m_selectedWeapon);
}
