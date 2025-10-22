font_s FONT_20;
font_s FONT_CHAT;

var vector autocvar_hlhud_fgColor  = [1, 160/255, 0];

var vector autocvar_hlhud_healthColor1  = [1, 160/255, 0];
var vector autocvar_hlhud_healthColor2  = [1, 160/255, 0];
var vector autocvar_hlhud_armorColor1  = [1, 160/255, 0];
var vector autocvar_hlhud_armorColor2  = [1, 160/255, 0];
var vector autocvar_hlhud_lowHealthColor1  = [1, 0, 0];
var vector autocvar_hlhud_lowHealthColor2  = [1, 0, 0];
var vector autocvar_hlhud_lowArmorColor1  = [1, 0, 0];
var vector autocvar_hlhud_lowArmorColor2  = [1, 0, 0];

var float autocvar_hlhud_fgAlpha  = 100/255;
var float autocvar_hlhud_fgAlphaScale  = 1.0;
var float autocvar_hlhud_altBucket  = 0.0;
var float autocvar_hlhud_bucketNumAlpha  = 0.5f;
var float autocvar_hlhud_hideTime  = 3.0f;
var bool autocvar_hlhud_leadingZeroes = false;
var bool autocvar_hlhud_leadingZeroesAlpha = 0.15f;
var bool autocvar_hlhud_leadingZeroesLimit = true;

#define g_fg_color autocvar_hlhud_fgColor
#define g_fg_alpha autocvar_hlhud_fgAlpha
#define g_fg_alphaScale autocvar_hlhud_fgAlphaScale

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

#define HLHUD_SPRITES 61i
int g_spriteSheets[HLHUD_SPRITES];
int g_spriteAmmoIcon;
int g_spriteAmmo2Icon;
int g_spriteCrosshair;

typedef enum
{
S_AUTOAIM_C,
S_BUCKET0,
S_BUCKET1,
S_BUCKET2,
S_BUCKET3,
S_BUCKET4,
S_BUCKET5,
S_CROSS,
S_D_357,
S_D_9MMAR,
S_D_9MMHANDGUN,
S_D_BOLT,
S_D_CROSSBOW,
S_D_CROWBAR,
S_D_EGON,
S_D_GAUSS,
S_D_GRENADE,
S_D_HORNET,
S_D_RPG_ROCKET,
S_D_SATCHEL,
S_D_SHOTGUN,
S_D_SKULL,
S_D_SNARK,
S_D_TRACKTRAIN,
S_D_TRIPMINE,
S_DIVIDER,
S_DMG_BIO,
S_DMG_CHEM,
S_DMG_COLD,
S_DMG_DROWN,
S_DMG_GAS,
S_DMG_HEAT,
S_DMG_POISON,
S_DMG_RAD,
S_DMG_SHOCK,
S_FLASH_BEAM,
S_FLASH_EMPTY,
S_FLASH_FULL,
S_ITEM_BATTERY,
S_ITEM_HEALTHKIT,
S_ITEM_LONGJUMP,
S_NUMBER_0,
S_NUMBER_1,
S_NUMBER_2,
S_NUMBER_3,
S_NUMBER_4,
S_NUMBER_5,
S_NUMBER_6,
S_NUMBER_7,
S_NUMBER_8,
S_NUMBER_9,
S_SELECTION,
S_SUIT_EMPTY,
S_SUIT_FULL,
S_TITLE_HALF,
S_TITLE_LIFE,
S_TRAIN_BACK,
S_TRAIN_FORWARD1,
S_TRAIN_FORWARD2,
S_TRAIN_FORWARD3,
S_TRAIN_STOP
} hlSprites_t;

const string g_hlSpriteNames[HLHUD_SPRITES] =
{
"autoaim_c",
"bucket0",
"bucket1",
"bucket2",
"bucket3",
"bucket4",
"bucket5",
"cross",
"d_357",
"d_9mmAR",
"d_9mmhandgun",
"d_bolt",
"d_crossbow",
"d_crowbar",
"d_egon",
"d_gauss",
"d_grenade",
"d_hornet",
"d_rpg_rocket",
"d_satchel",
"d_shotgun",
"d_skull",
"d_snark",
"d_tracktrain",
"d_tripmine",
"divider",
"dmg_bio",
"dmg_chem",
"dmg_cold",
"dmg_drown",
"dmg_gas",
"dmg_heat",
"dmg_poison",
"dmg_rad",
"dmg_shock",
"flash_beam",
"flash_empty",
"flash_full",
"item_battery",
"item_healthkit",
"item_longjump",
"number_0",
"number_1",
"number_2",
"number_3",
"number_4",
"number_5",
"number_6",
"number_7",
"number_8",
"number_9",
"selection",
"suit_empty",
"suit_full",
"title_half",
"title_life",
"train_back",
"train_forward1",
"train_forward2",
"train_forward3",
"train_stop"
};



#define KILLMESSAGE_LIMIT 5i
#define KILLMESSAGE_TIME 4.0f

int g_killMsgCount;
float g_killMsgTime;

typedef struct
{
	string m_target;
	string m_attacker;
	int m_icon;
} killmsg_t;

var killmsg_t g_killMsgRecord[KILLMESSAGE_LIMIT];
