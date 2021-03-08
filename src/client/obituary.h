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

#define OBITUARY_LINES	4
#define OBITUARY_TIME	5

/* imagery */
typedef struct {
	string name;			/* name of the weapon/type, e.g. d_crowbar */
	string sprite;			/* name of the spritesheet it's from */
	float size[2];			/* on-screen size in pixels */
	float src_pos[2];		/* normalized position in the sprite sheet */
	float src_size[2];		/* normalized size in the sprite sheet */
	string src_sprite;		/* precaching reasons */
} obituaryimg_t;

obituaryimg_t *g_obtypes;
int g_obtype_count;

/* actual obituary storage */
typedef struct
{
	string attacker;
	string victim;
	int icon;
} obituary_t;

obituary_t g_obituary[OBITUARY_LINES];
int g_obituary_count;
float g_obituary_time;

void Obituary_Init(void);
void Obituary_Precache(void);
void Obituary_Draw(void);
void Obituary_Parse(void);
