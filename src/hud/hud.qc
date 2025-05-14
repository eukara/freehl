#pragma PROGS_DAT  "../../hud.dat"

#include "../../../src/client/api.h"

font_s FONT_BIG;
font_s FONT_WEAPONICON;
font_s FONT_WEAPONNUM;
font_s FONT_WEAPONNUMB;
font_s FONT_VERDANA;
font_s FONT_WEAPONTEXT;
font_s FONT_WEAPONICON_SEL;

var vector autocvar_hlhud_fgColor  = [1.0, 0.86, 0.0];
var float autocvar_hlhud_fgAlpha  = 0.39f;
var float autocvar_hlhud_altBucket  = 0.0;
var float autocvar_hlhud_bucketNumAlpha  = 0.5f;
var float autocvar_hlhud_hideTime  = 3.0f;

#define g_fg_color autocvar_hlhud_fgColor
#define g_fg_alpha autocvar_hlhud_fgAlpha

#include "WeaponSelect.h"
#include "WeaponSelect.qc"


noref var string g_ammoPic;
HLWeaponSelect weaponSelectionHUD;

var float g_oldHealth;
var float g_oldArmor;
var float g_oldClip;
var float g_oldAmmo1;
var float g_oldAmmo2;

var vector g_hudMins;
var vector g_hudRes;

var float g_healthAlpha;
var float g_armorAlpha;
var float g_clipAlpha;
var float g_ammo1Alpha;
var float g_ammo2Alpha;
var float g_ammoDisplayAlpha;
var float g_damageAlpha;
var vector g_damageLocation;
var int g_damageFlags;

var string g_damage_spr_t;
var string g_damage_spr_b;
var string g_damage_spr_l;
var string g_damage_spr_r;

var string g_dmg1_spr;
var string g_dmg2_spr;

var string g_hud1_spr;
var string g_hud2_spr;
var string g_hud3_spr;
var string g_hud4_spr;
var string g_hud5_spr;
var string g_hud6_spr;
var string g_hud7_spr;

var float autocvar_cg_damageFill = 0.25f;

#define AMMO_COUNT 17

typedef struct
{
	float alpha;
	int count;
} ammonote_t;
ammonote_t g_ammonotify[AMMO_COUNT];

vector g_ammotype[AMMO_COUNT] = {
	[0/256, 72/128], // pistol
	[24/256, 72/128], // revolver
	[48/256, 72/128], // grenade
	[72/256, 72/128], // shell
	[96/256, 72/128], //  arrow
	[120/256, 72/128], // rocket
	[0/256, 96/128], // uranium
	[24/256, 96/128], // hornet
	[48/256, 96/128], // grenade
	[72/256, 96/128], // satchel
	[96/256, 96/128], //  snark
	[120/256, 96/128], // tripmine
	[24/256, 72/128], // 556 (same as 357)
	[24/256, 72/128], // 762 (same as 357)
	[200/256, 48/128], // spore
	[224/256, 48/128], //  shock
	[144/256, 72/128], // penguin
};

void
HLHUD_AmmoNotify_Draw(__inout vector pos)
{
	pos[0] = g_hudMins[0] + g_hudRes[0] - 40;

	for (int i = 0; i < AMMO_COUNT; i++) {
		vector srcpos;
		float a;

		/* make sure we skip any faded entries, and also null them */
		if (g_ammonotify[i].alpha <= 0.0f) {
			g_ammonotify[i].count = 0;
			continue;
		}

		/* let's get the src img pos for our type */
		srcpos = g_ammotype[i];
		a = bound(0, g_ammonotify[i].alpha, 1.0);

		/* we'll use the alpha to control the offset so it gently glides down when fading out */
		pos -= [0, 32 * a]; /* go up a notch */
		draw.SubPic(pos,
			[24,24],
			g_hud7_spr,
			srcpos,
			[24/256, 24/128],
			g_fg_color,
			a,
			DRAWFLAG_ADDITIVE
		);

		drawfont = 0;
		string txt = sprintf("%i", g_ammonotify[i].count);
		float offs = stringwidth(txt, FALSE, [20,20]);
		draw.Text_RGBA(pos + [-offs - 8,4], sprintf("%i", g_ammonotify[i].count), g_fg_color, a, FONT_BIG);

		g_ammonotify[i].alpha -= (clframetime * 0.5);
	}
}

