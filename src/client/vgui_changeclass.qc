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

static string g_classDescrScout;
static string g_classDescrSniper;
static string g_classDescrSoldier;
static string g_classDescrDemoman;
static string g_classDescrMedic;
static string g_classDescrHWGuy;
static string g_classDescrPyro;
static string g_classDescrSpy;
static string g_classDescrEngineer;
static string g_classDescrRandomPC;

static void
TFCClass_Init(void)
{
	g_classDescrScout = textfile_to_string("classes/short_scout.txt");
	g_classDescrSniper = textfile_to_string("classes/short_sniper.txt");
	g_classDescrSoldier = textfile_to_string("classes/short_soldier.txt");
	g_classDescrDemoman = textfile_to_string("classes/short_demoman.txt");
	g_classDescrMedic = textfile_to_string("classes/short_medic.txt");
	g_classDescrHWGuy = textfile_to_string("classes/short_hwguy.txt");
	g_classDescrPyro = textfile_to_string("classes/short_pyro.txt");
	g_classDescrSpy = textfile_to_string("classes/short_spy.txt");
	g_classDescrEngineer = textfile_to_string("classes/short_engineer.txt");
	g_classDescrRandomPC = textfile_to_string("classes/short_randompc.txt");
}

static vguiWindow winClassSelection;
static vguiPic imgClassPreview;
static vguiLabel lblClassTitle;
static vguiLabel lblClassDescription;
static vguiLabel lblClassCounter;

class VGUIChangeClassButton:vguiButton
{
	void VGUIChangeClassButton(void);

	virtual void OnMouseUp(void);
	virtual void OnMouseEntered(void);
};

void
VGUIChangeClassButton::VGUIChangeClassButton(void)
{
}

void
VGUIChangeClassButton::OnMouseUp(void)
{
	int classSelection = GetTag();
	int teamID = player.GetTeam();
	string classType = teams.ClassForIndex(teamID, classSelection);

	localcmd(sprintf("cmd %s\n", classType));
	winClassSelection.Hide();
}

void
VGUIChangeClassButton::OnMouseEntered(void)
{
	int classSelection = GetTag();
	int teamID = player.GetTeam();
	string teamName = teams.Name(teamID);
	string baseName = teams.ClassForIndex(teamID, classSelection);

	lblClassTitle.SetTitle(baseName);
	imgClassPreview.SetImage(strcat("gfx/classes/", baseName, "_", teamName));
	lblClassDescription.SetTitle(g_classDescrRandomPC);
}

void
VGUI_ChooseClass(int wishTeam)
{
	static int initialized;
	static VGUIChangeClassButton *btns;
	static vguiLabel lblSelectClass;
	static vguiFrame frmClassInfo;

	if (!initialized) {
		vector btnpos = [40,80];
		initialized = TRUE;

		TFCClass_Init();

		winClassSelection = spawn(vguiWindow);
		winClassSelection.SetSize([640, 480]);
		winClassSelection.SetStyleMask(vguiWindowBorderless | vguiWindowFullscreen);

		lblSelectClass = spawn(vguiLabel);
		lblSelectClass.SetTitle(Titles_GetTextBody("Title_SelectYourClass"));
		lblSelectClass.SetTextSize(19);
		lblSelectClass.SetPos([40, 38]);
		lblSelectClass.SetSize([400, 24]);

		frmClassInfo = spawn(vguiFrame);
		frmClassInfo.SetPos([176, 80]);
		frmClassInfo.SetSize([424, 312]);

		imgClassPreview = spawn(vguiPic);
		imgClassPreview.SetPos([190, 90]);

		lblClassTitle = spawn(vguiLabel);
		lblClassTitle.SetPos([338, 90]);
		lblClassTitle.SetTextSize(19);
		lblClassTitle.SetSize([320, 24]);

		lblClassCounter = spawn(vguiLabel);
		lblClassCounter.SetPos([338, 90 + 32]);
		lblClassCounter.SetSize([320, 18]);

		lblClassDescription = spawn(vguiLabel);
		lblClassDescription.SetPos([338, 90 + 32 + 32]);
		lblClassDescription.SetSize([250, 240]);

		g_uiDesktop.Add(winClassSelection);
		winClassSelection.Add(lblSelectClass);
		winClassSelection.Add(frmClassInfo);
		winClassSelection.Add(imgClassPreview);
		winClassSelection.Add(lblClassTitle);
		winClassSelection.Add(lblClassCounter);
		winClassSelection.Add(lblClassDescription);

		int classCount = teams.TotalClasses(wishTeam);
		btns = memalloc(sizeof(VGUIChangeClassButton) * classCount);
		for (int i = 0; i < classCount; i++) {
			btns[i] = spawn(VGUIChangeClassButton);
			btns[i].SetTitle(Titles_GetTextBody(teams.ClassForIndex(wishTeam, i)));
			btns[i].SetSize([124, 24]);
			btns[i].SetPos(btnpos);
			btns[i].SetTag(i);

			if (i == 9) {
				btns[i].SetKeyEquivalent("0");
			} else {
				btns[i].SetKeyEquivalent(ftos((float)i+1));
			}

			winClassSelection.Add(btns[i]);
			btnpos[1] += 32;
		}
	}

	winClassSelection.Show();
	winClassSelection.SetPos((g_vidsize / 2) - (winClassSelection.GetSize() / 2));
}
