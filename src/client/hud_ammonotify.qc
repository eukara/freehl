
#ifndef GEARBOX
#define AMMO_COUNT 12
#else
#define AMMO_COUNT 17
#endif

string g_ammo_spr;

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
#ifdef GEARBOX
	[24/256, 72/128], // 556 (same as 357)
	[24/256, 72/128], // 762 (same as 357)
	[200/256, 48/128], // spore
	[224/256, 48/128], //  shock
	[144/256, 72/128], // penguin
#endif
};

void
HUD_AmmoNotify_Init(void)
{
	g_ammo_spr = spriteframe("sprites/640hud7.spr", 0, 0.0f);
}

void
HUD_AmmoNotify_Draw(__inout vector pos)
{
	pos[0] = g_hudmins[0] + g_hudres[0] - 40;

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
		drawsubpic(pos,
			[24,24],
			g_ammo_spr,
			srcpos,
			[24/256, 24/128],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);

		drawfont = Font_GetID(FONT_20);
		string txt = sprintf("%i", g_ammonotify[i].count);
		float offs = stringwidth(txt, FALSE, [20,20]);
		drawstring(pos + [-offs - 8,4], sprintf("%i", g_ammonotify[i].count), [20,20], g_hud_color, a, DRAWFLAG_ADDITIVE);

		g_ammonotify[i].alpha -= (clframetime * 0.5);
	}
}

void
HUD_AmmoNotify_Insert(int type, int count)
{
	if (count <= 0)
		return;

	if (type == 7 && count < 8) // hornet hack!
		return;

	g_ammonotify[type].count += count;
	g_ammonotify[type].alpha = 2.5f;

}

/* called whenever we should check for pickup updates */
void
HUD_AmmoNotify_Check(NSClientPlayer pl)
{
	HUD_AmmoNotify_Insert(0, pl.m_iAmmoTypes[1] - pl.m_iAmmoTypes_net[1]);
	HUD_AmmoNotify_Insert(1, pl.m_iAmmoTypes[2] - pl.m_iAmmoTypes_net[2]);
	HUD_AmmoNotify_Insert(2, pl.m_iAmmoTypes[12] - pl.m_iAmmoTypes_net[12]);
	HUD_AmmoNotify_Insert(3, pl.m_iAmmoTypes[3] - pl.m_iAmmoTypes_net[3]);
	HUD_AmmoNotify_Insert(4, pl.m_iAmmoTypes[4] - pl.m_iAmmoTypes_net[4]);
	HUD_AmmoNotify_Insert(5, pl.m_iAmmoTypes[5] - pl.m_iAmmoTypes_net[5]);
	HUD_AmmoNotify_Insert(6, pl.m_iAmmoTypes[6] - pl.m_iAmmoTypes_net[6]);
	HUD_AmmoNotify_Insert(7, pl.m_iAmmoTypes[11] - pl.m_iAmmoTypes_net[11]);
	HUD_AmmoNotify_Insert(8, pl.m_iAmmoTypes[7] - pl.m_iAmmoTypes_net[7]);
	HUD_AmmoNotify_Insert(9, pl.m_iAmmoTypes[8] - pl.m_iAmmoTypes_net[8]);
	HUD_AmmoNotify_Insert(10, pl.m_iAmmoTypes[10] - pl.m_iAmmoTypes_net[10]);
	HUD_AmmoNotify_Insert(11, pl.m_iAmmoTypes[9] - pl.m_iAmmoTypes_net[9]);

#ifdef GEARBOX
	HUD_AmmoNotify_Insert(12, pl.m_iAmmoTypes[13] - pl.m_iAmmoTypes_net[13]);
	HUD_AmmoNotify_Insert(13, pl.m_iAmmoTypes[14] - pl.m_iAmmoTypes_net[14]);
	HUD_AmmoNotify_Insert(14, pl.m_iAmmoTypes[15] - pl.m_iAmmoTypes_net[15]);
	HUD_AmmoNotify_Insert(15, pl.m_iAmmoTypes[16] - pl.m_iAmmoTypes_net[16]);
	HUD_AmmoNotify_Insert(16, pl.m_iAmmoTypes[17] - pl.m_iAmmoTypes_net[17]);
#endif
}