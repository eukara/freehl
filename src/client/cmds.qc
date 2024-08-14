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

void HUD_DrawWeaponSelect_Back(void);
void HUD_DrawWeaponSelect_Forward(void);
void HUD_DrawWeaponSelect_Last(void);
void HUD_SlotSelect(int);

int
ClientGame_ConsoleCommand(void)
{
	switch(argv(0)) {
	case "chooseteam":
		sendevent("HLDM_Chooseteam", "s", argv(1));
		break;
	case "invnext":
		pSeatLocal->weaponSelectionHUD.SelectNext(false);
		break;
	case "invprev":
		pSeatLocal->weaponSelectionHUD.SelectPrevious(false);
		break;
	case "lastinv":
		//HUD_DrawWeaponSelect_Last();
		break;
	case "slot1":
		HUD_SlotSelect(0);
		break;
	case "slot2":
		HUD_SlotSelect(1);
		break;
	case "slot3":
		HUD_SlotSelect(2);
		break;
	case "slot4":
		HUD_SlotSelect(3);
		break;
	case "slot5":
		HUD_SlotSelect(4);
		break;
	case "slot6":
		HUD_SlotSelect(5);
		break;
	case "slot7":
		HUD_SlotSelect(6);
		break;
	case "slot8":
		HUD_SlotSelect(7);
		break;
	case "slot9":
		HUD_SlotSelect(8);
		break;
	case "slot10":
		HUD_SlotSelect(9);
		break;
	default:
		return (0);
	}
	return (1);
}
