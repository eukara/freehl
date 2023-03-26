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
	static VGUIButton winMotdClose;
	static VGUIWindow winMotd;
	static VGUILabel winMotdHostname;
	static VGUILabel winMotdBody;
	
	static void VGUI_ShowMOTD_Close(void)
	{
		winMotd.Hide();
	}

	if (MOTD_GetLineCount() < 1i)
		return;

	if (!initialized) {
		initialized = TRUE;
		winMotd = spawn(VGUIWindow);
		winMotd.SetTitle("Message Of The Day");
		winMotd.SetSize('424 312');
		winMotd.SetStyleMask(0);

		winMotdClose = spawn(VGUIButton);
		winMotdClose.SetTitle("OK");
		winMotdClose.SetPos([16, 266]);
		winMotdClose.SetSize([160, 30]);
		winMotdClose.SetFunc(VGUI_ShowMOTD_Close);

		winMotdHostname = spawn(VGUILabel);
		winMotdHostname.SetTitle(serverkey("hostname"));
		winMotdHostname.SetTextSize(19);
		winMotdHostname.SetPos([16, 20]);

		winMotdBody = spawn(VGUILabel);
		winMotdBody.SetTitle(MOTD_GetTextBody());
		winMotdBody.SetPos([16, 48]);
		winMotdBody.SetSize([392, 210]);

		g_uiDesktop.Add(winMotd);
		winMotd.Add(winMotdClose);
		winMotd.Add(winMotdHostname);
		winMotd.Add(winMotdBody);
	}

	winMotd.Show();
	winMotd.SetPos((video_res / 2) - (winMotd.GetSize() / 2));
}
