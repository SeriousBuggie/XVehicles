Class MatOverlayFX extends ShieldBeltEffect;

simulated function Destroyed();

simulated function PostBeginPlay();

simulated function Tick(float DeltaTime)
{
	if( Owner==None || Owner.bDeleteMe )
	{
		Destroy();
		Return;
	}
	Fatness = Owner.Fatness+1;
	bHidden = Owner.bHidden;
	Mesh = Owner.Mesh;
	AnimSequence = Owner.AnimSequence;
	AnimFrame = Owner.AnimFrame;
	PrePivot = Owner.PrePivot;
	DrawScale = Owner.DrawScale;
	bOwnerNoSee = Owner.bOwnerNoSee;
	
	if (Vehicle(Owner) != None && Vehicle(Owner).bSlopedPhys && Vehicle(Owner).GVT!=None)
	{
		PrePivot = Vehicle(Owner).GVT.PrePivot;
		bHidden = false;
	}
}

defaultproperties
{
      RemoteRole=ROLE_None
}
