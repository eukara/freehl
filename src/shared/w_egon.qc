/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
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

#ifdef CLIENT
var float TRAIL_EGONBEAM;

string w_egon_sparkframes[11];

void
w_egon_beamfx(vector vecPos, vector vecEndPos, entity eOwner)
{
	trailparticles(TRAIL_EGONBEAM, eOwner, vecPos, vecEndPos);
}
#endif

enum
{
	EGON_IDLE1,
	EGON_FIDGET1,
	EGON_ALTFIREON,
	EGON_ALTFIRECYCLE,
	EGON_ALTFIREOFF,
	EGON_FIRE1,
	EGON_FIRE2,
	EGON_FIRE3,
	EGON_FIRE4,
	EGON_DRAW,
	EGON_HOLSTER
};

void w_egon_precache(void)
{
#ifdef SERVER
	precache_sound("weapons/egon_windup2.wav");
	precache_sound("weapons/egon_run3.wav");
	precache_sound("weapons/egon_off1.wav");
	precache_model("models/w_egon.mdl");
	Sound_Precache("weapon_egon.empty");
#else
	TRAIL_EGONBEAM = particleeffectnum("weapon_egon.beam");
	precache_model("models/v_egon.mdl");
	precache_model("models/p_egon.mdl");
	precache_model("sprites/xspark1.spr");

	for (int i = 0; i < 11; i++)
		w_egon_sparkframes[i] = spriteframe("sprites/xspark1.spr", i, 0.0f);
#endif
}

void w_egon_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, pl.ammo_uranium, -1);
}

string w_egon_wmodel(void)
{
	return "models/w_egon.mdl";
}

string w_egon_pmodel(player pl)
{
	return "models/p_egon.mdl";
}

string w_egon_deathmsg(void)
{
	return "";
}

int w_egon_pickup(player pl, int new, int startammo)
{
#ifdef SERVER
	int addAmmo = (startammo == -1) ? 20 : startammo;

	if (pl.ammo_uranium < MAX_A_URANIUM) {
		pl.ammo_uranium = bound(0, pl.ammo_uranium + addAmmo, MAX_A_URANIUM);
	} else {
		if (!new)
			return (0);
	}
#endif
	return (1);
}

void w_egon_draw(player pl)
{
	pl.mode_tempstate = 0;

	Weapons_SetModel("models/v_egon.mdl");
	Weapons_ViewAnimation(pl, EGON_DRAW);
}

void w_egon_holster(player pl)
{
	Weapons_ViewAnimation(pl, EGON_HOLSTER);
}

void w_egon_release(player pl);

void w_egon_primary(player pl)
{
	if (pl.w_attack_next > 0.0f) {
		return;
	}
	if (pl.gflags & GF_SEMI_TOGGLED) {
		w_egon_release(pl);
		return;
	}

	/* Ammo check */
	bool out_of_ammo = (pl.ammo_uranium <= 0i) ? true : false;
	if (out_of_ammo || pl.WaterLevel() >= WATERLEVEL_SUBMERGED) {
#ifdef SERVER
		Sound_Play(pl, CHAN_AUTO, "weapon_egon.empty");
#endif
		pl.gflags |= GF_SEMI_TOGGLED;
		w_egon_release(pl);
		return;
	}

#ifdef SERVER
	Weapons_MakeVectors(pl);
	vector src = Weapons_GetCameraPos(pl);
	vector endpos = src + v_forward * 1024;
	traceline(src, endpos, FALSE, pl);
	Damage_Radius(trace_endpos, pl, 14, 64, TRUE, WEAPON_EGON);
	Client_ShakeOnce(trace_endpos, 128, 0.2, 1.0, 1.0f);
#endif

	int r = (float)input_sequence % 2.0f;

	pl.ammo_uranium--;
	pl.gflags |= GF_EGONBEAM;

	if (pl.mode_tempstate == 0) {
#ifdef SERVER
		sound(pl, CHAN_WEAPON, "weapons/egon_windup2.wav", 1, ATTN_NORM, 100, 0);
#endif
		pl.mode_tempstate = 1;
		//Weapons_ViewPunchAngle(pl, [-5,0,0]);
		if (r) {
			Weapons_ViewAnimation(pl, EGON_FIRE3);
		} else {
			Weapons_ViewAnimation(pl, EGON_FIRE4);
		}
		pl.w_idle_next = 1.5f;
	} else if not (pl.w_idle_next > 0.0f) {
		/* wait 3 seconds (idle next) */
		if (pl.mode_tempstate == 1) {
			if (r) {
				Weapons_ViewAnimation(pl, EGON_FIRE3);
			} else {
				Weapons_ViewAnimation(pl, EGON_FIRE4);
			} 
#ifdef SERVER
			sound(pl, CHAN_WEAPON, "weapons/egon_run3.wav", 1, ATTN_NORM, 100);
#endif
			pl.mode_tempstate = 2;
		}
		pl.w_idle_next = 3.0f;
	}

	pl.w_attack_next = 0.2f;
}

void w_egon_reload(player pl)
{
	
}

