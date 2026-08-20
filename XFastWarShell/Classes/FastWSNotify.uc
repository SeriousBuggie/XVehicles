//=============================================================================
// FastWSNotify.
//
// Speeds the Redeemer up without replacing the weapon or the projectile class,
// so the mod stays compatible with any Redeemer mod running on the server.
//
// Both paths work on the INSTANCE. This class deliberately no longer writes
// class'WarShell'.default.Speed / MaxSpeed: those are process-global, survive
// level travel, are only ever restored on the server (a bNetTemporary notify
// can not replicate bGameEnded back to a client), and - worst of all - they are
// read as the base speed by Redeemer mods that rebuilt MoveRocket around their
// own `speed` var instead of the stock hardcoded 550 (NewNet / UTPure
// ST_GuidedWarshell does exactly that, up to 1200 with bRedeemerControls).
// Patching the defaults turned the boost into a multiplier of somebody else's
// speed, which is where the uncontrollable "fast Redeemer" match came from.
//
// ActorClass is Botpack.WarShell so the notification covers the unguided shell
// (primary fire) and every GuidedWarShell subclass through IsA:
//   - unguided WarShell: top the instance speed up to the target, once;
//   - GuidedWarShell: attach a FastWSTracker. Speed is not a knob there,
//     MoveRocket renormalises Velocity on every call.
//=============================================================================
class FastWSNotify expands SpawnNotify;

simulated event Actor SpawnNotification(Actor A)
{
	local WarShell W;
	local FastWSTracker T;
	local vector Dir;
	local float Target;

	W = WarShell(A);
	if (Role != ROLE_Authority || W == None)
		return A;

	if (GuidedWarShell(W) != None)
	{
		T = W.Spawn(class'FastWSTracker');
		if (T != None)
			T.MyShell = GuidedWarShell(W);
		return A;
	}

	// Top-up, not a multiplier: a mod shell that is already fast keeps its own
	// speed. Flying.BeginState has run by the time the notification fires, so
	// Velocity already carries the firing direction and has to be rebuilt.
	Target = class'FastWSTracker'.default.TargetSpeed;
	if (W.Speed < Target)
	{
		Dir = Normal(W.Velocity);
		if (Dir == vect(0,0,0))
			Dir = vector(W.Rotation);
		W.Speed = Target;
		if (W.MaxSpeed < W.Speed)
			W.MaxSpeed = W.Speed;
		W.Velocity = W.Speed * Dir;
	}
	return A;
}

defaultproperties
{
	ActorClass=Class'Botpack.WarShell'
	RemoteRole=ROLE_None
}
