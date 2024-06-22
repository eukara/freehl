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
Half-Life specific weapon based on NSWeapon.

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
HLWeapon:NSWeapon
{
	void HLWeapon(void);

	bool m_bAltModeSwitch;
	virtual void AddedToInventory(void);
	virtual void PrimaryAttack(void);
	virtual void SecondaryAttack(void);

#ifdef SERVER
	virtual void SpawnKey(string, string);
#endif

#ifdef CLIENT
	int m_iHudSlot;
	int m_iHudSlotPos;

	string m_ammoIcon;
	string m_crossHair;
	NSWeapon m_nextWeapon;
	virtual void UpdateGUI(void);
	nonvirtual void DrawLaser(void);
#endif
};

void
HLWeapon::HLWeapon(void)
{

}

#ifdef SERVER
void
HLWeapon::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "altLaser":
	case "ammoIcon":
	case "crosshair":
	case "hudSlot":
	case "hudSlotPos":
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}
#endif

void
HLWeapon::PrimaryAttack(void)
{
	if (m_bAltModeSwitch == true) {
		if (CanFire() == false) {
			return;
		}

		//m_iMode = 1 - m_iMode;
	}

	if (m_iMode) {
		super::SecondaryAttack();
		return;
	}

	super::PrimaryAttack();
}

void
HLWeapon::SecondaryAttack(void)
{
	if (m_bAltModeSwitch == true) {
		if (CanFire() == false) {
			return;
		}

		m_iMode = 1 - m_iMode;
		SetAttackNext(1.0);
		SetIdleNext(1.0f);
		return;
	}

	super::SecondaryAttack();
}


void
HLWeapon::AddedToInventory(void)
{
	super::AddedToInventory();

#ifdef CLIENT
	m_ammoIcon = GetDefString("ammoIcon");

	if (m_ammoIcon == "") {
		m_ammoIcon = sprintf("%s.ammo", strtolower(classname));
	}

	m_crossHair = GetDefString("crosshair");

	if (m_crossHair == "") {
		m_crossHair = sprintf("%s.crosshair", strtolower(classname));
	}

	if (m_ammoIcon == "none") {
		m_ammoIcon = __NULL__;
	}

	if (m_crossHair == "none") {
		m_crossHair = __NULL__;
	}

	m_iHudSlot = GetDefInt("hudSlot");
	m_iHudSlotPos = GetDefInt("hudSlotPos");
#endif

	m_bAltModeSwitch = GetDefBool("altLaser");
}

#ifdef CLIENT
void
HLWeapon::UpdateGUI(void)
{
	NSClientPlayer ourOwner = __NULL__;

	/* draw crosshair */
	HLSprite_DrawCrosshair(m_crossHair);

	/* draw ammo icon */
	if (m_ammoIcon) {
		vector ammoPos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
		HLSprite_Draw_RGBA(m_ammoIcon, ammoPos, g_hud_color, pSeatLocal->m_flAmmo2Alpha, true);
	}

	if (m_iMode) {
		DrawLaser();
	}

	if (m_bAmmoRequired == false)
		return;

	ourOwner = (NSClientPlayer)GetOwner();

	if (m_iClipSize > 0i) {
		ourOwner.a_ammo1 = m_iClip;
		HUD_DrawAmmo1();
	}

	ourOwner.a_ammo2 = ourOwner.GetReserveAmmo(m_primaryAmmoType);
	HUD_DrawAmmo2();

	if (m_secondaryAmmoType && m_primaryAmmoType != m_secondaryAmmoType) {
		ourOwner.a_ammo3 = ourOwner.GetReserveAmmo(m_secondaryAmmoType);
		HUD_DrawAmmo3();
	}
}

void
HLWeapon::DrawLaser(void)
{
	NSClientPlayer ourOwner = (NSClientPlayer)GetOwner();
	float lerpValue;
	vector laser_pos = g_vec_null;
	vector jitter = [0.0f, 0.0f, 0.0f];

	vector src = ourOwner.GetEyePos();
	traceline(src, src + (anglesToForward(ourOwner.v_angle) * 256), FALSE, ourOwner);
	lerpValue = lerp(18,6, trace_fraction);
	jitter[0] = (random(0,2) - 2) * (1 - trace_fraction);
	jitter[1] = (random(0,2) - 2) * (1 - trace_fraction);
	laser_pos = g_hudmins + (g_hudres / 2) + ([-lerpValue,-lerpValue] / 2);

	drawsubpic(
		laser_pos + jitter,
		[lerpValue,lerpValue],
		g_laser_spr,
		[0,0],
		[1.0, 1.0],
		[1,1,1],
		1.0f,
		DRAWFLAG_ADDITIVE
	);
}
#endif
