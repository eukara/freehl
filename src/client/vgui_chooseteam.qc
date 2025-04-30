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

static vguiWindow winChooseTeam;

class VGUITeamSelectButton:vguiButton
{
	void VGUITeamSelectButton(void);

	virtual void OnMouseUp(void);
};

void
VGUITeamSelectButton::VGUITeamSelectButton(void)
{
}

void
VGUITeamSelectButton::OnMouseUp(void)
{
	int tag = GetTag();

	if (tag == 0) {
		tag = teams.BestAutoJoinTeam();
	}

	localcmd(sprintf("cmd joinTeam %i\n", tag));

	if (teams.TotalClasses(tag) > 0i) {
		VGUI_ChooseClass(tag);
	} else {
		localcmd("cmd join\n");
	}

	winChooseTeam.Hide();
}

string
VGUI_ChooseTeam_MapInfo(void)
{
	static string mapinfo = __NULL__;

	if (mapinfo != __NULL__)
		return mapinfo;
	
	filestream fileMap = fopen(strcat("maps/", mapname, ".txt"), FILE_READ);
	string temp;

	if (fileMap != -1) {
		while ((temp = fgets(fileMap))) {
			mapinfo = strcat(mapinfo, temp, "\n");
		}
	} else {
		mapinfo = Titles_GetTextBody("Map_Description_not_available");
	}

	return mapinfo;
}

void
VGUI_ChooseTeam(void)
{
	static int initialized;
	static vguiButton btnAutoAssign;
	static vguiButton btnGoSpectator;
	static vguiFrame frmMapInfo;
	static vguiLabel lblSelectTeam;
	static vguiLabel lblMapName;
	static vguiLabel lblMapInfo;

	if (!initialized) {
		vector btnpos = [40,80];

		initialized = TRUE;
		winChooseTeam = spawn(vguiWindow);
		winChooseTeam.SetSize('640 480');
		winChooseTeam.SetStyleMask(vguiWindowBorderless | vguiWindowFullscreen);

		lblSelectTeam = spawn(vguiLabel);
		lblSelectTeam.SetTitle(Titles_GetTextBody("Title_SelectYourTeam"));
		lblSelectTeam.SetTextSize(19);
		lblSelectTeam.SetPos([40, 38]);
		lblSelectTeam.SetSize('400 24');

		frmMapInfo = spawn(vguiFrame);
		frmMapInfo.SetPos('176 80');
		frmMapInfo.SetSize('424 312');

		lblMapName = spawn(vguiLabel);
		lblMapName.SetTitle(mapname);
		lblMapName.SetTextSize(19);
		lblMapName.SetPos('194 105');
		lblMapName.SetSize('250 312');

		lblMapInfo = spawn(vguiLabel);
		lblMapInfo.SetTitle(VGUI_ChooseTeam_MapInfo());
		lblMapInfo.SetPos('194 129');
		lblMapInfo.SetSize('375 250');

		for (int t = 1; t <= teams.TeamCount() ; t++) {
			VGUITeamSelectButton btnForTeam;
			string team_name = teams.Name(t);

			btnForTeam = spawn(VGUITeamSelectButton);
			btnForTeam.SetTitle(strtoupper(team_name));
			btnForTeam.SetPos(btnpos);
			btnForTeam.SetKeyEquivalent(ftos((float)t+1));
			btnForTeam.SetSize('124 24');
			btnForTeam.SetTag(t);

			winChooseTeam.Add(btnForTeam);
			btnpos[1] += 32;
		}

		btnAutoAssign = spawn(VGUITeamSelectButton);
		btnAutoAssign.SetTitle(Titles_GetTextBody("Team_AutoAssign"));
		btnAutoAssign.SetPos(btnpos);
		btnAutoAssign.SetSize('124 24');
		btnAutoAssign.SetKeyEquivalent("5");
		btnAutoAssign.SetTag(0);
		//btnAutoAssign.SetFunc(VGUI_AutoAssign);
		btnpos[1] += 32;

		btnGoSpectator = spawn(VGUITeamSelectButton);
		btnGoSpectator.SetTitle(Titles_GetTextBody("Menu_Spectate"));
		btnGoSpectator.SetPos(btnpos);
		btnGoSpectator.SetSize('124 24');
		btnGoSpectator.SetKeyEquivalent("6");
		btnGoSpectator.SetTag(TEAM_SPECTATOR);
		//btnGoSpectator.SetFunc(VGUI_GoSpectator);

		g_uiDesktop.Add(winChooseTeam);
		winChooseTeam.Add(frmMapInfo);
		winChooseTeam.Add(lblSelectTeam);
		winChooseTeam.Add(lblMapName);
		winChooseTeam.Add(lblMapInfo);
		winChooseTeam.Add(btnAutoAssign);
		winChooseTeam.Add(btnGoSpectator);
	}

	winChooseTeam.Show();
	winChooseTeam.SetPos((g_vidsize / 2) - (winChooseTeam.GetSize() / 2));
}
