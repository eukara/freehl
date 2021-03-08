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

#define SCORE_HEADER_C [255/255,156/255,0]
#define SCORE_LINE_C [255/255,200/255,0]

var int autocvar_cl_centerscores = FALSE;
var int g_scores_teamplay = 0;

void
Scores_Init(void)
{
	g_scores_teamplay = (int)serverkeyfloat("teamplay");
}

void
Scores_DrawTeam(player pl, vector pos)
{
	drawfill(pos, [290, 1], SCORE_LINE_C, 1.0f, DRAWFLAG_ADDITIVE);

	drawfont = FONT_20;
	drawstring(pos + [0,-18], "Teams", [20,20], SCORE_HEADER_C, 1.0f, DRAWFLAG_ADDITIVE);
	drawstring(pos + [124,-18], "kills / deaths", [20,20], SCORE_HEADER_C, 1.0f, DRAWFLAG_ADDITIVE);
	drawstring(pos + [240,-18], "latency", [20,20], SCORE_HEADER_C, 1.0f, DRAWFLAG_ADDITIVE);
	
	pos[1] += 12;

	for (int t = 1; t <= serverkeyfloat("teams"); t++) {
		float l;
		string temp;
		drawstring(pos, serverkey(sprintf("team_%i", t)), [20,20], SCORE_HEADER_C, 1.0f, DRAWFLAG_ADDITIVE);
		temp = serverkey(sprintf("teamscore_%i", t));
		l = stringwidth(temp, FALSE, [20,20]);
		drawstring(pos + [150-l, 0], temp, [20,20], SCORE_HEADER_C, 1.0f, DRAWFLAG_ADDITIVE);
		drawstring(pos + [158, 0], "wins", [20,20], SCORE_HEADER_C, 1.0f, DRAWFLAG_ADDITIVE);
		pos[1] += 16;

		for (int i = -1; i > -32; i--) {
			if (getplayerkeyfloat(i, "*team") != t) {
				continue;
			}

			temp = getplayerkeyvalue(i, "name");

			/* Out of players */
			if (!temp) {
				break;
			} else if (temp == getplayerkeyvalue(pl.entnum-1, "name")) {
				drawfill(pos, [290, 13], [0,0,1], 0.5f, DRAWFLAG_ADDITIVE);
			}

			drawstring(pos + [24,0], getplayerkeyvalue(i, "name"), [20,20], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);
			drawstring(pos + [154,0], "/", [20,20], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);

			/* Get the kills and align them left to right */
			temp = getplayerkeyvalue(i, "frags");
			l = stringwidth(temp, FALSE, [20,20]);
			drawstring(pos + [150 - l,0], temp, [20,20], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);

			/* Deaths are right to left aligned */
			temp = getplayerkeyvalue(i, "*deaths");
			drawstring(pos + [165,0], temp, [20,20], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);

			/* Get the latency and align it left to right */
			temp = getplayerkeyvalue(i, "ping");
			l = stringwidth(temp, FALSE, [20,20]);

			if (getplayerkeyfloat(i, "*dead") == 1) {
				drawsubpic(
					pos - [8,0],
					[32,16],
					g_hud1_spr,
					[224/256, 240/256],
					[32/256, 16/256],
					[1,0,0],
					1.0f,
					DRAWFLAG_ADDITIVE
				);
			}

			drawstring(pos + [290 - l,0], temp, [20,20], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);
			pos[1] += 20;
		}
		pos[1] += 12;
	}
	
	drawfont = FONT_CON;
}

void
Scores_DrawNormal(player pl, vector pos)
{
	drawfill(pos, [290, 1], SCORE_LINE_C, 1.0f, DRAWFLAG_ADDITIVE);

	drawfont = FONT_20;
	drawstring(pos + [0,-18], "Player", [20,20], SCORE_HEADER_C, 1.0f, DRAWFLAG_ADDITIVE);
	drawstring(pos + [124,-18], "kills / deaths", [20,20], SCORE_HEADER_C, 1.0f, DRAWFLAG_ADDITIVE);
	drawstring(pos + [240,-18], "latency", [20,20], SCORE_HEADER_C, 1.0f, DRAWFLAG_ADDITIVE);
	
	pos[1] += 12;
	for (int i = -1; i > -32; i--) {
		float l;
		string ping;
		string kills;
		string deaths;
		string name;

		name = getplayerkeyvalue(i, "name");

		/* Out of players */
		if (!name) {
			break;
		} else if (name == getplayerkeyvalue(pl.entnum-1, "name")) {
			drawfill(pos, [290, 13], [0,0,1], 0.5f, DRAWFLAG_ADDITIVE);
		}

		drawstring(pos, getplayerkeyvalue(i, "name"), [20,20], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);
		drawstring(pos + [154,0], "/", [20,20], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);

		/* Get the kills and align them left to right */
		kills = getplayerkeyvalue(i, "frags");
		l = stringwidth(kills, FALSE, [20,20]);
		drawstring(pos + [150 - l,0], kills, [20,20], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);

		/* Deaths are right to left aligned */
		deaths = getplayerkeyvalue(i, "*deaths");
		drawstring(pos + [165,0], deaths, [20,20], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);

		/* Get the latency and align it left to right */
		ping = getplayerkeyvalue(i, "ping");
		l = stringwidth(ping, FALSE, [20,20]);

		drawstring(pos + [290 - l,0], ping, [20,20], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);
		pos[1] += 20;
	}
	
	drawfont = FONT_CON;
}

void
Scores_Draw(void)
{
	vector pos;
	player pl;
	
	pl = (player)pSeat->m_ePlayer;

	if (autocvar_cl_centerscores) {
		int c = 10;
		
		/* calculate all valid entries */
		for (int i = -1; i > -32; i--) {
			if (getplayerkeyvalue(i, "name")) {
				break;
			}
			c += 10;
		}
		pos = video_mins + [(video_res[0] / 2) - 145, (video_res[1] / 2) - c];
	} else {
		pos = video_mins + [(video_res[0] / 2) - 145, 30];
	}

	if (serverkeyfloat("teams") > 0) {
		Scores_DrawTeam(pl, pos);
	} else {
		Scores_DrawNormal(pl, pos);
	}
}
