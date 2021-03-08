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

/* called every input frame */
void
Game_RunClientCommand(void)
{
	Footsteps_Update();
	Animation_PlayerUpdate();
	PMove_Run();
}

/* custom chat packet */
void
SV_SendChat(entity sender, string msg, entity eEnt, float fType)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, fType == 0 ? EV_CHAT:EV_CHAT_TEAM);
	WriteByte(MSG_MULTICAST, num_for_edict(sender) - 1); 
	WriteByte(MSG_MULTICAST, sender.team); 
	WriteString(MSG_MULTICAST, msg);

	if (eEnt) {
		msg_entity = eEnt;
		multicast([0,0,0], MULTICAST_ONE);
	} else {
		multicast([0,0,0], MULTICAST_ALL);
	}

	localcmd(sprintf("echo [SERVER] %s: %s\n", sender.netname, msg));
}

/* client cmd overrides happen here */
void
Game_ParseClientCommand(string cmd)
{
	tokenize(cmd);

	if (argv(1) == "timeleft") {
		string msg;
		string timestring;
		float timeleft;
		timeleft = cvar("mp_timelimit") - (time / 60);
		timestring = Vox_TimeToString(timeleft);
		msg = sprintf("we have %s minutes remaining", timestring);
		Vox_Singlecast(self, msg);
		return;
	}

	if (argv(0) == "say") {
		SV_SendChat(self, argv(1), world, 0);
		return;
	} else if (argv(0) == "say_team") {
		entity a;
		for (a = world; (a = find(a, ::classname, "player"));) { 
			if (a.team == self.team) {
				SV_SendChat(self, argv(1), a, 1);
			}
		}
		return;
	}

	clientcommand(self, cmd);
}