void
HLHUD_AmmoNotify_Insert(int type, int count)
{
	if (count <= 0)
		return;

	if (type == 7 && count < 8) // hornet hack!
		return;

	g_ammonotify[type].count += count;
	g_ammonotify[type].alpha = 2.5f;

}


/** All available damage types. */
typedef enum
{
	DMG_GENERIC = 1,		/**< Non specific. */
	DMG_CRUSH = 2,			/**< Being crushed by something heavy. */
	DMG_BULLET = 4,			/**< Shot by a gun. */
	DMG_SLASH = 8,			/**< Cutting, from swords or knives. */
	DMG_FREEZE = 16,			/**< Ice/freezing temperature damage. */
	DMG_BURN = 32,			/**< Short flame, or on-fire type damage. */
	DMG_VEHICLE = 64,		/**< Vehicle ramming into you at speed. */
	DMG_FALL = 128,			/**< Fall damage */
	DMG_EXPLODE = 256,		/**< Firery explosion damage. */
	DMG_BLUNT = 512,			/**< Blunt damage, like from a pipe or a bat. */
	DMG_ELECTRO = 1024,		/**< Electric shock damage. */
	DMG_SOUND = 2048,			/**< Noise so irritating it creates damage. */
	DMG_ENERGYBEAM = 4096,		/**< Energy beam damage. */
	DMG_GIB_NEVER = 8192,		/**< This damage type doesn't cause gibbing. */
	DMG_GIB_ALWAYS = 16384,		/**< This damage type will always gib. */
	DMG_DROWN = 32768,			/**< Drown damage, gets restored over time. */
	DMG_PARALYZE = 65536,		/**< Paralyzation damage. */
	DMG_NERVEGAS = 131072,		/**< Toxins to the nerve, special effect? */
	DMG_POISON = 262144,			/**< Poisonous damage. Similar to nervegas? */
	DMG_RADIATION = 524288,		/**< Radiation damage. Geiger counter go brrr */
	DMG_DROWNRECOVER = 1048576,	/**< Health increase from drown recovery. */
	DMG_CHEMICAL = 2097152,		/**< Chemical damage. */
	DMG_SLOWBURN = 4194304,		/**< Slow burning, just like burning but different rate. */
	DMG_SLOWFREEZE = 8388608,		/**< Slow freeze, just freezing but different rate. */
	DMG_SKIP_ARMOR = 16777216,		/**< This damage will skip armor checks entirely. */
	DMG_SKIP_RAGDOLL = 33554432	/**< This damage will not affect ragdolls. */
} damageType_t;

#define DMG_ACID DMG_CHEMICAL
#define DMG_COUNT 8

typedef struct
{
	float alpha;
} dmgnote_t;
static dmgnote_t g_dmgnotify[DMG_COUNT];

vector g_dmgtype[DMG_COUNT] = {
	[0,0], // chemical
	[0.25,0], // drown
	[0.5,0], // poison
	[0.75,0], // shock
	[0,0], // nerve gas
	[0.25,0], // freeze / slowfreeze
	[0.5,0], // burn / slowburn
	[0.75,0], // radiation?
};

void
HLHUD_DamageNotifyDraw(vector hudmins, vector res)
{
	vector pos;
	
	pos = hudmins + [16, res[1] - 128];

	for (int i = 0; i < DMG_COUNT; i++) {
		vector srcpos;
		float a;

		/* make sure we skip any faded entries, and also null them */
		if (g_dmgnotify[i].alpha <= 0.0f) {
			continue;
		}

		/* let's get the src img pos for our type */
		srcpos = g_dmgtype[i];

		a = (sin(cltime * 2.5) * 0.5) + 0.5;
		a *= bound(0.0f, g_dmgnotify[i].alpha, 1.0);

		if (i < 4)
		draw.SubPic(pos,
			[64,64],
			g_dmg1_spr,
			srcpos,
			[64/256, 64/64],
			g_fg_color,
			a,
			DRAWFLAG_ADDITIVE
		);
		else
		draw.SubPic(pos,
			[64,64],
			g_dmg2_spr,
			srcpos,
			[64/256, 64/64],
			g_fg_color,
			a,
			DRAWFLAG_ADDITIVE
		);

		g_dmgnotify[i].alpha -= (clframetime * 2.0);
		pos -= [0, 64]; /* go up a notch */
	}
}

