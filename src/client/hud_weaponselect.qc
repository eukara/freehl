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

vector g_vecHUDNums[6] =
{
	[168 / 256, 72 / 128],
	[188 / 256, 72 / 128],
	[208 / 256, 72 / 128],
	[168 / 256, 92 / 128],
	[188 / 256, 92 / 128],
	[208 / 256, 92 / 128]
};

void
HUD_DrawWeaponSelect_Forward(void)
{
	player pl = (player)pSeat->m_ePlayer;

	if (!pl.activeweapon) {
		return;
	}

	if (pSeat->m_flHUDWeaponSelectTime < time) {
		pSeat->m_iHUDWeaponSelected = pl.activeweapon;
		sound(pSeat->m_ePlayer, CHAN_ITEM, "common/wpn_hudon.wav", 0.5, ATTN_NONE);
	} else {
		sound(pSeat->m_ePlayer, CHAN_ITEM, "common/wpn_moveselect.wav", 0.5, ATTN_NONE);
		pSeat->m_iHUDWeaponSelected--;
		if (pSeat->m_iHUDWeaponSelected <= 0) {
			pSeat->m_iHUDWeaponSelected = g_weapons.length - 1;
		}
	}

	pSeat->m_flHUDWeaponSelectTime = time + 3;

	if not (pl.g_items & g_weapons[pSeat->m_iHUDWeaponSelected].id) {
		HUD_DrawWeaponSelect_Forward();
	}
}

void
HUD_DrawWeaponSelect_Back(void)
{
	player pl = (player)pSeat->m_ePlayer;

	if (!pl.activeweapon) {
		return;
	}

	if (pSeat->m_flHUDWeaponSelectTime < time) {
		pSeat->m_iHUDWeaponSelected = pl.activeweapon;
		sound(pSeat->m_ePlayer, CHAN_ITEM, "common/wpn_hudon.wav", 0.5, ATTN_NONE);
	} else {
		sound(pSeat->m_ePlayer, CHAN_ITEM, "common/wpn_moveselect.wav", 0.5, ATTN_NONE);
		pSeat->m_iHUDWeaponSelected++;
		if (pSeat->m_iHUDWeaponSelected >= g_weapons.length) {
			pSeat->m_iHUDWeaponSelected = 1;
		}
	}

	pSeat->m_flHUDWeaponSelectTime = time + 3;

	if not (pl.g_items & g_weapons[pSeat->m_iHUDWeaponSelected].id) {
		HUD_DrawWeaponSelect_Back();
	}
}

void
HUD_DrawWeaponSelect_Trigger(void)
{
	player pl = (player)pSeat->m_ePlayer;
	pl.activeweapon = pSeat->m_iHUDWeaponSelected;
	sendevent("PlayerSwitchWeapon", "i", pSeat->m_iHUDWeaponSelected);
	sound(pSeat->m_ePlayer, CHAN_ITEM, "common/wpn_select.wav", 0.5f, ATTN_NONE);
	pSeat->m_iHUDWeaponSelected = pSeat->m_flHUDWeaponSelectTime = 0;
}

void
HUD_DrawWeaponSelect_Last(void)
{
	player pl = (player)pSeat->m_ePlayer;
	if (pl.g_items & g_weapons[pSeat->m_iOldWeapon].id) {
		pl.activeweapon = pSeat->m_iOldWeapon;
		sendevent("PlayerSwitchWeapon", "i", pSeat->m_iOldWeapon);
	}
}

void
HUD_DrawWeaponSelect_Num(vector vecPos, float fValue)
{
	drawsubpic(vecPos, [20,20], g_hud7_spr, g_vecHUDNums[fValue], [20/256, 20/128], g_hud_color, 1, DRAWFLAG_ADDITIVE);
}

int
HUD_InSlotPos(int slot, int pos)
{
	player pl = (player)pSeat->m_ePlayer;
	for (int i = 1; i < g_weapons.length; i++) {
		if (g_weapons[i].slot == slot && g_weapons[i].slot_pos == pos) {
			if (pl.g_items & g_weapons[i].id) {
				return i;
			} else {
				return -1;
			}
		}
	}
	return -1;
}

void
HUD_SlotSelect(int slot)
{
	player pl = (player)pSeat->m_ePlayer;
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
		sound(pSeat->m_ePlayer, CHAN_ITEM, "common/wpn_hudon.wav", 0.5, ATTN_NONE);
	} else {
		sound(pSeat->m_ePlayer, CHAN_ITEM, "common/wpn_moveselect.wav", 0.5, ATTN_NONE);
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
}

void
HUD_DrawWeaponSelect(void)
{
	player pl = (player)pSeat->m_ePlayer;
	if (!pl.activeweapon) {
		return;
	}
	if (pSeat->m_flHUDWeaponSelectTime < time) {
		if (pSeat->m_iHUDWeaponSelected) {
			sound(pSeat->m_ePlayer, CHAN_ITEM, "common/wpn_hudoff.wav", 0.5, ATTN_NONE);
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
					Weapons_HUDPic(pSeat->m_iHUDWeaponSelected, 1, vecPos, 1.0f);
					drawsubpic(vecPos, [170,45], g_hud3_spr, 
								[0,180/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
					vecPos[1] += 50;
				} else if ((b=HUD_InSlotPos(i, x)) != -1) {
					// Unselected Sprite
					Weapons_HUDPic(b, 0, vecPos, 1.0f);
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
}
