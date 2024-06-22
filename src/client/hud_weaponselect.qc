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

.NSWeapon m_nextWeapon;
.NSWeapon m_prevWeapon;

void View_ForceChange(NSClientPlayer pl, int targetWeapon);

NSWeapon
HLWeapon_SortWeaponChain(NSClientPlayer targetPlayer)
{
	NSWeapon itemChain = targetPlayer.m_itemList;
	int heighestSlot = -1i;
	int heighestPos = -1i;
	NSWeapon firstWeapon, lastWeapon;

	firstWeapon = lastWeapon = __NULL__;

	if (!targetPlayer.m_itemList) {
		return __NULL__;
	}

	/* first we determine the range of our hud buckets. */
	while (itemChain) {
		if (itemChain.IsWeapon() == true) {
			int hudSlot = itemChain.GetDefInt("hudSlot");
			int hudPos = itemChain.GetDefInt("hudSlotPos");

			if (hudSlot > heighestSlot) {
				heighestSlot = hudSlot;
			}
			if (hudPos > heighestPos) {
				heighestPos = hudPos;
			}
		}

		itemChain = itemChain.chain;
	}

	for (int hS = 0i; hS <= heighestSlot; hS++) {
		for (int hP = 0i; hP <= heighestPos; hP++) {
			itemChain = targetPlayer.m_itemList;

			while (itemChain) {
				if (itemChain.IsWeapon() == true) {
					int hudSlot = itemChain.GetDefInt("hudSlot");
					int hudPos = itemChain.GetDefInt("hudSlotPos");

					if (hudSlot == hS && hudPos == hP) {
						/* first weapon in the chain? */
						if (!lastWeapon) {
							firstWeapon = itemChain;
							lastWeapon = firstWeapon;
						} else {
							/* assign this weapon to the last weapon of our chain. */
							lastWeapon.m_nextWeapon = itemChain;
							itemChain.m_prevWeapon = lastWeapon;
							lastWeapon = itemChain;
						}
					}
				}

				itemChain = itemChain.chain;
			}
		}
	}

	/* test */
	NSWeapon weaponTest = firstWeapon;
	while (weaponTest) {
		weaponTest = weaponTest.m_nextWeapon;
	}

	firstWeapon.m_prevWeapon = lastWeapon;

	return (firstWeapon);
}

vector g_vecHUDNums[6] =
{
	[168 / 256, 72 / 128],
	[188 / 256, 72 / 128],
	[208 / 256, 72 / 128],
	[168 / 256, 92 / 128],
	[188 / 256, 92 / 128],
	[208 / 256, 92 / 128]
};

bool
HUD_DrawWeaponSelect_CanSwitch(NSClientPlayer pl)
{
	if (!pl.m_activeWeapon)
		return false;

	return true;
}

void
HUD_SelectWeapon(NSWeapon nextWeapon)
{
	if (!nextWeapon) {
		pSeat->m_iHUDWeaponSelected = 0i;
		return;
	}

	pSeat->m_iHUDWeaponSelected = nextWeapon.GetSharedID();
}

/* Select the next item in the list. */
void
HUD_DrawWeaponSelect_Forward(void)
{
	NSClientPlayer pl = (NSClientPlayer)pSeat->m_ePlayer;
	NSWeapon firstWeapon;

	if (HUD_DrawWeaponSelect_CanSwitch(pl) = false) {
		return;
	}

	firstWeapon = HLWeapon_SortWeaponChain(pl);

	if (pl.m_activeWeapon.m_nextWeapon) {
		HUD_SelectWeapon(pl.m_activeWeapon.m_nextWeapon);
	} else {
		HUD_SelectWeapon(firstWeapon);
	}
}

void
HUD_DrawWeaponSelect_Back(void)
{
	NSClientPlayer pl = (NSClientPlayer)pSeat->m_ePlayer;
	NSWeapon firstWeapon;

	if (HUD_DrawWeaponSelect_CanSwitch(pl) = false) {
		return;
	}

	firstWeapon = HLWeapon_SortWeaponChain(pl);

	if (pl.m_activeWeapon.m_prevWeapon) {
		HUD_SelectWeapon(pl.m_activeWeapon.m_prevWeapon);
	} else {
		HUD_SelectWeapon(firstWeapon);
	}
}