typedef enum
{
	DMGNOT_CHEMICAL,
	DMGNOT_DROWN,
	DMGNOT_POISON,
	DMGNOT_SHOCK,
	DMGNOT_NERVEGAS,
	DMGNOT_FREEZE,
	DMGNOT_BURN,
	DMGNOT_RADIATION
} dmgnot_e;

#define DMG_NOTIFY_SET(x) g_dmgnotify[x].alpha = 10.0f


#define ITEM_COUNT 3

noref var string g_item_spr;

typedef struct
{
	float alpha;
	int count;
} itemnote_t;
itemnote_t g_itemnotify[ITEM_COUNT];

vector g_itemtype[ITEM_COUNT] = {
	[176/256, 0/256], // battery
	[176/256, 48/256], // medkit
	[176/256, 96/256], // longjump
};

void
HLHUD_ItemNotify_Draw(__inout vector pos)
{
	pos[0] = g_hudMins[0] + g_hudRes[0] - 44;

	for (int i = 0; i < ITEM_COUNT; i++) {
		vector srcpos;
		float a;

		/* make sure we skip any faded entries, and also null them */
		if (g_itemnotify[i].alpha <= 0.0f) {
			g_itemnotify[i].count = 0;
			continue;
		}

		/* let's get the src img pos for our type */
		srcpos = g_itemtype[i];
		a = bound(0, g_itemnotify[i].alpha, 1.0);

		/* we'll use the alpha to control the offset so it gently glides down when fading out */
		pos -= [0, 52 * a]; /* go up a notch */
		draw.SubPic(pos + [-20,0],
			[44,44],
			g_hud2_spr,
			srcpos,
			[44/256, 44/256],
			g_fg_color,
			a,
			DRAWFLAG_ADDITIVE
		);

		if (g_itemnotify[i].count > 1) {
		drawfont = 0;
		string txt = sprintf("%i", g_itemnotify[i].count);
		float offs = stringwidth(txt, FALSE, [20,20]) + 16;

		draw.Text_RGBA(pos + [-offs - 8,12], sprintf("%i", g_itemnotify[i].count), g_fg_color, a, FONT_BIG);
		}

		g_itemnotify[i].alpha -= (clframetime * 0.5);
	}
}

void
HLHUD_ItemNotify_Insert(int type, int count)
{
	if (count <= 0) {
		return;
	}

	g_itemnotify[type].count += count;
	g_itemnotify[type].alpha = 2.5f;

}

void
HUD_PickedUpItem(string itemClass)
{
	switch (itemClass) {
	case "item_battery":
		HLHUD_ItemNotify_Insert(0i, 1i);
		break;
	case "item_healthkit":
		HLHUD_ItemNotify_Insert(1i, 1i);
		break;
	case "item_longjump":
		HLHUD_ItemNotify_Insert(2i, 1i);
		break;
	}
}


void
HLHUD_UpdateTimers(float health, float armor, float clip, float ammo1, float ammo2)
{
	if (health != g_oldHealth) {
		g_healthAlpha = 1.0;
	}
	if (armor != g_oldArmor) {
		g_armorAlpha = 1.0;
	}
	if (clip != g_oldClip) {
		g_clipAlpha = 1.0;
	}
	if (ammo1 != g_oldAmmo1) {
		g_ammo1Alpha = 1.0;
	}
	if (ammo2 != g_oldAmmo2) {
		g_ammo2Alpha = 1.0;
	}

	g_oldHealth = health;
	g_oldArmor = armor;
	g_oldClip = clip;
	g_oldAmmo1 = ammo1;
	g_oldAmmo2 = ammo2;
}

