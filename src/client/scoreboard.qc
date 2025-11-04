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

/* New Style Scoreboard. Needs to do caching, very slow atm! */

var vector autocvar_sb_fgColor = [255/255,156/255,0];
var vector autocvar_sb_bgColor = [0,0,0];
var vector autocvar_sb_hiColor = [255/255,156/255,0];
var vector autocvar_sb_loColor = [0,0,0];
var int autocvar_sb_avatarSize = 32;
var bool autocvar_sb_roundedCorners = true;
var bool autocvar_sb_showAvatars = false;
var bool autocvar_sb_anonymizeIdentities = false;
var bool autocvar_sb_showFediHandle = true;

#define SCORE_HEADER_C autocvar_sb_hiColor


var bool autocvar_cg_centerScores = true;
var int g_scores_teamplay = 0;
var bool g_scores_scorepoints = false;

void
Scores_Init(void)
{
	g_scores_teamplay = (int)serverkeyfloat("teamplay");
	g_scores_scorepoints = (bool)serverkeyfloat("scorepoints");
}

string
Scoreboard_GetAvatar(float playerNum)
{
	string playerAvatar = getplayerkeyvalue(playerNum, "*av");
	
	if (!STRING_SET(playerAvatar)) {
		return "gfx/ui/avatar_missing";
	}
	
	return (playerAvatar);
}

string
Scoreboard_GetName(float playerNum, string selfName)
{
	string playerName = getplayerkeyvalue(playerNum, "name");
	
	if (autocvar_sb_anonymizeIdentities && playerName != selfName) {
		return sprintf("Player %d", playerNum);
	}
	
	if (autocvar_sb_showFediHandle) {
		string fediHandle = getplayerkeyvalue(playerNum, "*ap");
		
		if (STRING_SET(fediHandle)) {
			return strcat(playerName, " ^x999 | ", fediHandle);
		}
	}
	
	return (playerName);
}

