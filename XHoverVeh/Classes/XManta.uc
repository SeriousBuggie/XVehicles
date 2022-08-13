//=============================================================================
// XManta.
//=============================================================================
class XManta expands HoverCraftPhys;

var byte CurrentTeamColor;

simulated function Tick(float delta)
{
	local bool bInside;
	Super.Tick(delta);
	if (CurrentTeamColor != CurrentTeam)
		ChangeColor();
	if (bHeadLightInUse != bDriving)
	{
		bUseVehicleLights = true;
		SwitchVehicleLights();
		bUseVehicleLights = false;
	}
}

simulated function ChangeColor()
{
	CurrentTeamColor = CurrentTeam;
	switch (CurrentTeamColor)
	{
		case 1:
		case 2:
			MultiSkins[0] = Texture'MantaGreen';
			break;
		default: 
			MultiSkins[0] = Texture'MantaYellow';
			break;
	}
}

defaultproperties
{
	MaxHoverSpeed=2500.000000
	VehicleTurnSpeed=16000.000000
	HoveringHeight=160.000000
	JumpingHeight=730.000000
	MaxPushUpDiff=3.000000
	Repulsor(0)=(X=95.000000,Z=-7.000000)
	Repulsor(1)=(X=-10.000000,Y=80.000000,Z=-7.000000)
	Repulsor(2)=(X=-10.000000,Y=-80.000000,Z=-7.000000)
	JumpSound=Sound'XHoverVeh.Manta.HoverBikeJump05'
	DuckSound=Sound'XHoverVeh.Manta.HoverBikeTurbo01'
	bEngDynSndPitch=True
	MinEngPitch=64
	MaxEngPitch=128
	AIRating=6.000000
	WAccelRate=1000.000000
	VehicleName="Manta"
	TranslatorDescription="This is a Manta, press [Fire] or [AltFire] to fire the different firemodes. Use your Strafe keys and Move Forward/Backward keys to strafe/accelerate/deaccelerate. To leave this vehicle, press your [ThrowWeapon] key."
	ExitOffset=(X=0.000000,Y=130.000000)
	BehinViewViewOffset=(X=-500.000000,Y=0.000000,Z=100.000000)
	StartSound=Sound'XHoverVeh.Manta.HoverBikeStart01'
	EndSound=Sound'XHoverVeh.Manta.HoverBikeStop01'
	EngineSound=Sound'XHoverVeh.Manta.HoverBikeEng02'
	DriverWeapon=(WeaponClass=Class'XHoverVeh.MantaGun',WeaponOffset=(X=0.000000))
	WDeAccelRate=1500.000000
	HeadLights(0)=(VLightOffset=(X=85.000000,Y=11.000000,Z=-2.000000),VLightTex=Texture'XHoverVeh.pics.FlashFlare1',VLightScale=0.500000)
	HeadLights(1)=(VLightOffset=(X=85.000000,Y=-11.000000,Z=-2.000000),VLightTex=Texture'XHoverVeh.pics.FlashFlare1',VLightScale=0.500000)
	HeadLightOn=None
	HeadLightOff=None
	DropFlag=DF_All
	DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=50.000000,Y=-25.000000,Z=-7.000000))
	DestroyedExplDmg=70
	ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=6.750000)
	ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=1.750000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=100.000000,Y=80.000000,Z=-5.000000))
	ExplosionGFX(3)=(bHaveThisExplFX=True,ExplSize=1.750000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=-64.000000,Y=80.000000,Z=-5.000000))
	bEnableShield=True
	ShieldLevel=0.650000
	LODBias=1.000000
	Texture=Texture'XHoverVeh.pics.fan1'
	Mesh=LodMesh'XHoverVeh.Manta'
	DrawScale=25.000000
	MultiSkins(1)=Texture'XHoverVeh.pics.fan1'
	MultiSkins(2)=Texture'XHoverVeh.pics.fan1'
	SoundRadius=255
	SoundVolume=255
	CollisionRadius=92.000000
	CollisionHeight=46.000000
}