void
HLHUD_ClampTimers()
{
	g_healthAlpha = bound(g_fg_alpha, g_healthAlpha - (clframetime * 0.5), 1.0);
	g_armorAlpha = bound(g_fg_alpha, g_armorAlpha - (clframetime * 0.5), 1.0);
	g_clipAlpha = bound(g_fg_alpha, g_clipAlpha - (clframetime * 0.5), 1.0);
	g_ammo1Alpha = bound(g_fg_alpha, g_ammo1Alpha - (clframetime * 0.5), 1.0);
	g_ammo2Alpha = bound(g_fg_alpha, g_ammo2Alpha - (clframetime * 0.5), 1.0);
	g_ammoDisplayAlpha = bound(0.0, g_ammoDisplayAlpha - (clframetime * 5), 1.0);
	g_damageAlpha = bound(0.0, g_damageAlpha - (clframetime * 1), 1.0);
}

void
HLHUD_BigNums(vector pos, string numString, float alpha)
{
	if (alpha > g_fg_alpha) {
		float backAlpha = bound(0.0f, alpha - g_fg_alpha, 1.0f);
		draw.Text_RGBA(pos + [random(-2,2), 0], numString, g_fg_color, backAlpha, FONT_WEAPONNUMB);
		draw.Text_RGBA(pos, numString, g_fg_color, alpha, FONT_BIG);
	} else
		draw.Text_RGBA(pos, numString, g_fg_color, alpha, FONT_BIG);
}


void
HUD_Init(void)
{
	weaponSelectionHUD = spawn(HLWeaponSelect);
}

void
HUD_ReloadVideoResources(void)
{
#if 0
	font.Load("fonts/chat.font", FONT_SMALL);
	font.Load("fonts/font20.font", FONT_BIG);
	font.Load("fonts/weaponicon.font", FONT_WEAPONICON);
	font.Load("fonts/weaponicon_sel.font", FONT_WEAPONICON_SEL);
	font.Load("fonts/weapontext.font", FONT_WEAPONTEXT);
	font.Load("fonts/weaponnumbers.font", FONT_WEAPONNUM);
	font.Load("fonts/weaponnumbers_blurry.font", FONT_WEAPONNUMB);
#endif

	g_hud1_spr = spriteframe("sprites/640hud1.spr", 0, 0.0f);
	g_hud2_spr = spriteframe("sprites/640hud2.spr", 0, 0.0f);
	g_hud3_spr = spriteframe("sprites/640hud3.spr", 0, 0.0f);
	g_hud4_spr = spriteframe("sprites/640hud4.spr", 0, 0.0f);
	g_hud5_spr = spriteframe("sprites/640hud5.spr", 0, 0.0f);
	g_hud6_spr = spriteframe("sprites/640hud6.spr", 0, 0.0f);
	g_hud7_spr = spriteframe("sprites/640hud7.spr", 0, 0.0f);

	g_damage_spr_t = spriteframe("sprites/640_pain.spr", 0, 0.0f);
	g_damage_spr_r = spriteframe("sprites/640_pain.spr", 1, 0.0f);
	g_damage_spr_b = spriteframe("sprites/640_pain.spr", 2, 0.0f);
	g_damage_spr_l = spriteframe("sprites/640_pain.spr", 3, 0.0f);

	g_dmg1_spr = spriteframe("sprites/640hud8.spr", 0, 0.0f);
	g_dmg2_spr = spriteframe("sprites/640hud9.spr", 0, 0.0f);
}

/* Use first frame for drawing (needs precache) */
#define NUMSIZE_X 24/256
#define NUMSIZE_Y 24/128
#define HUD_ALPHA 0.5

float spr_hudnum[10] = {
	0 / 256,
	24 / 256,
	(24*2) / 256,
	(24*3) / 256,
	(24*4) / 256,
	(24*5) / 256,
	(24*6) / 256,
	(24*7) / 256,
	(24*8) / 256,
	(24*9) / 256
};

/* pre-calculated sprite definitions */
float spr_health[4] = {
	80 / 256, // pos x
	24 / 128, // pos u
	32 / 256, // size x
	32 / 128 // size y
};

