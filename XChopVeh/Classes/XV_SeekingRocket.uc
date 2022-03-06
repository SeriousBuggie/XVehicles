class XV_SeekingRocket expands UT_SeekingRocket;

var() float AccelRate;
var() float MinAim;

simulated function Timer()
{
	local ut_SpriteSmokePuff b;
	local vector SeekingDir;
	local float MagnitudeVel;

	if ( InitialDir == vect(0,0,0) )
		InitialDir = Normal(Velocity);
		 
	if ( (Seeking != None) && (Seeking != Instigator) ) 
	{
		SeekingDir = Normal(Seeking.Location - Location);
		if ( (SeekingDir Dot InitialDir) > 0 )
		{
			MagnitudeVel = VSize(Velocity);
			SeekingDir = Normal(SeekingDir * 0.7 * MagnitudeVel + Velocity);
			Velocity =  MagnitudeVel * SeekingDir;	
			Acceleration = Normal(Velocity) * AccelRate;	
			SetRotation(rotator(Velocity));
		}
	}
	if ( bHitWater || (Level.NetMode == NM_DedicatedServer) )
		Return;

	if ( (Level.bHighDetailMode && !Level.bDropDetail) || (FRand() < 0.5) )
	{
		b = Spawn(class'ut_SpriteSmokePuff');
		b.RemoteRole = ROLE_None;
	}
}

simulated function PostBeginPlay()
{
	local Vehicle V, Best;
	local float CurAim, BestAim;
	Super.PostBeginPlay();
	
	if (Bot(Instigator) != None)
	{
		if (Instigator.Enemy != None && IsGoodTarget(Instigator.Enemy) && 
			Instigator.FastTrace(Instigator.Enemy.Location, Instigator.Location))
			Seeking = Instigator.Enemy;
	}
	else
	{
		BestAim = MinAim;
		foreach AllActors(class'Vehicle', V)
			if (IsGoodTarget(V))
			{
				CurAim = Normal(V.Location - Location) dot vector(Rotation);
				if (CurAim > BestAim && Instigator.FastTrace(V.Location, Instigator.Location))
				{
					Best = V;
					BestAim = CurAim;
				}
			}
		if (Best != None)
			Seeking = Best;
	}
}

simulated function bool IsGoodTarget(Actor Other)
{
	if (Pawn(Other) != None && DriverWeapon(Pawn(Other).Weapon) != None)
		Other = DriverWeapon(Pawn(Other).Weapon).VehicleOwner;
	if (ChopperPhys(Other) == None && HoverCraftPhys(Other) == None)
		return false;
	if (Instigator == None || Instigator.PlayerReplicationInfo == None || 
		Vehicle(Other).CurrentTeam == Instigator.PlayerReplicationInfo.Team)
		return false;
	return true;
}

defaultproperties
{
      AccelRate=2000.000000
      MinAim=0.900000
      speed=2000.000000
      MaxSpeed=4000.000000
      Damage=150.000000
      DrawScale=0.040000
}
