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

class item_ammo:CBaseEntity
{
	void(void) item_ammo;
	virtual void(void) Respawn;
	virtual void(void) touch;
};

void item_ammo::touch(void)
{
	if not (other.flags & FL_CLIENT) {
		return;
	}

	player pl = (player)other;
	Sound_Play(other, CHAN_ITEM, "ammo.pickup");
	Weapons_RefreshAmmo(pl);
	Logging_Pickup(other, this, __NULL__);

	if (real_owner || cvar("sv_playerslots") == 1) {
		remove(self);
	} else {
		Hide();
		think = Respawn;
		nextthink = time + 20.0f;
	}
}

void item_ammo::Respawn(void)
{
	SetSolid(SOLID_TRIGGER);
	SetMovetype(MOVETYPE_TOSS);
	SetSize([-16,-16,0],[16,16,16]);
	SetOrigin(m_oldOrigin);
	SetModel(m_oldModel);

	think = __NULL__;
	nextthink = -1;

	if (real_owner)
		Sound_Play(this, CHAN_ITEM, "ammo.respawn");

	droptofloor();
}

void item_ammo::item_ammo(void)
{
	precache_model(model);
	m_oldModel = model;
	SetModel(m_oldModel);
	CBaseEntity::CBaseEntity();
}

/*QUAKED ammo_357 (0 0 0.8) (-16 -16 0) (16 16 32)

HALF-LIFE (1998) ENTITY

Ammo for the .357 Magnum Revolver.
A single ammo_357 will provide 6 bullets.

*/
class ammo_357:item_ammo
{
	void(void) ammo_357;
	virtual void(void) touch;
};

void ammo_357::ammo_357(void)
{
	model = "models/w_357ammobox.mdl";
	item_ammo::item_ammo();
}
void ammo_357::touch(void)
{
	if not (other.flags & FL_CLIENT) {
		return;
	}
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_357 < MAX_A_357) {
			pl.ammo_357 = bound(0, pl.ammo_357 + 6, MAX_A_357);
			item_ammo::touch();
		}
	}
}

/*QUAKED ammo_9mmAR (0 0 0.8) (-16 -16 0) (16 16 32)

HALF-LIFE (1998) ENTITY

Ammo for the 9mm Handgun and the 9mm AR.
A single ammo_9mmAR will provide 50 bullets.

*/
class ammo_9mmAR:item_ammo
{
	void(void) ammo_9mmAR;
	virtual void(void) touch;
};

void ammo_9mmAR::ammo_9mmAR(void)
{
	model = "models/w_9mmarclip.mdl";
	item_ammo::item_ammo();
}
void ammo_9mmAR::touch(void)
{
	if not (other.flags & FL_CLIENT) {
		return;
	}
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_9mm < MAX_A_9MM) {
			pl.ammo_9mm = bound(0, pl.ammo_9mm + 50, MAX_A_9MM);
			item_ammo::touch();
		}
	}
}
CLASSEXPORT(ammo_mp5clip, ammo_9mmAR)

/*QUAKED ammo_9mmbox (0 0 0.8) (-16 -16 0) (16 16 32)

HALF-LIFE (1998) ENTITY

Ammo for the 9mm Handgun and the 9mm AR.
A single ammo_9mmbox will provide 200 bullets.

*/
class ammo_9mmbox:item_ammo
{
	void(void) ammo_9mmbox;
	virtual void(void) touch;
};

void ammo_9mmbox::ammo_9mmbox(void)
{
	model = "models/w_chainammo.mdl";
	item_ammo::item_ammo();
}
void ammo_9mmbox::touch(void)
{
	if not (other.flags & FL_CLIENT) {
		return;
	}
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_9mm < MAX_A_9MM) {
			pl.ammo_9mm = bound(0, pl.ammo_9mm + 200, MAX_A_9MM);
			item_ammo::touch();
		}
	}
}

/*QUAKED ammo_9mmclip (0 0 0.8) (-16 -16 0) (16 16 32)

HALF-LIFE (1998) ENTITY

Ammo for the 9mm Handgun and the 9mm AR.
A single ammo_9mmclip will provide 17 bullets.

*/
class ammo_9mmclip:item_ammo
{
	void(void) ammo_9mmclip;
	virtual void(void) touch;
};

void ammo_9mmclip::ammo_9mmclip(void)
{
	model = "models/w_9mmclip.mdl";
	item_ammo::item_ammo();
}
void ammo_9mmclip::touch(void)
{
	if not (other.flags & FL_CLIENT) {
		return;
	}
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_9mm < MAX_A_9MM) {
			pl.ammo_9mm = bound(0, pl.ammo_9mm + 17, MAX_A_9MM);
			item_ammo::touch();
		}
	}
}

