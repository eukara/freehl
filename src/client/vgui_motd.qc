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

void
VGUI_ShowMOTD(void)
{
	static int initialized;
	static vguiButton winMotdClose;
	static vguiWindow winMotd;
	static vguiLabel winMotdHostname;
	static vguiLabel winMotdBody;
	
	static void VGUI_ShowMOTD_Close(void)
	{
		int playerTeam = player.GetTeam();
		bool teamSelect = ((playerTeam == TEAM_UNASSIGNED) || (playerTeam == TEAM_SPECTATOR)) ? (true) : (false);

		if (playerTeam == 0) {
			teamSelect = true;
		}

// 		printf("MOTD opening team? %i %d open teams: %i\n", playerTeam, teamSelect, teams.OpenTeamCount());

		if (teams.OpenTeamCount() > 0i && teamSelect) {
			VGUI_ChooseTeam();
		}

		if (winMotd) {
			winMotd.Hide();
		}
	}

	if (MOTD_GetLineCount() < 1i) {
		VGUI_ShowMOTD_Close();
		return;
	}

	if (!initialized) {
		initialized = TRUE;
		winMotd = spawn(vguiWindow);
		winMotd.SetTitle("Message Of The Day");
		winMotd.SetStyleMask(vguiWindowBorderless | vguiWindowFullscreen);
		winMotd.SetSize('424 312');
		winMotd.SetStyleMask(0);

		winMotdClose = spawn(vguiButton);
		winMotdClose.SetTitle("OK");
		winMotdClose.SetPos([16, 266]);
		winMotdClose.SetSize([160, 30]);
		winMotdClose.SetFunc(VGUI_ShowMOTD_Close);

		winMotdHostname = spawn(vguiLabel);
		winMotdHostname.SetTitle(serverkey("hostname"));
		winMotdHostname.SetTextSize(19);
		winMotdHostname.SetPos([16, 20]);

		winMotdBody = spawn(vguiLabel);
		winMotdBody.SetTitle(MOTD_GetTextBody());
		winMotdBody.SetPos([16, 48]);
		winMotdBody.SetSize([392, 210]);

		g_uiDesktop.Add(winMotd);
		winMotd.Add(winMotdClose);
		winMotd.Add(winMotdHostname);
		winMotd.Add(winMotdBody);
	}

	winMotd.Show();
	winMotd.SetPos((g_vidsize / 2) - (winMotd.GetSize() / 2));
}