float spr_suit1[4] = {
	0 / 256, // pos x
	24 / 128, // pos u
	40 / 256, // size x
	40 / 128 // size y
};

float spr_suit2[4] = {
	40 / 256, // pos x
	24 / 128, // pos u
	40 / 256, // size x
	40 / 128 // size y
};

float spr_flash1[4] = {
	160 / 256, // pos x
	24 / 128, // pos u
	32 / 256, // size x
	32 / 128 // size y
};

float spr_flash2[4] = {
	112 / 256, // pos x
	24 / 128, // pos u
	48 / 256, // size x
	32 / 128 // size y
};

void
HLHUD_DrawNumber(int iNumber, vector vecPos, float fAlpha, vector vColor)
{
	draw.SubPic(vecPos,
		[24,24],
		g_hud7_spr,
		[spr_hudnum[iNumber], 0],
		[NUMSIZE_X, NUMSIZE_Y],
		vColor,
		fAlpha,
		DRAWFLAG_ADDITIVE
	);
}

void
HLHUD_DrawNums(float fNumber, vector vecPos, float fAlpha, vector vColor)
{
	int iNumber = fNumber;
	if (iNumber > 0) {
		while (iNumber > 0) {
			HLHUD_DrawNumber((float)iNumber % 10, vecPos, fAlpha, vColor);
			iNumber = iNumber / 10;
			vecPos[0] -= 20;
		} 
	} else {
		HLHUD_DrawNumber(0, vecPos, fAlpha, vColor);
	}
}

void
HLHUD_DrawHealth(vector pos, float healthValue)
{
	if (healthValue > 25) {
		draw.SubPic(
			pos + [-72,-4],
			[32,32],
			g_hud7_spr,
			[spr_health[0], spr_health[1]],
			[spr_health[2], spr_health[3]],
			g_fg_color,
			g_healthAlpha,
			DRAWFLAG_ADDITIVE
		);
		HLHUD_DrawNums(healthValue, pos, g_healthAlpha, g_fg_color);
	} else {
		draw.SubPic(
			pos + [-72,-4],
			[32,32],
			g_hud7_spr,
			[spr_health[0], spr_health[1]],
			[spr_health[2], spr_health[3]],
			[1,0,0],
			g_healthAlpha,
			DRAWFLAG_ADDITIVE
		);
		HLHUD_DrawNums(healthValue, pos, g_healthAlpha, [1,0,0]);
	}
}

void
HLHUD_DrawArmor(vector pos, float armorValue)
{
	draw.SubPic(
		pos + [-80,-9],
		[40,40],
		g_hud7_spr,
		[spr_suit2[0], spr_suit2[1]],
		[spr_suit2[2], spr_suit2[3]],
		g_fg_color,
		g_armorAlpha,
		DRAWFLAG_ADDITIVE
	);

	if (armorValue > 0) {
		float perc = bound(0, (armorValue / 100), 1.0);
		draw.SubPic(
			pos + [-80,-9] + [0, 40 * (1.0-perc)],
			[40, 40 * perc],
			g_hud7_spr,
			[spr_suit1[0],spr_suit1[1] + spr_suit1[3] * (1.0-perc)],
			[spr_suit1[2], spr_suit1[3] * perc],
			g_fg_color,
			g_armorAlpha,
			DRAWFLAG_ADDITIVE
		);
	}

	HLHUD_DrawNums(armorValue, pos, g_armorAlpha, g_fg_color);
}

void
HUD_DrawSeperator(vector pos)
{
	draw.SubPic(pos,
		[2,24],
		g_hud7_spr,
		[240/256, 0],
		[2/256, 24/128],
		g_fg_color,
		HUD_ALPHA,
		DRAWFLAG_ADDITIVE
	);
}

void
HLHUD_DrawAmmo1(vector pos, float ammoValue)
{
	HLHUD_DrawNums(ammoValue, pos, g_clipAlpha, g_fg_color);
	HUD_DrawSeperator(pos + [30,0]);
}

void
HLHUD_DrawAmmo2(vector pos, float ammoValue)
{
	HLHUD_DrawNums(ammoValue, pos, g_ammo1Alpha, g_fg_color);
}