/*QUAKED ammo_ARgrenades (0 0 0.8) (-16 -16 0) (16 16 32)

HALF-LIFE (1998) ENTITY

Ammo for the 9mm AR's secondary fire.
A single ammo_ARgrenades will provide 2 AR grenades.

*/
class ammo_ARgrenades:item_ammo
{
	void(void) ammo_ARgrenades;
	virtual void(void) touch;
};

void ammo_ARgrenades::ammo_ARgrenades(void)
{
	model = "models/w_argrenade.mdl";
	item_ammo::item_ammo();
}
void ammo_ARgrenades::touch(void)
{
	if not (other.flags & FL_CLIENT) {
		return;
	}
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_m203_grenade < MAX_A_M203_GRENADE) {
			pl.ammo_m203_grenade = bound(0, pl.ammo_m203_grenade + 2, MAX_A_M203_GRENADE);
			item_ammo::touch();
		}
	}
}
CLASSEXPORT(ammo_mp5grenades, ammo_ARgrenades)

/*QUAKED ammo_buckshot (0 0 0.8) (-16 -16 0) (16 16 32)

HALF-LIFE (1998) ENTITY

Ammo for the Shotgun.
A single ammo_buckshot will provide 12 shells.

*/
class ammo_buckshot:item_ammo
{
	void(void) ammo_buckshot;
	virtual void(void) touch;
};

void ammo_buckshot::ammo_buckshot(void)
{
	model = "models/w_shotbox.mdl";
	item_ammo::item_ammo();
}
void ammo_buckshot::touch(void)
{
	if not (other.flags & FL_CLIENT) {
		return;
	}
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_buckshot < MAX_A_BUCKSHOT) {
			pl.ammo_buckshot = bound(0, pl.ammo_buckshot + 12, MAX_A_BUCKSHOT);
			item_ammo::touch();
		}
	}
}

/*QUAKED ammo_crossbow (0 0 0.8) (-16 -16 0) (16 16 32)

HALF-LIFE (1998) ENTITY

Ammo for the Crossbow.
A single ammo_crossbow will provide 5 bolts.

*/
class ammo_crossbow:item_ammo
{
	void(void) ammo_crossbow;
	virtual void(void) touch;
};

void ammo_crossbow::ammo_crossbow(void)
{
	model = "models/w_crossbow_clip.mdl";
	item_ammo::item_ammo();
}
void ammo_crossbow::touch(void)
{
	if not (other.flags & FL_CLIENT) {
		return;
	}
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_bolt < MAX_A_BOLT) {
			pl.ammo_bolt = bound(0, pl.ammo_bolt + 5, MAX_A_BOLT);
			item_ammo::touch();
		}
	}
}

/*QUAKED ammo_gaussclip (0 0 0.8) (-16 -16 0) (16 16 32)

HALF-LIFE (1998) ENTITY

Ammo for the Tau Cannon and the Gluon Gun.
A single ammo_gaussclip will provide 20 cells.

*/
class ammo_gaussclip:item_ammo
{
	void(void) ammo_gaussclip;
	virtual void(void) touch;
};

void ammo_gaussclip::ammo_gaussclip(void)
{
	model = "models/w_gaussammo.mdl";
	item_ammo::item_ammo();
}
void ammo_gaussclip::touch(void)
{
	if not (other.flags & FL_CLIENT) {
		return;
	}

	player pl = (player)other;
	if (pl.ammo_uranium < MAX_A_URANIUM) {
		pl.ammo_uranium = bound(0, pl.ammo_uranium + 20, MAX_A_URANIUM);
		item_ammo::touch();
	}
}

/*QUAKED ammo_rpgclip (0 0 0.8) (-16 -16 0) (16 16 32)

HALF-LIFE (1998) ENTITY

Ammo for the RPG.
A single ammo_rpgclip will provide 1 rocket.

*/
class ammo_rpgclip:item_ammo
{
	void(void) ammo_rpgclip;
	virtual void(void) touch;
};

void ammo_rpgclip::ammo_rpgclip(void)
{
	model = "models/w_rpgammo.mdl";
	item_ammo::item_ammo();
}
void ammo_rpgclip::touch(void)
{
	if not (other.flags & FL_CLIENT) {
		return;
	}

	player pl = (player)other;
	if (pl.ammo_rocket < MAX_A_ROCKET) {
		pl.ammo_rocket = bound(0, pl.ammo_rocket + 1, MAX_A_ROCKET);
		item_ammo::touch();
	}
}
