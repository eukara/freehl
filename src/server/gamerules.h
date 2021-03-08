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

class HLGameRules:CGameRules
{
	virtual void(base_player) PlayerConnect;
	virtual void(base_player) PlayerDisconnect;
	virtual void(base_player) PlayerKill;
	virtual void(base_player) PlayerPostFrame;

	virtual void(base_player) LevelDecodeParms;
	virtual void(base_player) LevelChangeParms;
	virtual void(void) LevelNewParms;
};

class HLSingleplayerRules:HLGameRules
{
	/* client */
	virtual void(base_player) PlayerSpawn;
	virtual void(base_player) PlayerDeath;
};

class HLMultiplayerRules:HLGameRules
{
	int m_iIntermission;
	int m_iIntermissionTime;

	virtual void(void) FrameStart;

	/* client */
	virtual void(base_player) PlayerSpawn;
	virtual void(base_player) PlayerDeath;
	virtual float(base_player, string) ConsoleCommand;
};
