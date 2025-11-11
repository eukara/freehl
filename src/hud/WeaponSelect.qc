/*
 * Copyright (c) 2024-2025 Marco Cawthorne <marco@icculus.org>
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

var float autocvar_hlhud_weaponIconAlpha = 0.75;
var float autocvar_hlhud_weaponIconSelectedAlpha = 1.0f;
var bool autocvar_hlhud_selectCurrentWeaponFirst = false;
var int autocvar_hlhud_minimumSlots = 5;

var vector autocvar_hlhud_ammoBarColor1 = [0, 1, 0];
var vector autocvar_hlhud_ammoBarColor2 = [0, 1, 0];


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
	if (m_selectedWeapon == __NULL__) {
		return;
	}

	m_selectedWeapon = __NULL__;
	m_flHUDWeaponSelectTime = 0.0f;
	Event_Closed();
}

void
HLWeaponSelect::DrawBar(vector drawAtPos, float percentageAmount)
{
	vector colorLerp;
	float barWidth;

	draw.Rect(drawAtPos + [10,0], [20,4], g_fg_color, 1.0f);

	barWidth = bound(1, 20 * percentageAmount, 20);
	colorLerp[0] = lerp(autocvar_hlhud_ammoBarColor1[0], autocvar_hlhud_ammoBarColor2[0], percentageAmount);
	colorLerp[1] = lerp(autocvar_hlhud_ammoBarColor1[1], autocvar_hlhud_ammoBarColor2[1], percentageAmount);
	colorLerp[2] = lerp(autocvar_hlhud_ammoBarColor1[2], autocvar_hlhud_ammoBarColor2[2], percentageAmount);

	draw.Rect(drawAtPos + [10,0], [barWidth,4], colorLerp, 1.0f);
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

#if 0
	float totalWidth = 120;
	totalWidth += (weapon.GetSlot(m_lastWeapon) * 40);
	vecPos = hudMins + [hudRes[0] / 2 - (totalWidth / 2),16];
#else
	vecPos = hudMins + [16,16];
#endif

	/* iterate through the inventory*/
	while (linkedList) {
		/* only iterate over weapons */
		if (weapon.IsValid(linkedList) == true) {
			currentSlot = weapon.GetSlot(linkedList);

			/* new slot started, reset Y axis */
			if (lastSlot != currentSlot) {
				/* new slot, new offset */
				if (lastSlot == m_iWantSlot) {
					vecPos[0] += 175;
				} else {
					vecPos[0] += 25;
				}

				/* quick hack to re-adjust */
				if (lastSlot == -1) {
#if 0
					vecPos[0] = hudMins[0] + (hudRes[0] / 2 - (totalWidth / 2));
#else
					vecPos = hudMins + [16,16];
#endif
				}

				/* slot number icon at the top */
				vecPos[1] = hudMins[1] + 25;

				/* Fluff: draw slot category for weapons we don't have */
				for (int i = m_cachedSlot + 1; i < currentSlot; i++) {
					DrawSlotNum(vecPos + [0, -20], i + 1, false);
					vecPos[0] += 25;
				}
				m_cachedSlot = currentSlot;

			}

			bool isEmpty = weapon.IsEmpty(linkedList);

			/* new slot started */
			if (lastSlot != currentSlot) {
				/* every slot number is accompanied by their own tiny bg rect */
				if (m_iWantSlot != currentSlot) {
					DrawSlotNum(vecPos, 0, isEmpty);
				}

				/* draw num on top of the bg */
				DrawSlotNum(vecPos + [0, -20], currentSlot + 1, false);
			} else {
				if (m_iWantSlot != currentSlot) {
					DrawSlotNum(vecPos, 0, isEmpty);
				}
			}

			lastSlot = currentSlot;

			/* selected slot VS unselected slot */
			if (m_iWantSlot == currentSlot) {
				vector weaponColor = g_fg_color;

				if (isEmpty) {
					weaponColor = [1, 0, 0];
				}
					
				float ammo1Percentage = (float)weapon.GetAmmo1(linkedList) / (float)weapon.MaxAmmo(linkedList);
				float ammo2Percentage = (float)weapon.GetAmmo2(linkedList) / (float)weapon.MaxAmmo(linkedList);

				if (linkedList == m_selectedWeapon) {
					atlasPic.Draw_RGBA(atlasPic.Load(weapon.GetSelectedIcon(linkedList)), vecPos, weaponColor * autocvar_hlhud_weaponIconSelectedAlpha, g_fg_alphaScale, true);
					atlasPic.Draw_RGBA(g_spriteSheets[S_SELECTION], vecPos, weaponColor * autocvar_hlhud_weaponIconSelectedAlpha, g_fg_alphaScale, true);

					if (isEmpty == false && weapon.AmmoRequired(linkedList) == true) {
						DrawBar(vecPos, ammo1Percentage);
					}

					if (isEmpty == false && weapon.UsesSecondaryAmmo(linkedList) == true) {
						DrawBar(vecPos + [35, 0], ammo2Percentage);
					}
				} else {
					atlasPic.Draw_RGBA(atlasPic.Load(weapon.GetIcon(linkedList)), vecPos, weaponColor * autocvar_hlhud_weaponIconAlpha, g_fg_alphaScale, true);

					if (isEmpty == false && weapon.AmmoRequired(linkedList) == true) {
						DrawBar(vecPos, ammo1Percentage);
					}

					if (isEmpty == false && weapon.UsesSecondaryAmmo(linkedList) == true) {
						DrawBar(vecPos + [35, 0], ammo2Percentage);
					}
				}
				vecPos[1] += 50;
			} else {
				vecPos[1] += 25;
			}
		}

		linkedList = weapon.GetNextWeaponRelativeTo(linkedList);
	}

	vecPos[1] = hudMins[1] + 25;
	
	if (m_iWantSlot == currentSlot) {
		vecPos[0] += 175;
	} else {
		vecPos[0] += 25;
	}

	/* Fluff: empty categories over the current inventory layout */
	for (int i = m_cachedSlot + 1; i < autocvar_hlhud_minimumSlots; i++) {
		DrawSlotNum(vecPos + [0, -20], i + 1, false);
		vecPos[0] += 25;
	}
}

