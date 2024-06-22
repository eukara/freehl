#ifdef SERVER
class
HLGaussBeam:NSProjectile
{
	void HLGaussBeam(void);

	virtual void Launch(vector, vector, float, float, float);
	nonvirtual void GaussAttack(float);
};

void
HLGaussBeam::HLGaussBeam(void)
{
}

void
HLGaussBeam::Launch(vector startPos, vector launchDir, float fuseOffset, float powerMultiplier, float dmgMultiplier)
{
	GaussAttack(fuseOffset);

	if (fuseOffset > 0.0f)
		FX_GaussBeam(startPos, launchDir, 6, owner);
	else
		FX_GaussBeam(startPos, launchDir, 0, owner);

	NSError("fuseOffset: %f", fuseOffset);
}

void
HLGaussBeam::GaussAttack(float fuseOffset)
{
	NSClientPlayer ourOwner = (NSClientPlayer)owner;
	int iLoop = 6i;
	vector vecCurPlane;
	vector vecCurPos;
	vector vecSrc;
	vector vecEndPos;
	vector vecDir;

	vecDir = anglesToForward(ourOwner.GetViewAngle());
	vecSrc = ourOwner.GetEyePos();
	vecEndPos = vecSrc + v_forward * 1024;
	traceline(vecSrc, vecEndPos, FALSE, ourOwner);
	vecCurPlane = trace_plane_normal;
	vecCurPos = trace_endpos;

	int iDamage;

	if (fuseOffset > 0.0) {
		iDamage = (int)rint(lerp(20, 150, fuseOffset / 5.0f));
	} else {
		iDamage = 20i;
	}

	if (serverkeyfloat("*bspversion") == BSPVER_HL)
		if (getsurfacetexture(trace_ent, getsurfacenearpoint(trace_ent, trace_endpos)) == "sky") {
			return;
		}

	if (trace_ent.takedamage == DAMAGE_YES) {
		//Damage_Apply(trace_ent, ourOwner, iDamage, WEAPON_GAUSS, DMG_ELECTRO);
		sound(trace_ent, CHAN_ITEM, sprintf("weapons/electro%d.wav", random(0,3)+4), 1, ATTN_NORM);
	}

	// reflection equation:
	trace_plane_normal = vecCurPlane;
	trace_endpos = vecCurPos;

	while (iLoop > 0i) {
		vector newDir;
		trace_plane_normal = vecCurPlane;
		trace_endpos = vecCurPos;
		newDir = vecDir - 2 * (vecDir * trace_plane_normal) * trace_plane_normal;
		vecDir = newDir;
		vecSrc = trace_endpos + (vecDir * -1);
		vecEndPos = trace_endpos + (vecDir * 8192);
		traceline(vecSrc, vecEndPos, FALSE, ourOwner);
		vecCurPlane = trace_plane_normal;
		vecCurPos = trace_endpos;
		iLoop--;

		if (trace_ent.takedamage == DAMAGE_YES) {
			//Damage_Apply(trace_ent, ourOwner, iDamage, WEAPON_GAUSS, DMG_ELECTRO);
			sound(trace_ent, CHAN_ITEM, sprintf("weapons/electro%d.wav", random(0,3)+4), 1, ATTN_NORM);
		}
	}
}
#endif