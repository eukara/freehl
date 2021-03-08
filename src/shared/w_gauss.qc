/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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

/*QUAKED weapon_gauss (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_gauss.mdl"

HALF-LIFE (1998) ENTITY

Gauss Weapon

*/

#ifdef CLIENT
#define FXGAUSS_BEAMCOLOR [1,0.5,0]
class FXGauss:CBaseFX
{
	int m_iBeams;
	vector m_vecStart;
	vector m_vecAngle;

	void(void) FXGauss;
	virtual void(void) Draw;
};

void
FXGauss::Draw(void)
{
	player pl = (player)self;
	int iLoop = 6;
	vector src, endpos;
	vector gunpos = gettaginfo(pSeat->m_eViewModel, 33);

	if (alpha <= 0.0f) {
		return;
	}

	src = m_vecStart;
	makevectors(input_angles);
	endpos = src + v_forward * 1024;
	traceline(src, endpos, FALSE, pl);

	/* drawing the first bit */
	vector fsize = [3,3];
	makevectors(view_angles);
	R_BeginPolygon("sprites/xbeam1.spr_0.tga", 1, 0);
		R_PolygonVertex(gunpos + v_right * fsize[0] - v_up * fsize[1],
			[1,1], FXGAUSS_BEAMCOLOR, alpha);
		R_PolygonVertex(gunpos - v_right * fsize[0] - v_up * fsize[1],
			[0,1], FXGAUSS_BEAMCOLOR, alpha);
		R_PolygonVertex(trace_endpos - v_right * fsize[0] + v_up * fsize[1],
			[0,0], FXGAUSS_BEAMCOLOR, alpha);
		R_PolygonVertex(trace_endpos + v_right * fsize[0] + v_up * fsize[1],
			[1,0], FXGAUSS_BEAMCOLOR, alpha);
	R_EndPolygon();

	if (m_iBeams == 0) {
		alpha -= clframetime * 3;
		return;
	}

	// reflection equation:
	vector x = v_forward;
	while (iLoop > 0) {
		float n;
		vector r;
		n = -dotproduct(trace_plane_normal, x);
		r = 2 * trace_plane_normal * n + x;
		x = r;
		src = trace_endpos + (x * 1);
		endpos = trace_endpos + (x * 8192);
		traceline(src, endpos, FALSE, pl);

		makevectors(view_angles);
		R_BeginPolygon("sprites/xbeam1.spr_0.tga", 1, 0);
			R_PolygonVertex(src + v_right * fsize[0] - v_up * fsize[1],
				[1,1], FXGAUSS_BEAMCOLOR, alpha);
			R_PolygonVertex(src - v_right * fsize[0] - v_up * fsize[1],
				[0,1], FXGAUSS_BEAMCOLOR, alpha);
			R_PolygonVertex(trace_endpos - v_right * fsize[0] + v_up * fsize[1],
				[0,0], FXGAUSS_BEAMCOLOR, alpha);
			R_PolygonVertex(trace_endpos + v_right * fsize[0] + v_up * fsize[1],
				[1,0], FXGAUSS_BEAMCOLOR, alpha);
		R_EndPolygon();
	
		iLoop--;
	}
	alpha -= clframetime * 3;
}

void
FXGauss::FXGauss(void)
{
	CBaseFX::CBaseFX();
}
#endif

enum
{
	GAUSS_IDLE1,
	GAUSS_IDLE2,
	GAUSS_FIDGET,
	GAUSS_SPINUP,
	GAUSS_SPIN,
	GAUSS_FIRE1,
	GAUSS_FIRE2,
	GAUSS_HOLSTER,
	GAUSS_DRAW
};

void w_gauss_release(void);

void w_gauss_precache(void)
{
#ifdef SERVER
	precache_model("models/w_gauss.mdl");
	precache_model("sprites/yelflare1.spr");
	precache_model("sprites/xbeam1.spr");
	precache_sound("weapons/electro4.wav");
	precache_sound("weapons/electro5.wav");
	precache_sound("weapons/electro6.wav");
	precache_sound("weapons/gauss2.wav");
#else
	precache_sound("ambience/pulsemachine.wav");
	precache_model("models/v_gauss.mdl");
	precache_model("models/p_gauss.mdl");
#endif
}
void w_gauss_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, pl.ammo_uranium, -1);
}
string w_gauss_wmodel(void)
{
	return "models/w_gauss.mdl";
}
string w_gauss_pmodel(void)
{
	return "models/p_gauss.mdl";
}
string w_gauss_deathmsg(void)
{
	return "";
}

