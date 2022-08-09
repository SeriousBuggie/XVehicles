//=============================================================================
// WRI.
//=============================================================================
class WRI expands ReplicationInfo;

var class<Weapon> WeaponClass[8];

replication
{
	reliable if( Role==ROLE_Authority)
		WeaponClass;
}

simulated function PreBeginPlay()
{
	local int i;
	local WeaponLocker Locker;
	
	Super.PreBeginPlay();
	
	if( Role == ROLE_Authority)
	{
		Locker = WeaponLocker(Owner);
		if (Locker != None)		
			for (i=0; i<ArrayCount(WeaponClass); i++)
				WeaponClass[i] = Locker.Weapons[i].WeaponClass;
	}
	
	if (Level.NetMode != NM_DedicatedServer)
		SetTimer(1, true);
}

simulated function Timer()
{
	local int i;
	local WeaponLocker Locker;
	local bool bChanged;
	
	Locker = WeaponLocker(Owner);
	if (Locker == None)
		return;
	
	for (i=0; i<ArrayCount(WeaponClass); i++)
		if (Locker.WMesh[i] != None && Locker.WMesh[i].WeaponClass != WeaponClass[i])
		{
			Locker.Weapons[i].WeaponClass = WeaponClass[i];
			bChanged = true;
		}
	if (bChanged)
		Locker.SetPickups();
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
