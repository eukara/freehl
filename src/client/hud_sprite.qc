/*
 * Copyright (c) 2023 Marco Cawthorne <marco@icculus.org>
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

typedef struct
{
	string m_strImage;
	vector m_vecSize;
	vector m_vecCanvasSize;
	vector m_vecCanvasPos;
} hlsprite_t;

hlsprite_t *g_hlsprites;
var hashtable g_hashhlsprite;

void
HLSprite_Init(void)
{
	filestream hudFile;
	vector imgSize;
	int spriteCount = 0i;
	int i = 0i;
	int c = 0i;
	string line;

	hudFile = fopen("sprites/hud.txt", FILE_READ);

	if (hudFile < 0) {
		NSError("Missing file sprites/hud.txt");
		return;
	}

	/* count valid entries */
	while ((line = fgets(hudFile))) {
		c = tokenize_console(line);

		if (c != 7)
			continue;

		if (argv(1) != "640")
			continue;

		spriteCount++;
	}

	/* if we couldn't find anything, don't bother */
	if (spriteCount <= 0i)
		return;

	/* allocate our hashtable */
	if (!g_hashhlsprite) {
		g_hashhlsprite = hash_createtab(2, HASH_ADD);
	}

	/* to the beginning we go. */
	fseek(hudFile, 0);
	/* allocate valid entries */
	g_hlsprites = memalloc(sizeof(hlsprite_t) * spriteCount);

	/* read the data into our banks */
	while ((line = fgets(hudFile))) {
		c = tokenize_console(line);

		if (c != 7)
			continue;

		if (argv(1) != "640")
			continue;

		g_hlsprites[i].m_strImage = spriteframe(sprintf("sprites/%s.spr", argv(2)), 0, 0.0f);
		g_hlsprites[i].m_vecSize[0] = stof(argv(5));
		g_hlsprites[i].m_vecSize[1] = stof(argv(6));
		imgSize = drawgetimagesize(g_hlsprites[i].m_strImage);
		g_hlsprites[i].m_vecCanvasPos[0] = stof(argv(3)) / imgSize[0];
		g_hlsprites[i].m_vecCanvasPos[1] = stof(argv(4)) / imgSize[1];
		g_hlsprites[i].m_vecCanvasSize[0] = g_hlsprites[i].m_vecSize[0] / imgSize[0];
		g_hlsprites[i].m_vecCanvasSize[1] = g_hlsprites[i].m_vecSize[1] / imgSize[1];
		hash_add(g_hashhlsprite, argv(0), (int)i);
		i++;
	}

	NSLog("...initialized %i HL sprites.", spriteCount);
}

void
HLSprite_Draw_RGBA(string spriteName, vector spritePos, vector spriteColor, float spriteAlpha, bool isAdditive)
{
	int spriteNum = -1i;

	spriteNum = (int)hash_get(g_hashhlsprite, spriteName, -1i);

	if (spriteNum == -1i) {
		NSError("Cannot draw sprite %S!", spriteName);
		return;
	}

	drawsubpic(
		spritePos,
		g_hlsprites[spriteNum].m_vecSize,
		g_hlsprites[spriteNum].m_strImage,
		g_hlsprites[spriteNum].m_vecCanvasPos,
		g_hlsprites[spriteNum].m_vecCanvasSize,
		spriteColor,
		spriteAlpha,
		isAdditive ? DRAWFLAG_ADDITIVE : 0
	);
}

void
HLSprite_Draw(string spriteName, vector spritePos, bool isAdditive)
{
	HLSprite_Draw_RGBA(spriteName, spritePos, [1,1,1], 1.0f, isAdditive);
}

void
HLSprite_Draw_A(string spriteName, vector spritePos, float spriteAlpha, bool isAdditive)
{
	HLSprite_Draw_RGBA(spriteName, spritePos, [1,1,1], spriteAlpha, isAdditive);
}

void
HLSprite_Draw_RGB(string spriteName, vector spritePos, vector spriteColor, bool isAdditive)
{
	HLSprite_Draw_RGBA(spriteName, spritePos, spriteColor, 1.0f, isAdditive);
}