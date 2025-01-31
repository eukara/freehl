debugcone
{
	cull none

	{
		rgbGen vertex
		alphaGen vertex
		blendFunc blend
	}
}

// the engine in Half-Life appears to hard-code hiding `TRIGGER`
trigger
{
	surfaceParm nodraw
}

// ... and `AAATRIGGER`
aaatrigger
{
	surfaceParm nodraw
}