void
HLHUD_DrawAmmo3(vector pos, float ammoValue)
{
	HLHUD_DrawNums(ammoValue, pos, g_ammo2Alpha, g_fg_color);
}

void
HUD_Draw(void)
{
	vector pos;
	vector hud_mins, hud_size;
	float armorValue  = player.GetArmor();
	float healthValue = player.GetHealth();
	int teamID = player.GetTeam();
	float clipValue = weapon.GetClip();
	float ammoValue = weapon.GetAmmo1();
	float ammoValue2 = weapon.GetAmmo2();
	float staminaValue = 1.0 - player.GetStamina();

	g_hudMins = hud_mins = screen.HUDMins();
	g_hudRes = hud_size = screen.HUDSize();

	HLHUD_UpdateTimers(healthValue, armorValue, clipValue, ammoValue, ammoValue2);

	HLHUD_DamageNotifyDraw(hud_mins, hud_size);



	if (1) {
		pos = g_hudMins + [g_hudRes[0] - 192, g_hudRes[1] - 128];
		pos[1] += 48;
		HLHUD_ItemNotify_Draw(pos);
		HLHUD_AmmoNotify_Draw(pos);
	}


	if (g_damageAlpha > 0.0f) {
		vector center;
		vector rel_pos;
		float fw, fw_alpha;
		float rt, rt_alpha;

		center = hud_mins + (hud_size / 2);

		/* the pos relative to the player + view_dir determines which
		 * and how bright each indicator is drawn. so first get the relative
		 * position between us and the attacker, then calculate the strength
		 * of each direction based on a dotproduct tested against our
		 * camera direction.
		 */
		vector playerPosition = player.GetCameraPosition();
		vector playerAngle = player.GetCameraAngles();
		playerPosition[2] = g_damageLocation[2];
		rel_pos = vectorNormalize(g_damageLocation - playerPosition);
		fw = vectorDot(rel_pos, anglesToForward(playerAngle));
		rt = vectorDot(rel_pos, anglesToRight(playerAngle));

		fw_alpha = fabs(fw) * g_damageAlpha;
		if (fw > 0.25f) {
			draw.Pic(center + [-64,-102], g_damage_spr_t, 
				[128,48], [1,1,1], fw_alpha, DRAWFLAG_ADDITIVE);
		} else if (fw < -0.25f) {
			draw.Pic(center + [-64,70], g_damage_spr_b,
				[128,48], [1,1,1], fw_alpha, DRAWFLAG_ADDITIVE);
		}

		rt_alpha = fabs(rt) * g_damageAlpha;
		if (rt > 0.25f) {
			draw.Pic(center + [70,-64], g_damage_spr_r,
				[48,128], [1,1,1], rt_alpha, DRAWFLAG_ADDITIVE);
		} else if (rt < -0.25f) {
			draw.Pic(center + [-102,-64], g_damage_spr_l,
				[48,128], [1,1,1], rt_alpha, DRAWFLAG_ADDITIVE);
		}

		if (autocvar_cg_damageFill > 0.0) {
			vector screenSize = screen.Size();
			vector finalColor = [1,1,1];
			finalColor[1] = finalColor[2] = 1.0 - (g_damageAlpha * autocvar_cg_damageFill);
			draw.Pic(hud_mins, "fade_modulate", screenSize, finalColor, 1.0, DRAWFLAG_NORMAL);
		}

		g_damageAlpha -= clframetime;
	}

	/* sprinting overlay  */
	if (staminaValue < 1.0f) {
		pos = hud_mins + [16, hud_size[1] - 90];

		if (player.IsSprinting()) {
			pos = hud_mins + [16, hud_size[1] - 90];
			draw.RoundedBox(pos, [102, 36], [0,0,0], 76/255);
			draw.Text_RGBA(pos + [8, 24], "SPRINT", g_fg_color, 1.0f, FONT_VERDANA);
		} else {
			pos = hud_mins + [16, hud_size[1] - 80];
			draw.RoundedBox(pos, [102, 26], [0,0,0], 76/255);
		}

		draw.Text_RGBA(pos + [8, 5], "AUX POWER", g_fg_color, 1.0f, FONT_VERDANA);


		for (float f = 0.0f; f <= 1.0f; f += 0.1f) {
			if (f < staminaValue)
				draw.Rect(pos + [8,15], [6, 4], g_fg_color, 1.0f);
			else
				draw.Rect(pos + [8,15], [6, 4], g_fg_color, g_fg_alpha);

			pos[0] += 9;
		}

	} else {
		if (teams.TeamCount() > 0i) {
			pos = hud_mins + [16, hud_size[1] - 65];
			draw.RoundedBox(pos, [66, 16], [0,0,0], 76/255);
			draw.Text_RGBA(pos + [8, 5], strcat("Team ", teams.Name(teamID)), teams.Color(teamID), 1.0f, FONT_VERDANA);
		}
	}

	pos = hud_mins + [88, hud_size[1] - 42];
	HLHUD_DrawHealth(pos, healthValue); 
	pos = hud_mins + [198, hud_size[1] - 42];
	HLHUD_DrawArmor(pos, armorValue);

	weaponSelectionHUD.Draw();

	if (weapon.AmmoRequired() == false) {
		HLHUD_ClampTimers();
		return;
	}

	/* ammo displays */

	/* ammo 2 */
	if (weapon.UsesSecondaryAmmo() == true) {
		pos = hud_mins + [hud_size[0] - 72, hud_size[1] - 74];
		HLHUD_DrawAmmo3(pos, ammoValue2);
	} else {
		pos = hud_mins + [hud_size[0] - 102 - 16, hud_size[1] - 48];
	}

	if (weapon.GetClipSize() > 0) {
		pos = hud_mins + [hud_size[0] - 152, hud_size[1] - 42];
		HLHUD_DrawAmmo1(pos, clipValue);
	}

	pos = hud_mins + [hud_size[0] - 72, hud_size[1] - 42];
	HLHUD_DrawAmmo2(pos, ammoValue);

	HLHUD_ClampTimers();
}

