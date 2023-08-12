class JTDXTurret expands JSDXTurret;

//Skinning
#exec TEXTURE IMPORT NAME=JeepTDXHTurretSk FILE=SKINS\JeepTDXHTurretSk.bmp GROUP=Skins LODSET=2

//Sounds
#exec AUDIO IMPORT NAME="JTDXLFire" FILE=SOUNDS\JTDXLFire.wav GROUP="Fire"
#exec AUDIO IMPORT NAME="JTDXLDualFire" FILE=SOUNDS\JTDXLDualFire.wav GROUP="Fire"

function SpawnFireEffects(byte Mode)
{
local vector ROffset;
local LPlasmaFireFX LPl;

	if (PitchPart != None)
	{
		ROffset = WeapSettings[Mode].FireStartOffset;
	
		if (Mode == 0)
		{
			if (bTurnFire)
				ROffset.Y = -ROffset.Y;
			LPl = Spawn(Class'HPlasmaFireFX',PitchPart,,PitchPart.Location + (ROffset >> PitchPart.Rotation));
			LPl.PrePivotRel = ROffSet;
			
		}
		else
		{
			LPl = Spawn(Class'HPlasmaFireFX',PitchPart,,PitchPart.Location + (ROffset >> PitchPart.Rotation));
			LPl.PrePivotRel = ROffSet;
			ROffset.Y = -ROffset.Y;
			LPl = Spawn(Class'HPlasmaFireFX',PitchPart,,PitchPart.Location + (ROffset >> PitchPart.Rotation));
			LPl.PrePivotRel = ROffSet;
		}
	}
}

defaultproperties
{
	TurretPitchActor=Class'JTDXGun'
	WeapSettings(0)=(ProjectileClass=Class'JTDXLPlasma',RefireRate=2.200000,FireAnim1="LeftHeavyFire",FireAnim2="RightHeavyFire",FireSound=Sound'XWheelVeh.Fire.JTDXLFire')
	WeapSettings(1)=(ProjectileClass=Class'JTDXLPlasma',RefireRate=1.000000,FireAnim1="DualHeavyFire",FireSound=Sound'XWheelVeh.Fire.JTDXLDualFire')
	MultiSkins(1)=Texture'XWheelVeh.Skins.JeepTDXHTurretSk'
}
