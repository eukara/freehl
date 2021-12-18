
#define DMG_COUNT 8

string g_dmg1_spr;
string g_dmg2_spr;

typedef struct
{
	float alpha;
} dmgnote_t;
dmgnote_t g_dmgnotify[DMG_COUNT];

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
HUD_DamageNotify_Init(void)
{
	g_dmg1_spr = spriteframe("sprites/640hud8.spr", 0, 0.0f);
	g_dmg2_spr = spriteframe("sprites/640hud9.spr", 0, 0.0f);
}

void
HUD_DamageNotify_Draw(void)
{
	vector pos;
	
	pos = g_hudmins + [16, g_hudres[1] - 128];

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
		drawsubpic(pos,
			[64,64],
			g_dmg1_spr,
			srcpos,
			[64/256, 64/64],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
		else
		drawsubpic(pos,
			[64,64],
			g_dmg2_spr,
			srcpos,
			[64/256, 64/64],
			g_hud_color,
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

/* called whenever we should check for pickup updates */
void
HUD_DamageNotify_Check(void)
{
	if (pSeat->m_iDamageFlags & DMG_CHEMICAL) {
		pSeat->m_iDamageFlags &= ~DMG_CHEMICAL;
		DMG_NOTIFY_SET(DMGNOT_CHEMICAL);
	}
	if (pSeat->m_iDamageFlags & DMG_BURN) {
		pSeat->m_iDamageFlags &= ~DMG_BURN;
		DMG_NOTIFY_SET(DMGNOT_BURN);
	}
	if (pSeat->m_iDamageFlags & DMG_SLOWBURN) {
		pSeat->m_iDamageFlags &= ~DMG_SLOWBURN;
		DMG_NOTIFY_SET(DMGNOT_BURN);
	}
	if (pSeat->m_iDamageFlags & DMG_ELECTRO) {
		pSeat->m_iDamageFlags &= ~DMG_ELECTRO;
		DMG_NOTIFY_SET(DMGNOT_SHOCK);
	}
	if (pSeat->m_iDamageFlags & DMG_DROWN) {
		pSeat->m_iDamageFlags &= ~DMG_DROWN;
		DMG_NOTIFY_SET(DMGNOT_DROWN);
	}
	if (pSeat->m_iDamageFlags & DMG_NERVEGAS) {
		pSeat->m_iDamageFlags &= ~DMG_NERVEGAS;
		DMG_NOTIFY_SET(DMGNOT_NERVEGAS);
	}
	if (pSeat->m_iDamageFlags & DMG_POISON) {
		pSeat->m_iDamageFlags &= ~DMG_POISON;
		DMG_NOTIFY_SET(DMGNOT_POISON);
	}
	if (pSeat->m_iDamageFlags & DMG_RADIATION) {
		pSeat->m_iDamageFlags &= ~DMG_RADIATION;
		DMG_NOTIFY_SET(DMGNOT_RADIATION);
	}
	if (pSeat->m_iDamageFlags & DMG_FREEZE) {
		pSeat->m_iDamageFlags &= ~DMG_FREEZE;
		DMG_NOTIFY_SET(DMGNOT_FREEZE);
	}
	if (pSeat->m_iDamageFlags & DMG_SLOWFREEZE) {
		pSeat->m_iDamageFlags &= ~DMG_SLOWFREEZE;
		DMG_NOTIFY_SET(DMGNOT_FREEZE);
	}
}