void
HUD_DrawSpectator(vector hud_mins, vector hud_size)
{

}

void
HUD_WeaponSwitched(string weaponName)
{
	//g_ammoPic = entityDef.GetKeyValue(weaponName, "ammoIcon");
	g_ammoDisplayAlpha = 1.0f;
}

float
HUD_InputFrame(float inputButtons)
{
	if (weaponSelectionHUD.Active()) {
		if (inputButtons & INPUT_PRIMARY) {
			weaponSelectionHUD.Trigger();
		} else if (inputButtons & INPUT_SECONDARY) {
			weaponSelectionHUD.Deactivate();
		}

		return (0.2f);
	}

	return (0.0f);
}

bool
HUD_ConsoleCommand(string commandString)
{
	tokenize_console(commandString);

	switch (argv(0)) {
	case "invnext":
		weaponSelectionHUD.SelectNext(false);
		break;
	case "invprev":
		weaponSelectionHUD.SelectPrevious(false);
		break;
	default:
		return (false);
	}

	return (true);
}

	
void
HUD_DamageReceived(vector damageLocation, int damagePoints, int damageFlags)
{
	if (damagePoints <= 0i) {
		return;
	}

	g_damageAlpha = 1.0;
	g_damageLocation = damageLocation;
	g_damageFlags = damageFlags;

	if (g_damageFlags & DMG_CHEMICAL) {
		g_damageFlags &= ~DMG_CHEMICAL;
		DMG_NOTIFY_SET(DMGNOT_CHEMICAL);
	}
	if (g_damageFlags & DMG_BURN) {
		g_damageFlags &= ~DMG_BURN;
		DMG_NOTIFY_SET(DMGNOT_BURN);
	}
	if (g_damageFlags & DMG_SLOWBURN) {
		g_damageFlags &= ~DMG_SLOWBURN;
		DMG_NOTIFY_SET(DMGNOT_BURN);
	}
	if (g_damageFlags & DMG_ELECTRO) {
		g_damageFlags &= ~DMG_ELECTRO;
		DMG_NOTIFY_SET(DMGNOT_SHOCK);
	}
	if (g_damageFlags & DMG_DROWN) {
		g_damageFlags &= ~DMG_DROWN;
		DMG_NOTIFY_SET(DMGNOT_DROWN);
	}
	if (g_damageFlags & DMG_NERVEGAS) {
		g_damageFlags &= ~DMG_NERVEGAS;
		DMG_NOTIFY_SET(DMGNOT_NERVEGAS);
	}
	if (g_damageFlags & DMG_POISON) {
		g_damageFlags &= ~DMG_POISON;
		DMG_NOTIFY_SET(DMGNOT_POISON);
	}
	if (g_damageFlags & DMG_RADIATION) {
		g_damageFlags &= ~DMG_RADIATION;
		DMG_NOTIFY_SET(DMGNOT_RADIATION);
	}
	if (g_damageFlags & DMG_FREEZE) {
		g_damageFlags &= ~DMG_FREEZE;
		DMG_NOTIFY_SET(DMGNOT_FREEZE);
	}
	if (g_damageFlags & DMG_SLOWFREEZE) {
		g_damageFlags &= ~DMG_SLOWFREEZE;
		DMG_NOTIFY_SET(DMGNOT_FREEZE);
	}
}


