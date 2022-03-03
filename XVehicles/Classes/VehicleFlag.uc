//=============================================================================
// VehicleFlag.
//=============================================================================
class VehicleFlag expands Effects;

var Decoration MyFlag;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	LoopAnim('newflag');
	FixOffset();
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	
	FixOffset();
}

simulated function FixOffset()
{
	if (Owner != None)
	{
		if (Vehicle(Owner) != None)	
			PrePivot = Vehicle(Owner).GetStateOffset();
		else
			PrePivot.Z = Owner.CollisionHeight;
		PrePivot.Z += 40;
		
		PrePivot = PrePivot >> Owner.Rotation;
		
		if (Vehicle(Owner) != None && Vehicle(Owner).bSlopedPhys && Vehicle(Owner).GVT!=None)
			PrePivot += Vehicle(Owner).GVT.PrePivot;
	}
}

simulated function Tick(float Delta)
{
	local rotator r;
	Super.Tick(Delta);
	
	FixOffset();

	if (Owner != None) {
		SetLocation(Owner.Location);
		r = Owner.Rotation;
		r.Yaw += 32768;
		r.Pitch = -r.Pitch;
		r.Roll = -r.Roll;
		SetRotation(r);
	}
}

function SetFlag(Decoration InFlag)
{
	Local Texture Tex;
	MyFlag = InFlag;
	
	Tex = Texture'JpflagB';
	if (InFlag != None && InFlag.isA('RedFlag'))
		Tex = Texture'JpflagR';
		
	if (Skin != Tex)
		Skin = Tex;
}

defaultproperties
{
      myFlag=None
      bNetTemporary=False
      bTrailerSameRotation=True
      bTrailerPrePivot=True
      RemoteRole=ROLE_SimulatedProxy
      DrawType=DT_Mesh
      Skin=Texture'Botpack.Skins.JpflagB'
      Mesh=LodMesh'Botpack.newflag'
      PrePivot=(Z=70.000000)
}