void
HUD_DrawWeaponSelect_Trigger(void)
{

}

void
HUD_DrawWeaponSelect_Last(void)
{

}

void
HUD_DrawWeaponSelect_Num(vector vecPos, float fValue)
{
	drawsubpic(vecPos, [20,20], g_hud7_spr, g_vecHUDNums[fValue], [20/256, 20/128], g_hud_color, 1, DRAWFLAG_ADDITIVE);
}

int
HUD_InSlotPos(int slot, int pos)
{

	return (-1);
}

void
HUD_SlotSelect(int slot)
{
#if 0
	NSClientPlayer pl = (NSClientPlayer)pSeat->m_ePlayer;
	int curslot = g_weapons[pSeat->m_iHUDWeaponSelected].slot;
	int i;

	if (g_textmenu != "") {
		Textmenu_Input(slot);
		return;
	}

	/* hack to see if we have ANY weapons at all. */
	if (!pl.activeweapon) {
		return;
	}

	if (pSeat->m_flHUDWeaponSelectTime < time) {
		pl.StartSoundDef("Player.WeaponSelectionOpen", CHAN_ITEM, false);
	} else {
		pl.StartSoundDef("Player.WeaponSelectionMoveSlot", CHAN_ITEM, false);
	}

	/* weren't in that slot? select the first one then */
	if (curslot != slot) {
		for (i = 1; i < g_weapons.length; i++) {
			if (g_weapons[i].slot == slot && pl.g_items & g_weapons[i].id) {
				pSeat->m_iHUDWeaponSelected = i;
				pSeat->m_flHUDWeaponSelectTime = time + 3;
				break;
			}
		}
	} else {
		int first = -1;
		for (i = 1; i < g_weapons.length; i++) {
			if (g_weapons[i].slot == slot && pl.g_items & g_weapons[i].id) {
				if (i < pSeat->m_iHUDWeaponSelected && first == -1) {
					first = i;
				} else if (i > pSeat->m_iHUDWeaponSelected) {
					first = -1;
					pSeat->m_iHUDWeaponSelected = i;
					pSeat->m_flHUDWeaponSelectTime = time + 3;
					break;
				}
			}
		}

		if (first > 0) {
			pSeat->m_iHUDWeaponSelected = first;
			pSeat->m_flHUDWeaponSelectTime = time + 3;
		}
	}
#endif
}

void
HUD_DrawWeaponSelect(void)
{
#if 0
	NSClientPlayer pl = (NSClientPlayer)pSeat->m_ePlayer;
	if (!pl.activeweapon) {
		return;
	}
	if (pSeat->m_flHUDWeaponSelectTime < time) {
		if (pSeat->m_iHUDWeaponSelected) {
			pl.StartSoundDef("Player.WeaponSelectionClose", CHAN_ITEM, false);
			pSeat->m_iHUDWeaponSelected = 0;
		}
		return;
	}

	vector vecPos = g_hudmins + [16,16];

	int b;
	int wantslot = g_weapons[pSeat->m_iHUDWeaponSelected].slot;
	int wantpos = g_weapons[pSeat->m_iHUDWeaponSelected].slot_pos;
	for (int i = 0; i < 5; i++) {
		int slot_selected = 0;
		vecPos[1] = g_hudmins[1] + 16;
		HUD_DrawWeaponSelect_Num(vecPos, i);
		vecPos[1] += 20;
		for (int x = 0; x < 32; x++) {
			if (i == wantslot) {
				slot_selected = TRUE;
				if (x == wantpos) {
					// Selected Sprite
					Weapons_HUDPic(pl, pSeat->m_iHUDWeaponSelected, 1, vecPos, 1.0f);
					drawsubpic(vecPos, [170,45], g_hud3_spr, 
								[0,180/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
					vecPos[1] += 50;
				} else if ((b=HUD_InSlotPos(i, x)) != -1) {
					// Unselected Sprite
					Weapons_HUDPic(pl, b, 0, vecPos, 1.0f);
					vecPos[1] += 50;
				}
			} else if (HUD_InSlotPos(i, x) != -1) {
				HUD_DrawWeaponSelect_Num(vecPos, 5);
				vecPos[1] += 25;
			}
		}

		if (slot_selected == TRUE) {
			vecPos[0] += 175;
		} else {
			vecPos[0] += 25;
		}
	}
#endif
}