vector g_ammotype[AMMO_COUNT] = {
	[0/256, 72/128], // pistol
	[24/256, 72/128], // revolver
	[48/256, 72/128], // grenade
	[72/256, 72/128], // shell
	[96/256, 72/128], //  arrow
	[120/256, 72/128], // rocket
	[0/256, 96/128], // uranium
	[24/256, 96/128], // hornet
	[48/256, 96/128], // grenade
	[72/256, 96/128], // satchel
	[96/256, 96/128], //  snark
	[120/256, 96/128], // tripmine
	[24/256, 72/128], // 556 (same as 357)
	[24/256, 72/128], // 762 (same as 357)
	[200/256, 48/128], // spore
	[224/256, 48/128], //  shock
	[144/256, 72/128], // penguin
};

void
HUD_AmmoChanged(int ammoType, int absoluteValue, int deltaValue)
{
	string ammoTypeName = ammo.NameForNum(ammoType);

	/* if you wonder why this isn't cleaner, this was ported from
	   the old HUD code. this can be changed to be decl specific at some point! */
	switch (ammoTypeName) {
	case "ammo_9mm":
		HLHUD_AmmoNotify_Insert(0, deltaValue);
		break;
	case "ammo_357":
		HLHUD_AmmoNotify_Insert(1, deltaValue);
		break;
	case "ammo_m203_grenade":
		HLHUD_AmmoNotify_Insert(2, deltaValue);
		break;
	case "ammo_buckshot":
		HLHUD_AmmoNotify_Insert(3, deltaValue);
		break;
	case "ammo_bolt":
		HLHUD_AmmoNotify_Insert(4, deltaValue);
		break;
	case "ammo_rocket":
		HLHUD_AmmoNotify_Insert(5, deltaValue);
		break;
	case "ammo_uranium":
		HLHUD_AmmoNotify_Insert(6, deltaValue);
		break;
	case "ammo_hornet":
		HLHUD_AmmoNotify_Insert(7, deltaValue);
		break;
	case "ammo_handgrenade":
		HLHUD_AmmoNotify_Insert(8, deltaValue);
		break;
	case "ammo_satchel":
		HLHUD_AmmoNotify_Insert(9, deltaValue);
		break;
	case "ammo_snark":
		HLHUD_AmmoNotify_Insert(10, deltaValue);
		break;
	case "ammo_tripmine":
		HLHUD_AmmoNotify_Insert(11, deltaValue);
		break;
	case "ammo_556":
		HLHUD_AmmoNotify_Insert(12, deltaValue);
		break;
	case "ammo_762":
		HLHUD_AmmoNotify_Insert(13, deltaValue);
		break;
	case "ammo_spore":
		HLHUD_AmmoNotify_Insert(14, deltaValue);
		break;
	case "ammo_shock":
		HLHUD_AmmoNotify_Insert(15, deltaValue);
		break;
	case "ammo_penguin":
		HLHUD_AmmoNotify_Insert(16, deltaValue);
		break;
	}
}
