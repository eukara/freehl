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

void ncWeapon_SelectWeapon(ncWeapon nextWeapon);

void
HLWeaponSelect::HLWeaponSelect(void)
{
	m_selectedWeapon = __NULL__;
	m_flHUDWeaponSelectTime = 0.0f;
}

bool
HLWeaponSelect::Active(void)
{
	return (m_flHUDWeaponSelectTime > time) ? (true) : (false);
}

void
HLWeaponSelect::Trigger(void)
{
	ncWeapon_SelectWeapon(m_selectedWeapon);
	Deactivate();
}

void
HLWeaponSelect::Deactivate(void)
{
	m_selectedWeapon = __NULL__;
	m_flHUDWeaponSelectTime = 0.0f;
}

void
HLWeaponSelect::Draw(void)
{
	ncPlayer pl = (ncPlayer)pSeat->m_ePlayer;

	if (!pl.m_activeWeapon) {
		return;
	}

	if (m_flHUDWeaponSelectTime < time) {
		m_selectedWeapon = __NULL__;
		return;
	}

	vector vecPos = g_hudmins + [16,16];
	float lastSlot = -1;
	float currentSlot;
	HLWeapon linkedList = __NULL__;

	/* since we have something in the inventory, start there */
	linkedList = m_firstWeapon;

	/* iterate through the inventory*/
	while (linkedList) {
		/* only iterate over weapons */
		if (linkedList.IsWeapon() == true) {
			currentSlot = linkedList. m_iHudSlot;

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
					vecPos[0] = g_hudmins[0] + 16;
				}

				/* slot number icon at the top */
				vecPos[1] = g_hudmins[1] + 16;
				DrawSlotNum(vecPos, currentSlot + 1);
				vecPos[1] += 20;
			}

			lastSlot = currentSlot;

			/* selected slot VS unselected slot */
			if (m_iWantSlot == currentSlot) {
				if (linkedList == m_selectedWeapon) {
					HLSprite_Draw_RGB(linkedList.m_iconSel, vecPos, g_hud_color, true);
					HLSprite_Draw_RGB("selection", vecPos, g_hud_color, true);
				} else {
					HLSprite_Draw_RGB(linkedList.m_icon, vecPos, g_hud_color, true);
				}
				vecPos[1] += 50;
			} else {
				DrawSlotNum(vecPos, 0);
				vecPos[1] += 25;
			}
		}

		linkedList = (HLWeapon)linkedList.GetNextWeapon();
	}
}

static string g_HLWeaponSelectBuckets[] =
{
	"bucket0",
	"bucket1",
	"bucket2",
	"bucket3",
	"bucket4",
	"bucket5",
	"bucket6",
	"bucket7",
	"bucket8",
};

void
HLWeaponSelect::DrawSlotNum(vector vecPos, float fValue)
{
	HLSprite_Draw_RGB(g_HLWeaponSelectBuckets[fValue], vecPos, g_hud_color, true);
}

void
HLWeaponSelect::SelectSlot(int wantedSlot, bool fastSwitch)
{
}

void
HLWeaponSelect::SelectNext(bool fastSwitch)
{
	ncClient ourPlayer = (ncClient)pSeat->m_ePlayer;

	m_firstWeapon = (HLWeapon)ourPlayer.SortWeaponChain();

	if (!m_selectedWeapon) {
		m_selectedWeapon = (HLWeapon)ourPlayer.m_activeWeapon.GetNextWeapon();
	} else {
		m_selectedWeapon = (HLWeapon)m_selectedWeapon.GetNextWeapon();
	}

	/* wrap around */
	if (!m_selectedWeapon) {
		m_selectedWeapon = m_firstWeapon;
	}

	m_flHUDWeaponSelectTime = time + 3;
	m_iWantSlot = m_selectedWeapon.m_iHudSlot;
	m_iWantSlotPos = m_selectedWeapon.m_iHudSlotPos;
}

void
HLWeaponSelect::SelectPrevious(bool fastSwitch)
{
	ncClient ourPlayer = (ncClient)pSeat->m_ePlayer;

	m_firstWeapon = (HLWeapon)ourPlayer.SortWeaponChain();

	if (!m_selectedWeapon) {
		m_selectedWeapon = (HLWeapon)ourPlayer.m_activeWeapon.GetPreviousWeapon();
	} else {
		m_selectedWeapon = (HLWeapon)m_selectedWeapon.GetPreviousWeapon();
	}

	/* wrap around */
	if (!m_selectedWeapon) {
		m_selectedWeapon = m_firstWeapon;
	}

	m_flHUDWeaponSelectTime = time + 3;
	m_iWantSlot = m_selectedWeapon.m_iHudSlot;
	m_iWantSlotPos = m_selectedWeapon.m_iHudSlotPos;
}
