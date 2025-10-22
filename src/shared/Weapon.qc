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
hlWeapon::hlWeapon(void)
{
#ifdef CLIENT
	m_nextWeapon = __NULL__;
#endif
	m_bAltModeLaser = false;
}

#ifdef SERVER
void
hlWeapon::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	default:
		super::SpawnKey(keyName, setValue);
	}
}
#endif

void
hlWeapon::ReloadCachedAttributes(void)
{
	super::ReloadCachedAttributes();

#ifdef CLIENT
	m_weaponHUDIcon = GetDefString("icon");

	if (!STRING_SET(m_weaponHUDIcon)) {
		m_weaponHUDIcon = sprintf("%s.weapon", strtolower(declclass));
	}

	m_weaponHUDIconSel = GetDefString("iconSelected");

	if (!STRING_SET(m_weaponHUDIconSel)) {
		m_weaponHUDIconSel = sprintf("%s.weapon_s", strtolower(declclass));
	}

	if (m_weaponHUDIcon == "none") {
		m_weaponHUDIcon = __NULL__;
	}

	if (m_weaponHUDIconSel == "none") {
		m_weaponHUDIconSel = __NULL__;
	}

	m_weaponHUDSlot = GetDefInt("hudSlot");
	m_weaponHUDSlotPos = GetDefInt("hudSlotPos");
#endif

	m_bAltModeLaser = GetDefBool("altLaser");
}

#ifdef SERVER

void
hlWeapon::SwitchedFromWeapon(void)
{
	if (m_laserEntity) {
		m_laserEntity.Destroy();
		m_laserEntity = 0;
	}
}

void
hlWeapon::FireInfoChanged(void)
{
	static void UpdateLaser(void) {
		ncEntity ourOwner = (ncEntity)owner;
		vector src = ourOwner.GetEyePos();
		vector dir = anglesToForward(owner.v_angle);
		traceline(src, src + (dir * 4096.0f), MOVE_NORMAL, owner);
		setorigin(self, trace_endpos + (dir * -4));
	}

	if (FireInfoSelected() && m_bAltModeLaser) {
		if (m_laserEntity) {
			return;
		}

		m_laserEntity = spawn(ncRenderableEntity);
		m_laserEntity.SetModel("sprites/laserdot.spr");
		m_laserEntity.SetRenderMode(RM_ADDITIVE);
		m_laserEntity.SetRenderColor([255, 255, 255]);
		m_laserEntity.SetRenderAmt(255);
		m_laserEntity.customphysics = UpdateLaser;
		m_laserEntity.owner = owner;
	} else {
		if (m_laserEntity) {
			m_laserEntity.Destroy();
			m_laserEntity = 0;
		}
	}
}
#endif

#ifdef CLIENT
void
hlWeapon::UpdateGUI(void)
{
#if 0
	ncPlayer ourOwner = __NULL__;
	vector ammoPos;

	/* draw crosshair */
	HLSprite_DrawCrosshair(m_crossHair);

	/* draw ammo icon */
	if (STRING_SET(m_ammoIcon)) {
		ammoPos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
		HLSprite_Draw_RGBA(m_ammoIcon, ammoPos, g_hud_color, pSeatLocal->m_flAmmo2Alpha, true);
	}

#if 1
	vector vSize = [540,16];
	vector vMainPos;
	float progress;

	progress = (OverheatingProgress() / m_fiOverheatLength);

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
#endif
}
#endif
