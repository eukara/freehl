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

#ifdef CLIENT
void
FX_BreakModel_Init(void)
{
	precache_model("models/glassgibs.mdl");
	precache_model("models/woodgibs.mdl");
	precache_model("models/metalplategibs.mdl");
	precache_model("models/fleshgibs.mdl");
	precache_model("models/ceilinggibs.mdl");
	precache_model("models/computergibs.mdl");
	precache_model("models/rockgibs.mdl");
	precache_model("models/cindergibs.mdl");
	precache_sound("debris/bustglass1.wav");
	precache_sound("debris/bustglass2.wav");
	precache_sound("debris/bustglass3.wav");
	precache_sound("debris/bustcrate1.wav");
	precache_sound("debris/bustcrate2.wav");
	precache_sound("debris/bustcrate3.wav");
	precache_sound("debris/bustmetal1.wav");
	precache_sound("debris/bustmetal2.wav");
	precache_sound("debris/bustflesh1.wav");
	precache_sound("debris/bustflesh2.wav");
	precache_sound("debris/bustconcrete1.wav");
	precache_sound("debris/bustconcrete2.wav");
	precache_sound("debris/bustceiling.wav");
}
#endif

void
FX_BreakModel(int count, vector vMins, vector vMaxs, vector vVel, float fStyle)
{
#ifdef SERVER
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_MODELGIB);
	WriteCoord(MSG_MULTICAST, vMins[0]); 
	WriteCoord(MSG_MULTICAST, vMins[1]); 
	WriteCoord(MSG_MULTICAST, vMins[2]);
	WriteCoord(MSG_MULTICAST, vMaxs[0]); 
	WriteCoord(MSG_MULTICAST, vMaxs[1]); 
	WriteCoord(MSG_MULTICAST, vMaxs[2]);
	WriteByte(MSG_MULTICAST, fStyle);
	WriteByte(MSG_MULTICAST, count);

	msg_entity = self;
	
	vector vWorldPos;
	vWorldPos[0] = vMins[0] + (0.5 * (vMaxs[0] - vMins[0]));
	vWorldPos[1] = vMins[1] + (0.5 * (vMaxs[1] - vMins[1]));
	vWorldPos[2] = vMins[2] + (0.5 * (vMaxs[2] - vMins[2]));
	multicast(vWorldPos, MULTICAST_PVS);
#else
	static void FX_BreakModel_Remove(void) { remove(self) ; }

	float fModelCount = 0;
	vector vecPos;
	string sModel = "";

	switch (fStyle) {
		case GSMATERIAL_GLASS:
		case GSMATERIAL_GLASS_UNBREAKABLE:
			sModel = "models/glassgibs.mdl";
			fModelCount = 8;
			break;
		case GSMATERIAL_WOOD:
			sModel = "models/woodgibs.mdl";
			fModelCount = 3;
			break;
		case GSMATERIAL_METAL:
			sModel = "models/metalplategibs.mdl";
			fModelCount = 13;
			break;
		case GSMATERIAL_FLESH:
			sModel = "models/fleshgibs.mdl";
			fModelCount = 4;
			break;
		case GSMATERIAL_TILE:
			sModel = "models/ceilinggibs.mdl";
			fModelCount = 4;
			break;
		case GSMATERIAL_COMPUTER:
			sModel = "models/computergibs.mdl";
			fModelCount = 15;
			break;
		case GSMATERIAL_ROCK:
			sModel = "models/rockgibs.mdl";
			fModelCount = 3;
			break;
		default:
		case GSMATERIAL_CINDER:
			sModel = "models/cindergibs.mdl";
			fModelCount = 9;
			break;
	}

	vector vWorldPos;
	vWorldPos = vMins + (0.5 * (vMaxs - vMins));

	switch (fStyle) {
		case GSMATERIAL_GLASS:
			pointsound(vWorldPos, sprintf("debris/bustglass%d.wav", random(1, 4)), 1.0f, ATTN_NORM);
			break;
		case GSMATERIAL_WOOD:
			pointsound(vWorldPos, sprintf("debris/bustcrate%d.wav", random(1, 4)), 1.0f, ATTN_NORM);
			break;
		case GSMATERIAL_METAL:
		case GSMATERIAL_COMPUTER:
			pointsound(vWorldPos, sprintf("debris/bustmetal%d.wav", random(1, 3)), 1.0f, ATTN_NORM);
			break;
		case GSMATERIAL_FLESH:
			pointsound(vWorldPos, sprintf("debris/bustflesh%d.wav", random(1, 3)), 1.0f, ATTN_NORM);
			break;
		case GSMATERIAL_CINDER:
		case GSMATERIAL_ROCK:
			pointsound(vWorldPos, sprintf("debris/bustconcrete%d.wav", random(1, 4)), 1.0f, ATTN_NORM);
			break;
		case GSMATERIAL_TILE:
			pointsound(vWorldPos, "debris/bustceiling.wav", 1.0f, ATTN_NORM);
			break;
	}

	for (int i = 0; i < count; i++) {
		entity eGib = spawn();
		eGib.classname = "gib";

		vecPos[0] = vMins[0] + (random() * (vMaxs[0] - vMins[0]));
		vecPos[1] = vMins[1] + (random() * (vMaxs[1] - vMins[1]));
		vecPos[2] = vMins[2] + (random() * (vMaxs[2] - vMins[2]));

		setorigin(eGib, vecPos);
		setmodel(eGib, sModel);
		setcustomskin(eGib, "", sprintf("geomset 0 %f\n", random(1, fModelCount + 1)));
		eGib.movetype = MOVETYPE_BOUNCE;
		eGib.solid = SOLID_NOT;

		eGib.avelocity[0] = random()*600;
		eGib.avelocity[1] = random()*600;
		eGib.avelocity[2] = random()*600;
		eGib.think = FX_BreakModel_Remove;
		eGib.nextthink = time + 10;

		if ((fStyle == GSMATERIAL_GLASS) || (fStyle == GSMATERIAL_GLASS_UNBREAKABLE)) {
			eGib.alpha = 0.5f;
		}

		eGib.drawmask = MASK_ENGINE;
	}
#endif
} 
