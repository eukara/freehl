//used on the front face of the portal entities.
warpzone
{
	sort portal
	surfaceparm nomarks
	surfaceparm nodlight
}

//used on side+back faces, just to hide them.
nodraw
{
	surfaceparm nomarks
	surfaceparm nodlight
	surfaceparm nodraw
}