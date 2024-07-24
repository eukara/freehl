/*
 * Copyright (c) 2024 Marco Cawthorne <marco@icculus.org>
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

class
HLScientist:NSTalkMonster
{
	void HLScientist(void);

	virtual void Respawn(void);
};

void
HLScientist::HLScientist(void)
{

}

void
HLScientist::Respawn(void)
{
	int bodyValue = GetSpawnInt("body");
	super::Respawn();

	if (bodyValue == -1i) {
		SetBody((int)floor(random(1,5)));
		SetSkin(0);

		switch (bodyValue) {
		case 1i:
			m_flPitch = 105;
			netname = "Walter";
			SetBodyInGroup(1, 1);
			break;
		case 2i:
			m_flPitch = 100;
			netname = "Einstein";
			SetBodyInGroup(1, 2);
			break;
		case 3i:
			m_flPitch = 95;
			netname = "Luther";
			SetBodyInGroup(1, 3);
			SetSkin(1);
			break;
		default:
			m_flPitch = 100;
			netname = "Slick";
			SetBodyInGroup(1, 4);
		}
	}
}