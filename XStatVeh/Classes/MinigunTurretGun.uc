//=============================================================================
// MinigunTurretGun.
//=============================================================================
class MinigunTurretGun expands xStatVehAttach;

auto state StartingUp
{
Begin:
	PlaySound(Sound'CybTransformSnd',,12.0,,1200.0);
	PlayAnim('Transform', 5.0);
	Sleep(0.1);
	FinishAnim();
}

defaultproperties
{
	AnimSequence="Still"
	Texture=Texture'XStatVeh.Skins.CybotMetal'
	Mesh=LodMesh'CybSentinelGun'
	DrawScale=5.000000
	MultiSkins(2)=Texture'XVehicles.Skins.CybotCoreRed'
}
