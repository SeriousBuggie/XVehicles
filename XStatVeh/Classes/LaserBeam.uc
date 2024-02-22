//=============================================================================
// LaserBeam.
//=============================================================================
class LaserBeam expands ShockBeam;

const MoveSize = 135.0;
const NetMul = 10.0;

simulated function Tick( float DeltaTime )
{
	local ShockBeam r;
	local vector HL, HN, End;
	
	Super.Tick(DeltaTime);
	
	if ( Level.NetMode != NM_DedicatedServer && NumPuffs > 0)
	{
		if (Owner != None && Owner.Class != Class)
		{
			End = Location + vector(Rotation)*80000;
			if (Trace(HL, HN, End, Location + MoveAmount/NetMul, true) == None)
				HL = End;
			NumPuffs = VSize(HL - Location)/MoveSize - 1;
		}
		if (NumPuffs > 0)
		{
			r = Spawn(Class,self,,Location + MoveAmount/NetMul);
			if (r != None)
			{
				r.RemoteRole = ROLE_None;
				r.NumPuffs = NumPuffs - 1;
				r.Texture = Texture;
				r.MoveAmount = MoveAmount;
			}
		}
		NumPuffs = 0;
	}
}

simulated function PostBeginPlay()
{
	local rotator R;
	MoveAmount = MoveSize*NetMul*vector(Rotation);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		R = Rotation;
		R.Roll = Rand(65535);
		SetRotation(R);
	}	
}

defaultproperties
{
	NumPuffs=1
	DrawScale=0.160000
}