int w_gauss_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (pl.ammo_uranium < MAX_A_URANIUM) {
		pl.ammo_uranium = bound(0, pl.ammo_uranium + 20, MAX_A_URANIUM);
	} else {
		return FALSE;
	}
#endif
	return TRUE;
}

void w_gauss_draw(void)
{
	player pl = (player)self;
	pl.mode_tempstate = 0;

	/* link the FX class */
#ifdef CLIENT
	Weapons_SetModel("models/v_gauss.mdl");
	Weapons_ViewAnimation(GAUSS_DRAW);

	entity eold = self;
	self = pSeat->m_pWeaponFX;
	spawnfunc_FXGauss();
	self = eold;
#endif
}

void w_gauss_holster(void)
{
	Weapons_ViewAnimation(GAUSS_HOLSTER);
}

#ifdef SERVER
void w_gauss_fire(int one)
{
	player pl = (player)self;
	int iLoop = 6;

	Weapons_MakeVectors();
	vector src = Weapons_GetCameraPos();
	vector endpos = src + v_forward * 1024;
	traceline(src, endpos, FALSE, pl);
	sound(pl, CHAN_WEAPON, "weapons/gauss2.wav", 1, ATTN_NORM);
	int iDamage = one ? 20 : 200;

	if (getsurfacetexture(trace_ent, getsurfacenearpoint(trace_ent, trace_endpos)) == "sky") {
		return;
	}

	if (trace_ent.takedamage == DAMAGE_YES) {
		Damage_Apply(trace_ent, self, iDamage, WEAPON_GAUSS, DMG_ELECTRO);
		sound(trace_ent, CHAN_ITEM, sprintf("weapons/electro%d.wav", random(0,3)+4), 1, ATTN_NORM);
	}
	if (one) {
		return;
	} else {
		/* Apply force */
		if (pl.flags & FL_ONGROUND) {
			pl.velocity += v_forward * -400;
		} else {
			pl.velocity += v_forward * -800;
		}
	}

	// reflection equation:
	vector dir = v_forward;
	while (iLoop > 0) {
		float n;
		vector r;
		n = -dotproduct(trace_plane_normal, dir);
		r = 2 * trace_plane_normal * n + dir;
		dir = r;
		src = trace_endpos + (dir * 1);
		endpos = trace_endpos + (dir * 8192);
		traceline(src, endpos, FALSE, pl);
		te_beam(world, src, trace_endpos);
		iLoop--;
		if (trace_ent.takedamage == DAMAGE_YES) {
			Damage_Apply(trace_ent, self, iDamage, WEAPON_GAUSS, DMG_ELECTRO);
			sound(trace_ent, CHAN_ITEM, sprintf("weapons/electro%d.wav", random(0,3)+4), 1, ATTN_NORM);
		}
		
		if (getsurfacetexture(trace_ent, getsurfacenearpoint(trace_ent, trace_endpos)) != "sky") {
			Decals_Place(trace_endpos, "{gaussshot1");
		} else {
			break;
		}
	}
}
#endif

void w_gauss_primary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* Ammo check */
#ifdef CLIENT
	if (pl.a_ammo2 < 2) {
		return;
	}
#else
	if (pl.ammo_uranium < 2) {
		return;
	}
#endif

	Weapons_ViewAnimation(GAUSS_FIRE2);
#ifdef CLIENT
	FXGauss p = (FXGauss)pSeat->m_pWeaponFX;
	p.m_iBeams = 0;
	p.m_vecAngle = input_angles;
	p.m_vecStart = pl.origin + pl.view_ofs;
	p.alpha = 1.0f;
	pl.a_ammo2 -= 2;
	Weapons_ViewPunchAngle([-2,0,0]);
#else
	pl.ammo_uranium -= 2;
	w_gauss_fire(1);
#endif

	pl.w_attack_next = 0.2f;
	pl.w_idle_next = 2.5f;
}
void w_gauss_secondary(void)
{
	player pl = (player)self;

#ifdef CLIENT
	if (pl.mode_tempstate)
		soundupdate(pl, CHAN_WEAPON, "", 2, ATTN_NORM, 100 + (200 * (pl.ammo_gauss_volume/255)), 0, 0);
#endif
	
	if (pl.w_attack_next) {
		return;
	}
	pl.w_attack_next = 0.1f;

	/* Ammo check */
#ifdef CLIENT
    if (pl.a_ammo2 <= 0) {
        if (pl.mode_tempstate > 0) {
			w_gauss_release();
		}
		return;
    }
#else
    if (pl.ammo_uranium <= 0) {
        if (pl.mode_tempstate > 0) {
            w_gauss_release();
        }
		return;
    }
#endif

#ifdef CLIENT
	if (pl.ammo_gauss_volume < 255)
		pl.a_ammo2--;
#else
	if (pl.ammo_gauss_volume < 255)
		pl.ammo_uranium--;
#endif

	/* Set pitch sound shift */
	pl.ammo_gauss_volume += 16;
	if (pl.ammo_gauss_volume > 255) {
		pl.ammo_gauss_volume = 255;
	}

	if (pl.mode_tempstate == 1) {
		Weapons_ViewAnimation(GAUSS_SPIN);
		pl.mode_tempstate = 2;
		pl.w_idle_next = 0.0f;
	} else if (!pl.mode_tempstate) {
		Weapons_ViewAnimation(GAUSS_SPINUP);
#ifdef CLIENT
		sound(pl, CHAN_WEAPON, "ambience/pulsemachine.wav", 2, ATTN_NORM);
#endif
		pl.mode_tempstate = 1;
	}
}

