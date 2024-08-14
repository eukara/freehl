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
HLWeapon::HLWeapon(void)
{
#ifdef CLIENT
	m_iHudSlot = 0i;
	m_iHudSlotPos = 0i;
	m_ammoIcon = __NULL__;
	m_ammo2Icon = __NULL__;
	m_crossHair = __NULL__;
	m_nextWeapon = __NULL__;
#endif
	m_bAltModeLaser = false;
}

#ifdef SERVER
void
HLWeapon::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	default:
		super::SpawnKey(keyName, setValue);
	}
}
#endif

void
HLWeapon::AddedToInventory(void)
{
	super::AddedToInventory();

#ifdef CLIENT
	m_ammoIcon = GetDefString("ammoIcon");

	if (m_ammoIcon == "") {
		m_ammoIcon = sprintf("%s.ammo", strtolower(classname));
	}

	m_ammo2Icon = GetDefString("ammoIcon");

	if (m_ammo2Icon == "") {
		m_ammo2Icon = sprintf("%s.ammo2", strtolower(classname));
	}

	m_crossHair = GetDefString("crosshair");

	if (m_crossHair == "") {
		m_crossHair = sprintf("%s.crosshair", strtolower(classname));
	}

	m_icon = GetDefString("icon");

	if (m_icon == "") {
		m_icon = sprintf("%s.weapon", strtolower(classname));
	}

	m_iconSel = GetDefString("iconSelected");

	if (m_iconSel == "") {
		m_iconSel = sprintf("%s.weapon_s", strtolower(classname));
	}

	if (m_ammoIcon == "none") {
		m_ammoIcon = __NULL__;
	}

	if (m_ammo2Icon == "none") {
		m_ammo2Icon = __NULL__;
	}

	if (m_crossHair == "none") {
		m_crossHair = __NULL__;
	}

	if (m_icon == "none") {
		m_icon = __NULL__;
	}

	if (m_iconSel == "none") {
		m_iconSel = __NULL__;
	}


	m_iHudSlot = GetDefInt("hudSlot");
	m_iHudSlotPos = GetDefInt("hudSlotPos");
#endif

	m_bAltModeLaser = GetDefBool("altLaser");
}

#ifdef CLIENT
void
HLWeapon::UpdateGUI(void)
{
	NSClientPlayer ourOwner = __NULL__;
	vector ammoPos;

	/* draw crosshair */
	HLSprite_DrawCrosshair(m_crossHair);

	/* draw ammo icon */
	if (m_ammoIcon) {
		ammoPos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
		HLSprite_Draw_RGBA(m_ammoIcon, ammoPos, g_hud_color, pSeatLocal->m_flAmmo2Alpha, true);
	}

	if (m_iMode && m_bAltModeLaser) {
		DrawLaser();
	}

#if 1
	vector vSize = [540,16];
	vector vMainPos;
	float progress;

	progress = (m_flOverheating / m_fiOverheatLength);

	if (progress > 1.0) {
		progress = 1.0f;
	}

	if (m_fiOverheatLength && progress > 0) {
		vMainPos = g_hudmins;
		vMainPos[0] += (g_hudres[0] / 2) - (vSize[0] / 2);
		vMainPos[1] += (g_hudres[1] / 2) - (vSize[1] / 2);

		vector vBar = vSize;
		vBar[0] = 538 * progress;
		vBar[1] = 14;
		drawfill(vMainPos + [1,1], vBar, g_hud_color, 1.0, DRAWFLAG_ADDITIVE);
		drawfill(vMainPos, [vSize[0], 1], g_hud_color, 1.0f); // Top
		drawfill([vMainPos[0], vMainPos[1] + vSize[1]], [vSize[0], 1], g_hud_color, 1.0f); // Bottom
		drawfill(vMainPos, [1, vSize[1]], g_hud_color, 1.0f); // Left
		drawfill([vMainPos[0] + vSize[0], vMainPos[1]], [1, vSize[1] + 1], g_hud_color, 1.0f); // Right
	}
#endif

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

		/* draw ammo icon */
		if (m_ammo2Icon) {
			ammoPos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 74];
			HLSprite_Draw_RGBA(m_ammo2Icon, ammoPos, g_hud_color, pSeatLocal->m_flAmmo2Alpha, true);
		}
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
