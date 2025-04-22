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

hlsprite_t *g_hlsprites;
var hashtable g_hashhlsprite;
var int g_hlSpriteCount;

static int
HLSprite_CountEntriesInFile(string fileName)
{
	int spriteCount = 0i;
	filestream hudFile;
	string line;
	int c = 0i;

	hudFile = fopen(fileName, FILE_READ);

	if (hudFile < 0) {
		ncError("Missing file %S", fileName);
		return (-1i);
	}

	/* count valid entries */
	while ((line = fgets(hudFile))) {
		c = tokenize_console(line);

		if (c != 7) {
			continue;
		}

		if (argv(1) != "640") {
			continue;
		}

		spriteCount += 1i;
	}

	fclose(hudFile);

	return (spriteCount);
}

static bool
HLSprite_LoadFromFile(string fileName, string prefix)
{
	filestream hudFile;
	int c = 0i;
	vector imgSize = g_vec_null;
	string line = "";
	string sheetName;

	hudFile = fopen(fileName, FILE_READ);

	if (hudFile < 0) {
		ncError("Missing file %S", fileName);
		return (false);
	}

	while ((line = fgets(hudFile))) {
		c = tokenize_console(line);

		if (c != 7)
			continue;

		if (argv(1) != "640")
			continue;

		if (prefix != "")
			sheetName = strcat(prefix, argv(0));
		else
			sheetName = argv(0);

		//printf("%S %S\n", sheetName, prefix);

		g_hlsprites[g_hlSpriteCount].m_strImage = spriteframe(sprintf("sprites/%s.spr", argv(2)), 0, 0.0f);
		g_hlsprites[g_hlSpriteCount].m_vecSize[0] = stof(argv(5));
		g_hlsprites[g_hlSpriteCount].m_vecSize[1] = stof(argv(6));
		imgSize = drawgetimagesize(g_hlsprites[g_hlSpriteCount].m_strImage);
		g_hlsprites[g_hlSpriteCount].m_vecCanvasPos[0] = stof(argv(3)) / imgSize[0];
		g_hlsprites[g_hlSpriteCount].m_vecCanvasPos[1] = stof(argv(4)) / imgSize[1];
		g_hlsprites[g_hlSpriteCount].m_vecCanvasSize[0] = g_hlsprites[g_hlSpriteCount].m_vecSize[0] / imgSize[0];
		g_hlsprites[g_hlSpriteCount].m_vecCanvasSize[1] = g_hlsprites[g_hlSpriteCount].m_vecSize[1] / imgSize[1];
		hash_add(g_hashhlsprite, sheetName, (int)g_hlSpriteCount);
		g_hlSpriteCount += 1i;
	}

	fclose(hudFile);
	return (true);
}

void
HLSprite_Init(void)
{
	int spriteCount = 0i;
	searchhandle sh;
	string hudFile;
	string prefix;

	g_hlSpriteCount = 0i;
	spriteCount = HLSprite_CountEntriesInFile("sprites/hud.txt");

	sh = search_begin("sprites/*weapon_*.txt", TRUE, TRUE);

	for (int i = 0; i < search_getsize(sh); i++) {
		hudFile = search_getfilename(sh, i);
		spriteCount += HLSprite_CountEntriesInFile(hudFile);
	}

	/* if we couldn't find anything, don't bother */
	if (spriteCount <= 0i)
		return;

	/* allocate our hashtable */
	if (!g_hashhlsprite) {
		g_hashhlsprite = hash_createtab(2, HASH_ADD);
	}

	/* allocate valid entries */
	g_hlsprites = memalloc(sizeof(hlsprite_t) * spriteCount);

	/* read the data into our banks */
	HLSprite_LoadFromFile("sprites/hud.txt", "");

	for (int i = 0; i < search_getsize(sh); i++) {
		hudFile = search_getfilename(sh, i);
		prefix = substring(hudFile, 8, -4);
		HLSprite_LoadFromFile(hudFile, prefix);
	}

	search_end(sh);
	ncLog("...initialized %i HL sprites.", spriteCount);
}

void
HLSprite_Draw_RGBA(string spriteName, vector spritePos, vector spriteColor, float spriteAlpha, bool isAdditive)
{
	int spriteNum = -1i;

	spriteNum = (int)hash_get(g_hashhlsprite, spriteName, -1i);

	if (spriteNum == -1i) {
		ncError("Cannot draw sprite %S!", spriteName);
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

void
HLSprite_DrawCrosshair(string spriteName)
{
	int spriteNum = -1i;

	if (!spriteName) {
		return;
	}

	spriteNum = (int)hash_get(g_hashhlsprite, spriteName, -1i);

	if (spriteNum == -1i) {
		ncError("Cannot draw sprite %S!", spriteName);
		return;
	}

	Cross_DrawSub(g_hlsprites[spriteNum].m_strImage, g_hlsprites[spriteNum].m_vecSize, g_hlsprites[spriteNum].m_vecCanvasPos, g_hlsprites[spriteNum].m_vecCanvasSize);
}
