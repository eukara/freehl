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

class
HLWeaponSelect
{
public:
	void HLWeaponSelect(void);

	virtual void Draw(void);
	virtual void SelectSlot(int, bool);
	virtual void SelectNext(bool);
	virtual void SelectPrevious(bool);

	nonvirtual void Event_Opened(void);
	nonvirtual void Event_Closed(void);
	nonvirtual void Event_SelectionChanged(void);
	nonvirtual void Event_SelectionTriggered(void);

	virtual bool Active(void);
	virtual void Trigger(void);
	virtual void Deactivate(void);

	virtual void DrawSlotNum(vector, float);

private:
	float m_flHUDWeaponSelectTime;
	entity m_selectedWeapon;
	entity m_firstWeapon;
	entity m_lastWeapon;
	int m_iWantSlot;
	int m_iWantSlotPos;
};