void w_gauss_release(void)
{
	player pl = (player)self;
	if (pl.w_idle_next > 0.0) {
		return;
	}

	/* Reset the pitch sound shift */
	pl.ammo_gauss_volume = 0;

	if (pl.mode_tempstate == 1) {
		pl.w_attack_next = 0.0f;
		pl.w_idle_next = 4.0f;
		w_gauss_primary();
		pl.mode_tempstate = 0;
		return;
	} else if (pl.mode_tempstate == 2) {
		Weapons_ViewAnimation(GAUSS_FIRE1);
#ifdef CLIENT
		FXGauss p = (FXGauss)pSeat->m_pWeaponFX;
		p.m_iBeams = 1;
		p.m_vecAngle = input_angles;
		p.m_vecStart = pl.origin + pl.view_ofs;
		p.alpha = 1.0f;
		soundupdate(pl, CHAN_WEAPON, "", -1, ATTN_NORM, 0, 0, 0);
		Weapons_ViewPunchAngle([-5,0,0]);
#else
		w_gauss_fire(0);
#endif
		pl.w_attack_next = 1.5f;
		pl.w_idle_next = 4.0f;
		pl.mode_tempstate = 0;
		return;
	}

	int r = (float)input_sequence % 3;
	switch (r) {
	case 1:
		Weapons_ViewAnimation(GAUSS_IDLE2);
		pl.w_idle_next = 4.0f;
		break;
#ifndef GEARBOX
	case 2:
		Weapons_ViewAnimation(GAUSS_FIDGET);
		pl.w_idle_next = 3.0f;
		break;
#endif
	default:
		Weapons_ViewAnimation(GAUSS_IDLE1);
		pl.w_idle_next = 4.0f;
		break;
	}
}

void w_gauss_crosshair(void)
{
#ifdef CLIENT
	vector cross_pos;
	vector aicon_pos;

	cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];
	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];

	drawsubpic(
		cross_pos,
		[24,24],
		g_cross_spr,
		[48/128,48/128],
		[0.1875, 0.1875],
		[1,1,1],
		1,
		DRAWFLAG_NORMAL
	);

	drawsubpic(
		aicon_pos,
		[24,24],
		g_hud7_spr,
		[0,96/128],
		[24/256,24/128],
		g_hud_color,
		pSeat->m_flAmmo2Alpha,
		DRAWFLAG_ADDITIVE
	);

	HUD_DrawAmmo2();
#endif
}

float w_gauss_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMGAUSS : ANIM_AIMGAUSS;
}

void w_gauss_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;
	vector hud_col;

	if (pl.ammo_uranium == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud5_spr,
			[0,90/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			g_hud2_spr,
			[0,90/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_uranium, MAX_A_URANIUM, a);
#endif
}

weapon_t w_gauss =
{
	.name		= "gauss",
	.id		= ITEM_GAUSS,
	.slot		= 3,
	.slot_pos	= 1,
	.draw		= w_gauss_draw,
	.holster	= w_gauss_holster,
	.primary	= w_gauss_primary,
	.secondary	= w_gauss_secondary,
	.reload		= __NULL__,
	.release	= w_gauss_release,
	.crosshair	= w_gauss_crosshair,
	.precache	= w_gauss_precache,
	.pickup		= w_gauss_pickup,
	.updateammo	= w_gauss_updateammo,
	.wmodel		= w_gauss_wmodel,
	.pmodel		= w_gauss_pmodel,
	.deathmsg	= w_gauss_deathmsg,
	.aimanim	= w_gauss_aimanim,
	.hudpic		= w_gauss_hudpic
};

#ifdef SERVER
void weapon_gauss(void) {
	Weapons_InitItem(WEAPON_GAUSS);
}
#endif
