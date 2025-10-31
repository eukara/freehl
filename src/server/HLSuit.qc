class
HLSuit:ncItem
{
	void HLSuit(void);

	virtual void OnUse(entity usingEntity);

	virtual void Spawned(void);
	
	int m_suitType;
	string m_sndFlashOff;
	string m_sndFlashOn;
	string m_sndNVGOn;
	string m_sndNVGOff;
};


void
HLSuit::HLSuit(void)
{
	m_suitType = 0i;
	m_sndFlashOn = "";
	m_sndFlashOff = "";
	m_sndNVGOn = "";
	m_sndNVGOff = "";
}

void
HLSuit::Spawned(void)
{
	super::Spawned();

	m_suitType = GetSpawnInt("suitType");
	m_sndFlashOn = GetSpawnString("snd_flashlightOn");
	m_sndFlashOff = GetSpawnString("snd_flashlightOff");
	m_sndNVGOn = GetSpawnString("snd_nvgOn");
	m_sndNVGOff = GetSpawnString("snd_nvgOff");
}

void
HLSuit::OnUse(entity userEntity)
{
	switch (m_suitType) {
	case 0i:
		if (userEntity.gflags & GF_FLASHLIGHT) {
			userEntity.gflags &= ~GF_FLASHLIGHT;
			StartSoundDef(m_sndFlashOff, CHAN_WEAPON, true);
			EntLog("Flashlight now OFF");
		} else {
			userEntity.gflags |= GF_FLASHLIGHT;
			StartSoundDef(m_sndFlashOn, CHAN_WEAPON, true);
			EntLog("Flashlight now ON");
		}
		break;
	case 1i:
		if (userEntity.gflags & GF_NIGHTVISION) {
			userEntity.gflags &= ~GF_NIGHTVISION;
			StartSoundDef(m_sndNVGOff, CHAN_WEAPON, true);
			EntLog("NVG now OFF");
		} else {
			userEntity.gflags |= GF_NIGHTVISION;
			StartSoundDef(m_sndNVGOn, CHAN_WEAPON, true);
			EntLog("NVG now ON");
		}
		break;
	case 2i:
		if (userEntity.gflags & GF_ZOMBIEVISION) {
			userEntity.gflags &= ~GF_ZOMBIEVISION;
			EntLog("Zombovision now OFF");
		} else {
			userEntity.gflags |= GF_ZOMBIEVISION;
			EntLog("Zombovision now ON");
		}
		break;
	default:
		ncError("Unknown hlSuit type!");
	}
}
