font_s FONT_BIG;
font_s FONT_WEAPONICON;
font_s FONT_WEAPONNUM;
font_s FONT_WEAPONNUMB;
font_s FONT_VERDANA;
font_s FONT_WEAPONTEXT;
font_s FONT_WEAPONICON_SEL;

var vector autocvar_hlhud_fgColor  = [1, 170/255, 0];
var float autocvar_hlhud_fgAlpha  = 0.39f;
var float autocvar_hlhud_altBucket  = 0.0;
var float autocvar_hlhud_bucketNumAlpha  = 0.5f;
var float autocvar_hlhud_hideTime  = 3.0f;

#define g_fg_color autocvar_hlhud_fgColor
#define g_fg_alpha autocvar_hlhud_fgAlpha

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
var dmgnote_t g_dmgnotify[DMG_COUNT];

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

