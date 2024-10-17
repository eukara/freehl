class
HLSuit:NSItem
{
	void HLSuit(void);

	virtual void OnUse(entity usingEntity);
};


void
HLSuit::HLSuit(void)
{

}

void
HLSuit::OnUse(entity userEntity)
{
	if (userEntity.gflags & GF_FLASHLIGHT)
		userEntity.gflags &= ~GF_FLASHLIGHT;
	else
		userEntity.gflags |= GF_FLASHLIGHT;
}
