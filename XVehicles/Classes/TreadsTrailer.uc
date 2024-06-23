Class TreadsTrailer extends Effects;

var vector PrePivotRel;
var int TreadSkinN;

function Tick(float Delta)
{
	if (Vehicle(Owner) != None)
	{
		if (Mesh == Mesh'SmokeBm')
			Mesh = None;
		if (Mesh == None)
			Owner.MultiSkins[TreadSkinN] = MultiSkins[TreadSkinN];
		if (Vehicle(Owner).GVT != None)
		{
			PrePivot = (PrePivotRel >> Owner.Rotation) + Vehicle(Owner).GVT.PrePivot;
			if (Mesh == None)
				Vehicle(Owner).GVT.MultiSkins[TreadSkinN] = MultiSkins[TreadSkinN];
		}
		else
			PrePivot = (PrePivotRel >> Owner.Rotation);
	}
	else if (Owner == None)
		Destroy();
}

defaultproperties
{
	bNetTemporary=False
	bTrailerSameRotation=True
	bTrailerPrePivot=True
	Physics=PHYS_Trailer
	RemoteRole=ROLE_None
	DrawType=DT_Mesh
}
