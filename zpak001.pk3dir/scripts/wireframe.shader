// Overriding this material
// so that r_wireframe being
// 2 means that we'll have an overlay
// of triangle lines instead of 
// wall hacks
wireframe
{
	program wireframe
	
	{
if r_wireframe == 1
		nodepthtest
endif
	}
}
