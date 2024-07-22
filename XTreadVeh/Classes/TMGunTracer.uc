class TMGunTracer expands MTracer;

simulated function ProcessTouch(Actor Other, vector HitLocation)
{
	If (Other != Instigator && Other != Owner)
		Destroy();
}

defaultproperties
{
	DrawScale=0.500000
	ScaleGlow=2.000000
}