void
Scores_Draw(void)
{
	vector pos;
	ncPlayer pl;
	
	pl = (ncPlayer)pSeat->m_ePlayer;
	ncUserInfo playerInfo = g_userInfo.LocalPlayerInfo();
	int teamCount = teams.TeamCount();
	int playerTeam =  playerInfo.Team();
	int c = 6i;
	string temp;

	float scoreboardWidth = screen.HUDSize()[0] - 120;
	float scoreboardHeight = screen.HUDSize()[1] - 120;
	const float playerPadding = 7;
	vector scorePos = screen.HUDMins() + [60,60];
	vector hostnamePos = scorePos + [6,6];
	vector hostlinePos = hostnamePos + [0, 18];
	string latencyLocalized = "Latency";
	string deathsLocalized = "Deaths";
	string scoreLocalized = "Score";
	float latencyPos = scorePos[0] + scoreboardWidth - 6 - font.StringWidth(latencyLocalized, false, FONT_SCORES_NORMAL) - playerPadding;
	float deathsPos = latencyPos - 28 - font.StringWidth(deathsLocalized, false, FONT_SCORES_NORMAL);
	float scoresPos = deathsPos - 28 - font.StringWidth(scoreLocalized, false, FONT_SCORES_NORMAL);
	string selfName = playerInfo.Name();
	float playerTextHeight = font.GetHeight(FONT_SCORES_BOLD);
	float playerStackSize = playerTextHeight + 4;
	float playerTextOffset = 0.0f;
	
	pos = hostlinePos + [0, 6];

	if (autocvar_sb_roundedCorners) {
		draw.RoundedBox(scorePos, [scoreboardWidth, scoreboardHeight], autocvar_sb_bgColor, 0.5f);
		draw.RoundedRectOutline(scorePos, [scoreboardWidth, scoreboardHeight], autocvar_sb_fgColor, 1.0f);
	} else {
		draw.Rect(scorePos, [scoreboardWidth, scoreboardHeight], autocvar_sb_bgColor, 0.5f);
		draw.RectOutline(scorePos, [scoreboardWidth, scoreboardHeight], 1.0f, autocvar_sb_fgColor, 1.0f);
	}

	draw.Text_RGBA(hostnamePos, serverinfo.GetString("hostname"), SCORE_HEADER_C, 1.0f, FONT_SCORES_BOLD);
	draw.Line(1.0f, hostlinePos, hostlinePos + [scoreboardWidth - 12, 0] , autocvar_sb_loColor, 1.0f);

	draw.Text_RGBA([latencyPos, hostnamePos[1]], latencyLocalized, SCORE_HEADER_C, 1.0f, FONT_SCORES_NORMAL);
	draw.Text_RGBA([deathsPos, hostnamePos[1]], deathsLocalized, SCORE_HEADER_C, 1.0f, FONT_SCORES_NORMAL);
	draw.Text_RGBA([scoresPos, hostnamePos[1]], scoreLocalized, SCORE_HEADER_C, 1.0f, FONT_SCORES_NORMAL);

	draw.Text_RGBA(pos, strcat("Mode: ", serverinfo.GetString("mode")), SCORE_HEADER_C, 1.0f, FONT_SCORES_NORMAL);
	pos[1] += 14;
	draw.Line(1.0f, pos, pos + [scoreboardWidth - 12, 0] , autocvar_sb_loColor, 1.0f);
	pos[1] += 6;

	if (autocvar_sb_showAvatars) {
		playerTextOffset = ((autocvar_sb_avatarSize - playerTextHeight) / 2);
		playerStackSize = autocvar_sb_avatarSize;
	}

	if (Util_IsTeamplay() && !(teams.Flags(playerTeam) & TEAMFLAG_TEAMBLIND)) {
		for (int t = 1; t <= teamCount; t++) {
			vector teamColor = teams.Color(t);
			int playerCount = teams.NumPlayers(t);
			bool showScoreValue = true;
			
			if (playerTeam == t) {
				if (teams.Flags(playerTeam) & TEAMFLAG_OTHERSCOREBLIND) {
					showScoreValue = false;
				}
			} else {
				if (teams.Flags(playerTeam) & TEAMFLAG_SELFSCOREBLIND) {
					showScoreValue = false;
				}
			}

			if (playerCount == 1)
				draw.Text_RGBA(pos, sprintf("%s    -    %i player", teams.Name(t), teams.NumPlayers(t)), teamColor, 1.0f, FONT_SCORES_NORMAL);
			else
				draw.Text_RGBA(pos, sprintf("%s    -    %i players", teams.Name(t), teams.NumPlayers(t)), teamColor, 1.0f, FONT_SCORES_NORMAL);

			draw.RText_RGBA([deathsPos - 28, pos[1]], serverkey(sprintf("teamscore_%i", t)), teamColor, 1.0f, FONT_SCORES_NORMAL);

			pos[1] += 14;
			draw.Line(1.0f, pos, pos + [scoreboardWidth - 12, 0] , teamColor, 1.0f);
			pos[1] += 2;

			for (int i = -1; i > -32; i--) {
				if (getplayerkeyfloat(i, "*team") != t) {
					continue;
				}

				temp = Scoreboard_GetName(i, selfName);

				/* Out of players */
				if (!temp) {
					break;
				} else if (temp == selfName) {
					draw.Rect(pos, [scoreboardWidth - 12, playerStackSize], [1,1,1], 0.1f);
				} else if (autocvar_sb_anonymizeIdentities) {
					temp = sprintf("Player %i", i);
				}

				if (showScoreValue) {
					draw.RText_RGBA([deathsPos - 28, pos[1] + 2 + playerTextOffset], getplayerkeyvalue(i, "frags"), teamColor, 1.0f, FONT_SCORES_BOLD);
					draw.RText_RGBA([latencyPos - 28, pos[1] + 2 + playerTextOffset], getplayerkeyvalue(i, "*deaths"), teamColor, 1.0f, FONT_SCORES_BOLD);
				} else {
					if (temp == selfName) {
						draw.RText_RGBA([deathsPos - 28, pos[1] + 2 + playerTextOffset], getplayerkeyvalue(i, "frags"), teamColor, 1.0f, FONT_SCORES_BOLD);
						draw.RText_RGBA([latencyPos - 28, pos[1] + 2 + playerTextOffset], getplayerkeyvalue(i, "*deaths"), teamColor, 1.0f, FONT_SCORES_BOLD);
					} else {
						draw.RText_RGBA([deathsPos - 28, pos[1] + 2 + playerTextOffset], "?", teamColor, 1.0f, FONT_SCORES_BOLD);
						draw.RText_RGBA([latencyPos - 28, pos[1] + 2 + playerTextOffset], "?", teamColor, 1.0f, FONT_SCORES_BOLD);
					}
				}

				draw.RText_RGBA([scorePos[0] + scoreboardWidth - 6 - playerPadding, pos[1] + 2 + playerTextOffset], getplayerkeyvalue(i, "ping"), teamColor, 1.0f, FONT_SCORES_BOLD);
				
				if (autocvar_sb_showAvatars) {
					draw.Rect(pos + [playerPadding,0], [playerStackSize, playerStackSize], autocvar_sb_bgColor, 0.5f);
					draw.Pic(pos + [playerPadding,0], Scoreboard_GetAvatar(i), [playerStackSize,playerStackSize], [1,1,1], 1.0f, DRAWFLAG_NORMAL);
					draw.RectOutline(pos + [playerPadding,0], [playerStackSize, playerStackSize], 1.0f, teamColor, 1.0f);
					draw.Text_RGBA(pos + [playerStackSize + 6 + playerPadding,2 + playerTextOffset], temp, teamColor, 1.0f, FONT_SCORES_BOLD);
					pos[1] += 4;
				} else {
					draw.Text_RGBA(pos + [playerPadding,2], temp, teamColor, 1.0f, FONT_SCORES_BOLD);
				}


				pos[1] += playerStackSize;
			}
			pos[1] += 12;
		}
	} else {
		for (int i = -1; i > -32; i--) {
			bool showScoreValue = true;

			if (getplayerkeyfloat(i, "*spec") != 0) {
				continue;
			}

			temp = Scoreboard_GetName(i, selfName);

			/* Out of players */
			if (!STRING_SET(temp)) {
				break;
			} else if (temp == selfName) {
				draw.Rect(pos, [scoreboardWidth - 12, playerStackSize], [1,1,1], 0.1f);
			}

			if ((teams.Flags(playerTeam) & TEAMFLAG_OTHERSCOREBLIND) && (temp != selfName)) {
				draw.RText_RGBA([deathsPos - 28, pos[1] + 2 + playerTextOffset], "?", SCORE_HEADER_C, 1.0f, FONT_SCORES_BOLD);
				draw.RText_RGBA([latencyPos - 28, pos[1] + 2 + playerTextOffset], "?", SCORE_HEADER_C, 1.0f, FONT_SCORES_BOLD);
			} else {
				draw.RText_RGBA([deathsPos - 28, pos[1] + 2 + playerTextOffset], getplayerkeyvalue(i, "frags"), SCORE_HEADER_C, 1.0f, FONT_SCORES_BOLD);
				draw.RText_RGBA([latencyPos - 28, pos[1] + 2 + playerTextOffset], getplayerkeyvalue(i, "*deaths"), SCORE_HEADER_C, 1.0f, FONT_SCORES_BOLD);
			}

			draw.RText_RGBA([scorePos[0] + scoreboardWidth - 6 - playerPadding, pos[1] + 2 + playerTextOffset], getplayerkeyvalue(i, "ping"), SCORE_HEADER_C, 1.0f, FONT_SCORES_BOLD);
			
			if (autocvar_sb_showAvatars) {
				draw.Rect(pos + [playerPadding,0], [playerStackSize, playerStackSize], autocvar_sb_bgColor, 0.5f);
				draw.Pic(pos + [playerPadding,0], Scoreboard_GetAvatar(i), [playerStackSize,playerStackSize], [1,1,1], 1.0f, DRAWFLAG_NORMAL);
				draw.RectOutline(pos + [playerPadding,0], [playerStackSize, playerStackSize], 1.0f, SCORE_HEADER_C, 1.0f);
				draw.Text_RGBA(pos + [playerStackSize + 6 + playerPadding,2 + playerTextOffset], temp, SCORE_HEADER_C, 1.0f, FONT_SCORES_BOLD);
				pos[1] += 4;
			} else {
				draw.Text_RGBA(pos + [playerPadding,2], temp, SCORE_HEADER_C, 1.0f, FONT_SCORES_BOLD);
			}
				
			pos[1] += playerStackSize;
		}
	}
}
