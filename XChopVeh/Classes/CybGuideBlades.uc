class CybGuideBlades expands xChopVehAttach;

auto state StartingUp
{
Begin:
	PlaySound(Sound'CybTransformSnd',,12.0,,1200.0);
	PlayAnim('Transform', 5.0);
	Sleep(0.1);
	FinishAnim();
}

defaultproperties
{
	bTrailerSameRotation=True
	Physics=PHYS_Trailer
	AnimSequence="Still"
	Mesh=LodMesh'CybHeliGuideBlades'
	DrawScale=8.000000
	PrePivot=(Z=-30.000000)
}
