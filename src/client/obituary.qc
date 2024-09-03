/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

void
Obituary_Init(void)
{
}

void
Obituary_Precache(void)
{
}


void
Obituary_Add(string attacker, string victim, string weapon, float flags)
{
	int i;
	int x, y;
	x = OBITUARY_LINES;
	string weaponIcon = "";

	if (attacker == "worldspawn" || attacker == victim) {
		attacker = "";
	}

	weaponIcon = EntityDef_GetKeyValue(weapon, "killIcon");

	if (weaponIcon == "") {
		weaponIcon = "d_skull";
	}

	/* we're not full yet, so fill up the buffer */
	if (g_obituary_count < x) {
		y = g_obituary_count;
		g_obituary[y].attacker = attacker;
		g_obituary[y].victim = victim;
		g_obituary[y].icon = weaponIcon;
		g_obituary_count++;
	} else {
		for (i = 0; i < (x-1); i++) {
			g_obituary[i].attacker = g_obituary[i+1].attacker;
			g_obituary[i].victim = g_obituary[i+1].victim;
			g_obituary[i].icon = g_obituary[i+1].icon;
		}
		/* after rearranging, add the newest to the bottom. */
		g_obituary[x-1].attacker = attacker;
		g_obituary[x-1].victim = victim;
		g_obituary[x-1].icon = weaponIcon;
	}

	g_obituary_time = OBITUARY_TIME;

#if 0
	if (g_weapons[weapon].deathmsg) {
		string conprint = g_weapons[weapon].deathmsg();

		if (conprint != "") {
			print(sprintf(conprint, attacker, victim));
			print("\n");
		}
	}
#endif
}

void
Obituary_Draw(void)
{
	int i;
	vector pos;
	vector item;
	drawfont = Font_GetID(FONT_CON);
	pos = g_hudmins + [g_hudres[0] - 18, 56];

	if (g_obituary_time <= 0 && g_obituary_count > 0) {
		for (i = 0; i < (OBITUARY_LINES-1); i++) {
			g_obituary[i].attacker = g_obituary[i+1].attacker;
			g_obituary[i].victim = g_obituary[i+1].victim;
			g_obituary[i].icon = g_obituary[i+1].icon;
		}
		g_obituary[OBITUARY_LINES-1].attacker = "";
		g_obituary[OBITUARY_LINES-1].victim = "";
		g_obituary[OBITUARY_LINES-1].icon = 0;

		g_obituary_time = OBITUARY_TIME;
		g_obituary_count--;
	}

	if (g_obituary_count <= 0) { 
		return;
	}

	item = pos;
	for (i = 0; i < OBITUARY_LINES; i++) {
		string a, v;

		if (!g_obituary[i].victim) {
			break;
		}

		item[0] = pos[0];

		v = g_obituary[i].victim;
		drawstring_r(item + [0,2], v, [12,12], [1,1,1], 1.0f, 0);
		item[0] -= stringwidth(v, TRUE, [12,12]) + 4;


		//item[0] -= g_obtypes[g_obituary[i].icon].size[0];

		HLSprite_Draw_RGBA(g_obituary[i].icon, item, g_hud_color, 1.0f, true);

		// draw g_obituary[i].icon

		a = g_obituary[i].attacker;
		drawstring_r(item + [-4,2], a, [12,12], [1,1,1], 1.0f, 0);
		item[1] += 18;
	}

	g_obituary_time = max(0, g_obituary_time - clframetime);
}

void
Obituary_Parse(void)
{
	string attacker;
	string victim;
	string weapon;
	float flags;

	attacker = readstring();
	victim = readstring();
	weapon = readstring();
	flags = readbyte();
	
	if (!attacker) {
		return;
	}

	Obituary_Add(attacker, victim, weapon, flags);
}
