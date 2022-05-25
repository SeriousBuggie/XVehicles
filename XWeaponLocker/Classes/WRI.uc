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
      WeaponClass(0)=None
      WeaponClass(1)=None
      WeaponClass(2)=None
      WeaponClass(3)=None
      WeaponClass(4)=None
      WeaponClass(5)=None
      WeaponClass(6)=None
      WeaponClass(7)=None
      RemoteRole=ROLE_SimulatedProxy
}
