
#define ITEM_COUNT 3

string g_item_spr;

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
HUD_ItemNotify_Init(void)
{
	g_item_spr = spriteframe("sprites/640hud2.spr", 0, 0.0f);
}

void
HUD_ItemNotify_Draw(__inout vector pos)
{
	pos[0] = g_hudmins[0] + g_hudres[0] - 44;
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
		drawsubpic(pos + [-20,0],
			[44,44],
			g_item_spr,
			srcpos,
			[44/256, 44/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);

		if (g_itemnotify[i].count > 1) {
		drawfont = Font_GetID(FONT_20);
		string txt = sprintf("%i", g_itemnotify[i].count);
		float offs = stringwidth(txt, FALSE, [20,20]) + 16;
		drawstring(pos + [-offs - 8,12], sprintf("%i", g_itemnotify[i].count), [20,20], g_hud_color, a, DRAWFLAG_ADDITIVE);
		}

		g_itemnotify[i].alpha -= (clframetime * 0.5);
	}
}

void
HUD_ItemNotify_Insert(int type, int count)
{
	if (count <= 0)
		return;

	g_itemnotify[type].count += count;
	g_itemnotify[type].alpha = 2.5f;

}

/* called whenever we should check for pickup updates */
void
HUD_ItemNotify_Check(player pl)
{
	int healthdiff = bound(0, pl.health - pSeatLocal->m_iHealthOld, 100);
	int armordiff = bound(0, pl.armor - pSeatLocal->m_iArmorOld, 100);
	int longjumpdiff = ((pl.g_items & ITEM_LONGJUMP) > (pSeatLocal->m_iItemsOld & ITEM_LONGJUMP)) == TRUE;

	if (healthdiff > 1)
		HUD_ItemNotify_Insert(1, 1);
	if (armordiff > 1)
		HUD_ItemNotify_Insert(0, 1);
	if (longjumpdiff)
		HUD_ItemNotify_Insert(2, 1);

	pSeatLocal->m_iItemsOld = pl.g_items;
}