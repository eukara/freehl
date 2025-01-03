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

/*! \brief Half-Life weapon base class. */
/*!QUAKED HLWeapon (0 0.8 0.8) (-16 -16 0) (16 16 72) 
# OVERVIEW
Half-Life specific weapon based on ncWeapon.

# NEW KEYS
- "ammoIcon" - Which sprites/ image to use. See notes.
- "crosshair" - Which sprites/ image to use as a crosshair. See notes.
- "hudSlot" - In which weapon selection slot this weapon belongs to.
- "hudSlotPos" - The position of the weapon in the respective weapon selection slot.

# NOTES
Both `ammoIcon` and `crosshair` refer to sprite declarations inside the sprites/ directory. FreeHL scans the `sprites/hud.txt` file and and weapon specific files.
Since the weapon specific files only contain short names like `ammo` and `crosshair` you have to refer to them with a prefix separated by a `.` period symbol.

For example, `ammoIcon` being set to `weapon_foobar.ammo` will look up `ammo` inside `sprites/weapon_foobar.txt`.
*/
class
HLWeapon:ncWeapon
{
public:
	void HLWeapon(void);

	virtual void AddedToInventory(void);

#ifdef SERVER
	virtual void SpawnKey(string, string);
#endif

#ifdef CLIENT
	virtual void UpdateGUI(void);
	nonvirtual void DrawLaser(void);
#endif

private:
#ifdef CLIENT
	int m_iHudSlot;
	int m_iHudSlotPos;
	string m_ammoIcon;
	string m_ammo2Icon;
	string m_crossHair;
	string m_icon;
	string m_iconSel;
	ncWeapon m_nextWeapon;
#endif
	bool m_bAltModeLaser;
};