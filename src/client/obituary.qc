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

void
Obituary_Init(void)
{
	int c;
	int i;
	filestream fh;
	string line;
	vector tmp;

	if (g_obtype_count > 0) {
		return;
	}

	g_obtype_count = 0;
	i = 0;

	fh = fopen("sprites/hud.txt", FILE_READ);
	if (fh < 0) {
		return;
	}

	/* count valid entries */
	while ((line = fgets(fh))) {
		if (substring(line, 0, 2) == "d_") {
			c = tokenize(line);
			if (c == 7 && argv(1) == "640") {
				g_obtype_count++;
			}
		}
	}

	g_obtypes = memalloc(sizeof(obituaryimg_t) * g_obtype_count);

	fseek(fh, 0);

	/* read them in */
	while ((line = fgets(fh))) {
		if (substring(line, 0, 2) == "d_") {
			c = tokenize(line);

			/* we only care about the high-res (640) variants. the 320
			 * HUD is useless to us. Just use the builtin scaler */
			if (c == 7 && argv(1) == "640") {
				g_obtypes[i].name = substring(argv(0), 2, -1);
				g_obtypes[i].src_sprite = sprintf("sprites/%s.spr", argv(2));
				precache_model(g_obtypes[i].src_sprite);
				g_obtypes[i].sprite = spriteframe(sprintf("sprites/%s.spr", argv(2)), 0, 0.0f);
				g_obtypes[i].size[0] = stof(argv(5));
				g_obtypes[i].size[1] = stof(argv(6));
				tmp = drawgetimagesize(g_obtypes[i].sprite);
				g_obtypes[i].src_pos[0] = stof(argv(3)) / tmp[0];
				g_obtypes[i].src_pos[1] = stof(argv(4)) / tmp[1];
				g_obtypes[i].src_size[0] = g_obtypes[i].size[0] / tmp[0];
				g_obtypes[i].src_size[1] = g_obtypes[i].size[1] / tmp[1];
				i++;
			}
		}
	}

	fclose(fh);
}

void
Obituary_Precache(void)
{
	for (int i = 0; i < g_obtype_count; i++)
		precache_model(g_obtypes[i].src_sprite);
}

void
Obituary_KillIcon(int id, float w)
{
	if (w > 0)
	for (int i = 0; i < g_obtype_count; i++) {
		if (g_weapons[w].name == g_obtypes[i].name) {
			g_obituary[id].icon = i;
			return;
		}
	}

	/* look for skull instead */
	for (int i = 0; i < g_obtype_count; i++) {
		if (g_obtypes[i].name == "skull") {
			g_obituary[id].icon = i;
			return;
		}
	}
}

void
Obituary_Add(string attacker, string victim, float weapon, float flags)
{
	int i;
	int x, y;
	x = OBITUARY_LINES;

	/* we're not full yet, so fill up the buffer */
	if (g_obituary_count < x) {
		y = g_obituary_count;
		g_obituary[y].attacker = attacker;
		g_obituary[y].victim = victim;
		Obituary_KillIcon(y, weapon);
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
		Obituary_KillIcon(x-1, weapon);
	}

	g_obituary_time = OBITUARY_TIME;

	if (g_weapons[weapon].deathmsg) {
		string conprint = g_weapons[weapon].deathmsg();

		if (conprint != "") {
			print(sprintf(conprint, attacker, victim));
			print("\n");
		}
	}
}

void
Obituary_Draw(void)
{
	int i;
	vector pos;
	vector item;
	drawfont = FONT_CON;
	pos = g_hudmins + [g_hudres[0] - 18, 56];

	if (g_obituary_time <= 0 && g_obituary_count > 0) {
		for (i = 0; i < (OBITUARY_LINES-1); i++) {
			g_obituary[i].attacker = g_obituary[i+1].attacker;
			g_obituary[i].victim = g_obituary[i+1].victim;
			g_obituary[i].icon = g_obituary[i+1].icon;
		}
		g_obituary[OBITUARY_LINES-1].attacker = "";

		g_obituary_time = OBITUARY_TIME;
		g_obituary_count--;
	}

	if (g_obituary_count <= 0) { 
		return;
	}

	item = pos;
	for (i = 0; i < OBITUARY_LINES; i++) {
		string a, v;

		if (!g_obituary[i].attacker) {
			break;
		}

		item[0] = pos[0];

		v = g_obituary[i].victim;
		drawstring_r(item + [0,2], v, [12,12], [1,1,1], 1.0f, 0);
		item[0] -= stringwidth(v, TRUE, [12,12]) + 4;
		item[0] -= g_obtypes[g_obituary[i].icon].size[0];

		drawsubpic(
			item,
			[g_obtypes[g_obituary[i].icon].size[0], g_obtypes[g_obituary[i].icon].size[1]],
			g_obtypes[g_obituary[i].icon].sprite,
			[g_obtypes[g_obituary[i].icon].src_pos[0],g_obtypes[g_obituary[i].icon].src_pos[1]],
			[g_obtypes[g_obituary[i].icon].src_size[0],g_obtypes[g_obituary[i].icon].src_size[1]],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);

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
	float weapon;
	float flags;

	attacker = readstring();
	victim = readstring();
	weapon = readbyte();
	flags = readbyte();
	
	if (!attacker) {
		return;
	}

	Obituary_Add(attacker, victim, weapon, flags);
}