void
HLWeaponSelect::DrawSlotNum(vector vecPos, float fValue, bool emptyWeapon)
{
	atlasPic.Draw_RGBA(
		g_spriteSheets[S_BUCKET0 + fValue],
		vecPos,
		emptyWeapon ? [1,0,0] : g_fg_color,
		g_fg_alphaScale,
		true
	);
}

void
HLWeaponSelect::SelectSlot(int wantedSlot, bool fastSwitch)
{
	wantedSlot -= 1;
	
	m_firstWeapon = weapon.GetFirstWeaponInInventory();
	m_lastWeapon = weapon.GetLastWeaponInInventory();

	entity weaponNumerator = weapon.GetFirstWeaponInInventory();
	entity currentWeapon = m_selectedWeapon;
	int currentWeaponSlot = weapon.GetSlot(currentWeapon);
	bool checkRange = (wantedSlot == currentWeaponSlot) ? (true) : (false);
	bool passedWeapon = false;
	entity firstWeaponInSlot = 0;
	entity lastSelected = m_selectedWeapon;

	do {
		int weaponSlot = weapon.GetSlot(weaponNumerator);

		/* not in slot, skip */
		if (wantedSlot != weaponSlot) {
			continue;
		}
		
		if (!firstWeaponInSlot) {
			firstWeaponInSlot = weaponNumerator;
		}

		/* next weapon in slot */
		if (weaponNumerator == currentWeapon) {
			/* past our current weapon! */
			if (checkRange) {
				passedWeapon = true;
			}
			continue;
		}

		/* only proceed if we've gone past our current weapon. */
		if (checkRange && passedWeapon == false) {
			continue;
		}
		
		m_selectedWeapon = weaponNumerator;
		break;
	} while ((weaponNumerator = weapon.GetNextWeaponRelativeTo(weaponNumerator)));
	
	/* wrap around */
	if (!m_selectedWeapon || m_selectedWeapon == lastSelected) {
		m_selectedWeapon = firstWeaponInSlot;
	}

	/* there's nothing to be found */
	if (!m_selectedWeapon) {
		m_selectedWeapon = lastSelected;
		return;
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
		if (autocvar_hlhud_selectCurrentWeaponFirst) {
			m_selectedWeapon = currentWeapon;
		} else {
			m_selectedWeapon = weapon.GetNextWeaponRelativeTo(currentWeapon);
		}
	} else {
		m_selectedWeapon = weapon.GetNextWeaponRelativeTo(m_selectedWeapon);
	}

	/* iterate over non-empty weapons only */
	while (weapon.IsEmpty(m_selectedWeapon) == true && m_selectedWeapon) {
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
		if (autocvar_hlhud_selectCurrentWeaponFirst) {
			m_selectedWeapon = currentWeapon;
		} else {
			m_selectedWeapon = weapon.GetPreviousWeaponRelativeTo(currentWeapon);
		}
	} else {
		m_selectedWeapon = weapon.GetPreviousWeaponRelativeTo(m_selectedWeapon);
	}

	/* iterate over non-empty weapons only */
	while (weapon.IsEmpty(m_selectedWeapon) == true && m_selectedWeapon) {
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


void
HLWeaponSelect::SelectLast(bool fastSwitch)
{

}
