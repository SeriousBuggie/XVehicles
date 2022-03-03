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
	DrawScale = Owner.DrawScale;
	bOwnerNoSee = Owner.bOwnerNoSee;
}

defaultproperties
{
      RemoteRole=ROLE_None
}
