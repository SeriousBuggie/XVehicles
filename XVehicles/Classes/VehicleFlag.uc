//=============================================================================
// VehicleFlag.
//=============================================================================
class VehicleFlag expands Effects;

var Decoration MyFlag;
var VehicleFlag Next;
var float LastCheck;
var int Pos;

replication
{
	// Variables the server should send to the client.
	reliable if (Role == ROLE_Authority)
		Pos;
}

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
	local bool bNetOwner;
	local int i;
	local vector X, Y, Z;
	
	Super.Tick(Delta);
	
	FixOffset();

	if (Owner != None) {
		SetLocation(Owner.Location - (vect(10,0,0)*Pos >> Owner.Rotation));
		r = Owner.Rotation;
		if (VSize(Owner.Velocity) > 0)
		{
			GetAxes(Owner.Rotation, X, Y, Z);
			X = Normal(Owner.Velocity - Z*(Z dot Owner.Velocity));
			Y = Z cross X;
			r = OrthoRotation(X, Y, Z);
		}
		r.Yaw += 32768;
		r.Pitch = -r.Pitch;
		r.Roll = -r.Roll;
		SetRotation(r);
	}
	if (Vehicle(Owner) != None && Vehicle(Owner).IsNetOwned())
		Style = STY_Translucent;
	else
		Style = STY_Normal;
}

function Destroyed()
{
	local VehicleFlag Prev;
	if (Vehicle(Owner) != None)
	{
		if (Vehicle(Owner).VehicleFlag == self || Vehicle(Owner).VehicleFlag == None)
			Vehicle(Owner).VehicleFlag = Next;
		else
		{
			for (Prev = Vehicle(Owner).VehicleFlag; Prev != None; Prev = Prev.Next)
				if (Prev.Next == self)
					break;
			if (Prev != None)
				Prev.Next = Next;
		}
	}
	Super.Destroyed();
}

function VehicleFlag SetFlag(Decoration InFlag)
{
	Local Texture Tex;
	MyFlag = InFlag;
	
	Tex = Texture'JpflagB';
	if (MyFlag.Mesh == Mesh'pflag' || MyFlag.Mesh == Mesh)
		Tex = MyFlag.Skin;
	else if (CTFFlag(MyFlag) != None && CTFFlag(MyFlag).Team == 0)
		Tex = Texture'JpflagR';
		
	if (Skin != Tex)
		Skin = Tex;
		
	LastCheck = Level.TimeSeconds;
	return self;
}

defaultproperties
{
	bNetTemporary=False
	bTrailerSameRotation=True
	bTrailerPrePivot=True
	RemoteRole=ROLE_SimulatedProxy
	DrawType=DT_Mesh
	Skin=Texture'Botpack.Skins.JpflagB'
	Mesh=LodMesh'Botpack.newflag'
	PrePivot=(X=0.000000,Y=0.000000,Z=70.000000)
}
