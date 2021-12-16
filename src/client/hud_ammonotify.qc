
string g_ammo_spr;

typedef struct
{
	float alpha;
	int count;
} ammonote_t;
ammonote_t g_ammonotify[12];

vector g_ammotype[12] = {
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
};

void
HUD_AmmoNotify_Init(void)
{
	g_ammo_spr = spriteframe("sprites/640hud7.spr", 0, 0.0f);
}

void
HUD_AmmoNotify_Draw(vector startpos)
{
	vector pos = startpos;

	for (int i = 0; i < 12; i++) {
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
		pos -= [0, 32]; /* go up a notch */
	}
}

void
HUD_AmmoNotify_Insert(int type, int count)
{
	if (count <= 0)
		return;

	g_ammonotify[type].count += count;
	g_ammonotify[type].alpha = 2.5f;

}

/* called whenever we should check for pickup updates */
void
HUD_AmmoNotify_Check(player pl)
{
	HUD_AmmoNotify_Insert(0, pl.ammo_9mm - pl.ammo_9mm_net);
	HUD_AmmoNotify_Insert(1, pl.ammo_357 - pl.ammo_357_net);
	HUD_AmmoNotify_Insert(2, pl.ammo_m203_grenade - pl.ammo_m203_grenade_net);
	HUD_AmmoNotify_Insert(3, pl.ammo_buckshot - pl.ammo_buckshot_net);
	HUD_AmmoNotify_Insert(4, pl.ammo_bolt - pl.ammo_bolt_net);
	HUD_AmmoNotify_Insert(5, pl.ammo_rocket - pl.ammo_rocket_net);
	HUD_AmmoNotify_Insert(6, pl.ammo_uranium - pl.ammo_uranium_net);
	HUD_AmmoNotify_Insert(7, pl.ammo_hornet - pl.ammo_hornet_net);
	HUD_AmmoNotify_Insert(8, pl.ammo_handgrenade - pl.ammo_handgrenade_net);
	HUD_AmmoNotify_Insert(9, pl.ammo_satchel - pl.ammo_satchel_net);
	HUD_AmmoNotify_Insert(10, pl.ammo_snark - pl.ammo_snark_net);
	HUD_AmmoNotify_Insert(11, pl.ammo_tripmine - pl.ammo_tripmine_net);
}