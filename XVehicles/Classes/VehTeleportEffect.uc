//=============================================================================
// VehTeleportEffect.
//
// The UT teleport flash sized to a vehicle: the spawner sets DrawScale, and the
// two rings the flash spawns on clients follow it.
//=============================================================================
class VehTeleportEffect expands UTTeleportEffect;

var bool bRingsScaled;

auto state Explode
{
	simulated function Tick(float DeltaTime)
	{
		local float Scale;

		Super.Tick(DeltaTime);
		// the rings appear on the first Tick, at their own default size
		if (bRingsScaled || !bSpawnEffects)
			return;
		bRingsScaled = true;
		Scale = DrawScale/default.DrawScale;
		if (T1 != None)
			T1.DrawScale *= Scale;
		if (T2 != None)
			T2.DrawScale *= Scale;
	}
}