void w_egon_release(player pl)
{
	if (pl.mode_tempstate != 0 && pl.mode_tempstate < 3) {
#ifdef SERVER
		sound(pl, CHAN_WEAPON, "weapons/egon_off1.wav", 1, ATTN_NORM, 100, 0);
#endif
		pl.mode_tempstate = 3;
		//Weapons_ViewPunchAngle(pl, [-2,0,0]);
	}

	pl.gflags &= ~GF_EGONBEAM;

	if (pl.mode_tempstate == 3) {
		/* This is hack that is unwise for custom content, but it needs to terminate. */
		Weapons_ViewAnimation(pl, EGON_FIRE1);
		pl.w_idle_next = 1.0f;
		pl.w_attack_next = 1.1f;
		pl.mode_tempstate = 0;
	} else {
		if (pl.w_idle_next > 0.0f) {
			return;
		}
		int r = floor(pseudorandom() * 3.0f);
		if (r == 1) {
			Weapons_ViewAnimation(pl, EGON_FIDGET1);
			pl.w_idle_next = 2.666667f;
		} else {
			Weapons_ViewAnimation(pl, EGON_IDLE1);
			pl.w_idle_next = 2.0f;
		}
		pl.mode_tempstate = 0;
	}
}

void
w_egon_postdraw(player pl, int thirdperson)
{
#ifdef CLIENT
	if (!(pl.gflags & GF_EGONBEAM))
		return;

	vector src;
	vector endpos;

	if (thirdperson) {
		makevectors(pl.v_angle);
		src = pl.origin;
		endpos = pl.origin + (v_forward * 1024);
		traceline(src, endpos, MOVE_NORMAL, pl);
		w_egon_beamfx(gettaginfo(pl.p_model, 10), trace_endpos, pl);
	} else {
		vector gunpos = gettaginfo(pSeat->m_eViewModel, 33);
		src = gettaginfo(pSeat->m_eViewModel, 0);
		makevectors(view_angles);
		endpos = src + v_forward * 1024;
		traceline(src, endpos, FALSE, pl);
		w_egon_beamfx(gunpos, endpos, pl);
	}

	int i = (cltime*10.0f) % 11.0f;
	vector fsize = [32,32];
	makevectors(view_angles);
	trace_endpos += v_forward * -16; /* nudge towards our camera */
	dynamiclight_add(trace_endpos, 128, [0.5, 0.5, 1.0]);

	R_BeginPolygon(w_egon_sparkframes[i], 1, 0);
	R_PolygonVertex(trace_endpos + v_right * fsize[0] - v_up * fsize[1],
		[1,1], [1,1,1], 1.0f);
	R_PolygonVertex(trace_endpos - v_right * fsize[0] - v_up * fsize[1],
		[0,1], [1,1,1], 1.0f);
	R_PolygonVertex(trace_endpos - v_right * fsize[0] + v_up * fsize[1],
		[0,0], [1,1,1], 1.0f);
	R_PolygonVertex(trace_endpos + v_right * fsize[0] + v_up * fsize[1],
		[1,0], [1,1,1], 1.0f);
	R_EndPolygon();
#endif
}

void w_egon_crosshair(player pl)
{
#ifdef CLIENT
	Cross_DrawSub(g_cross_spr, [24,24], [72/128,48/128], [0.1875, 0.1875]);

	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [0,96/128], [24/256, 24/128], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

float w_egon_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? ANIM_CR_AIMEGON : ANIM_AIMEGON;
}

void w_egon_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (pl.ammo_uranium == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	if (selected) {
		drawsubpic(pos, [170,45], g_hud5_spr, [0,135/256], [170/256,45/256], hud_col, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], g_hud2_spr, [0,135/256], [170/256,45/256], hud_col, a, DRAWFLAG_ADDITIVE);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_uranium, MAX_A_URANIUM, a);
#endif
}

int
w_egon_isempty(player pl)
{
	if (pl.ammo_uranium <= 0)
		return 1;

	return 0;
}

weapontype_t
w_egon_type(player pl)
{
	return WPNTYPE_FULLAUTO;
}

weapon_t w_egon =
{
	.name		= "egon",
	.id			= ITEM_EGON,
	.slot		= 3,
	.slot_pos	= 2,
	.weight		= 15,
	.draw		= w_egon_draw,
	.holster	= w_egon_holster,
	.primary	= w_egon_primary,
	.secondary	= w_egon_release,
	.reload		= w_egon_reload,
	.release	= w_egon_release,
	.postdraw	= w_egon_crosshair,
	.precache	= w_egon_precache,
	.pickup		= w_egon_pickup,
	.updateammo	= w_egon_updateammo,
	.wmodel		= w_egon_wmodel,
	.pmodel		= w_egon_pmodel,
	.deathmsg	= w_egon_deathmsg,
	.aimanim	= w_egon_aimanim,
	.hudpic		= w_egon_hudpic,
	.isempty	= w_egon_isempty,
	.type		= w_egon_type,
	.predraw	= w_egon_postdraw
};