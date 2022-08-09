class VehWaterAttach expands Effects;

var float WaveSize, WaveLenght;
var ZoneInfo OldWaterZone;

simulated function PostBeginPlay()
{
	if (class'Vehicle'.default.bHaveGroundWaterFX)
		SetTimer(0.1,True);
	else
		SetTimer(0.35,True);
}

simulated function Timer()
{
local VehWaterTrail vwt;
local float LScale;
local rotator RYaw;
 
	if (class'Vehicle'.default.bHaveGroundWaterFX && Vehicle(Owner) != None)
	{

		LScale = WaveSize / 128;

		if (OldWaterZone != None && OldWaterZone.IsA('xZoneInfo') && WaveSize > 0 && 
			(VSize(OldWaterZone.ZoneVelocity) > 150 || (!Vehicle(Owner).bBigVehicle && Abs(WaveLenght) > WaveSize/2) || 
			(Vehicle(Owner).bBigVehicle && Abs(WaveLenght) > WaveSize/6.5)))
		{
			RYaw.Yaw = Owner.Rotation.Yaw;

			if (WaveLenght >= 0)
				vwt = Spawn(Class'VehWaterTrail',,,, RYaw);
			else
				vwt = Spawn(Class'VehWaterTrail',,,, rotator(-vector(RYaw)));
			if (vwt != None)
			{
				vwt.AnimFrame = FMin(FMax(WaveSize, Abs(WaveLenght)) / (2560*LScale),0.5);
				vwt.InitDrawScale = WaveSize / 128;
				vwt.DrawScale = WaveSize / 128;
				if (OldWaterZone.Skin != None)
					vwt.MultiSkins[1] = OldWaterZone.Skin;
			}
		}
//		if (WaveLenght > 0) log(self @ Level.TimeSeconds @ "WaveLenght" @ WaveLenght);

		WaveLenght = 0;
	}
	else if (Vehicle(Owner) != None && Vehicle(Owner).Region.Zone != Region.Zone)
		Vehicle(Owner).AnalyzeZone(Region.Zone);
}

event HitWall(vector HitNormal, actor Wall);

defaultproperties
{
	bHidden=True
	RemoteRole=ROLE_None
	SoundRadius=255
	CollisionRadius=0.500000
	CollisionHeight=0.500000
	bCollideWorld=True
}
