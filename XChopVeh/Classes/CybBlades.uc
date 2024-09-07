class CybBlades expands RaptorGun;

auto state StartingUp
{
Begin:
	PlaySound(Sound'CybTransformSnd',,12.0,,1200.0);
	PlayAnim('Transform', 5.0);
	Sleep(0.1);
	FinishAnim();
}

function SpawnFireEffects(byte Mode)
{
	local name Anim;
	Super.SpawnFireEffects(Mode);
	
	if (OwnerVehicle == None)
		return;
	if (bTurnFire)
		Anim = 'LeftFire';
	else
		Anim = 'RightFire';
	OwnerVehicle.PlayAnim(Anim, 10.0 - Mode*8);
}

defaultproperties
{
	PitchActorOffset=(X=188.000000,Y=0.000000,Z=-58.000000)
	WeapSettings(0)=(FireStartOffset=(Y=96.000000))
	WeapSettings(1)=(FireStartOffset=(Y=96.000000))
	AnimSequence="Still"
	Texture=Texture'XVehicles.Skins.CybotMetal'
	Mesh=LodMesh'CybHeliBlades'
	DrawScale=8.000000
	PrePivot=(X=0.000000,Y=0.000000,Z=-30.000000)
	SoundRadius=80
	SoundVolume=210
}
