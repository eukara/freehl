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
XenDecore:NSSurfacePropEntity
{
public:
	void XenDecore(void);

	virtual void SpawnKey(string, string);
	virtual void(void) Respawn;
	virtual void StartTouch(entity);

private:
	float m_flDamageTime;
	float m_flDamageTest;
	NSDict m_damageDecl;
};

void
XenDecore::XenDecore(void)
{
	m_flDamageTime = 0.0;
	m_flDamageTest = 0.0f;
	m_damageDecl = __NULL__;
}

void
XenDecore::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "dmgtime":
		m_flDamageTime = ReadFloat(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}

void
XenDecore::Respawn(void)
{
	if (1)
		SetSolid(SOLID_BBOX);
	else
		SetSolid(SOLID_NOT);

	SetOrigin(GetSpawnVector("origin"));
	SetAngles(GetSpawnVector("angles"));
	SetModel(GetSpawnString("model"));
	SetSize(GetSpawnVector("mins"), GetSpawnVector("maxs"));
	SetFrame(GetSpawnFloat("frame"));

	if (!m_damageDecl) {
		m_damageDecl = spawn(NSDict);
		m_damageDecl.AddKey("damage", GetSpawnString("damage"));
	}

	if (1) {
		DropToFloor();
	}
}

void
XenDecore::StartTouch(entity touchingEntity)
{
	if (m_flDamageTest > GetTime()) {
		return;
	}

	if (touchingEntity.takedamage == DAMAGE_NO) {
		return;
	}

	combat.Damage(touchingEntity, this, touchingEntity, m_damageDecl.GetDeclBody(), GetOrigin(), g_vec_null, touchingEntity.origin);

	m_flDamageTest = GetTime() + m_flDamageTime;
}
