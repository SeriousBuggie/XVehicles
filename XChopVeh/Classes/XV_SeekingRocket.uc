class XV_SeekingRocket expands UT_SeekingRocket;

var() float AccelRate;
var() float MinAim;

simulated function Timer()
{
	local vector SeekingDir, Delta, HL, HN;
	local float MagnitudeVel;

	if ( InitialDir == vect(0,0,0) )
		InitialDir = Normal(Velocity);
		 
	if ( (Seeking != None) && (Seeking != Instigator) ) 
	{
		SeekingDir = Seeking.Location - Location;
		Delta = Seeking.Velocity*(VSize(SeekingDir) / VSize(Velocity));
		if (Seeking.Trace(HL, HN, Seeking.Location + Delta) != None)
			Delta = (HL - Seeking.Location)*0.9;
		SeekingDir += Delta;
		if (!FastTrace(Location + SeekingDir))
			SeekingDir -= Delta/2;
		SeekingDir = Normal(SeekingDir);
		if ( (SeekingDir Dot InitialDir) > 0 )
		{
			MagnitudeVel = VSize(Velocity);
			SeekingDir = Normal(SeekingDir * 0.7 * MagnitudeVel + Velocity);
			Velocity =  MagnitudeVel * SeekingDir;	
			Acceleration = Normal(Velocity) * AccelRate;	
			SetRotation(rotator(Velocity));
		}
	}
}

simulated function Tick(float delta)
{
	local ut_SpriteSmokePuff b;
	
	Super.Tick(delta);
	if ( bHitWater || (Level.NetMode == NM_DedicatedServer) )
		Return;

	if ( (Level.bHighDetailMode && !Level.bDropDetail) || (FRand() < 0.5) )
	{
		b = Spawn(class'ut_SpriteSmokePuff');
		b.RemoteRole = ROLE_None;
		b.DrawScale *= 4;
	}
}

simulated function PostBeginPlay()
{
	local Vehicle V, Best;
	local float CurAim, BestAim;
	Super.PostBeginPlay();
	
	if (Bot(Instigator) != None)
	{
		// seek the vehicle, not its driver: the pawn has no velocity to lead
		V = GoodTarget(Instigator, Instigator.Enemy);
		if (V == None || !Instigator.FastTrace(V.Location, Instigator.Location))
			V = GoodTarget(Instigator, Instigator.Target);
		if (V != None && Instigator.FastTrace(V.Location, Instigator.Location))
			Seeking = V;
	}
	else
	{
		BestAim = MinAim;
		foreach AllActors(class'Vehicle', V)
			if (IsGoodTarget(Instigator, V))
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

simulated static function bool IsGoodTarget(Pawn Instigator, Actor Other)
{
	return GoodTarget(Instigator, Other) != None;
}

// The enemy flying vehicle Other stands for (the vehicle, its driver, or something riding on it), or None
simulated static function Vehicle GoodTarget(Pawn Instigator, Actor Other)
{
	local Vehicle V;

	if (Other == None)
		return None;
	if (Pawn(Other) != None && DriverWeapon(Pawn(Other).Weapon) != None)
		Other = DriverWeapon(Pawn(Other).Weapon).VehicleOwner;
	V = Vehicle(Other);
	if (V == None && Other != None)
		V = Vehicle(Other.Base);
	if (V == None || !V.bCanFly)
		return None;
	if (Instigator == None || Instigator.PlayerReplicationInfo == None ||
		(Instigator.PlayerReplicationInfo.TeamName != "" &&
		V.CurrentTeam == Instigator.PlayerReplicationInfo.Team))
		return None;
	return V;
}

function BlowUp(vector HitLocation)
{
	HurtRadius(Damage,150.0, MyDamageType, MomentumTransfer, HitLocation );
	MakeNoise(1.0);
}

auto state Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if (Other == Owner || Other == Instigator)
			return;
		
		Super.ProcessTouch(Other, HitLocation);
	}
}

defaultproperties
{
	AccelRate=2000.000000
	MinAim=0.900000
	speed=2000.000000
	MaxSpeed=4000.000000
	Damage=100.000000
	MomentumTransfer=50000
	DrawScale=0.080000
}
