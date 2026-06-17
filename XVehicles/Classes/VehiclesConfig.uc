//=============================================================================
// VehiclesConfig.
//=============================================================================
class VehiclesConfig expands Info Config(XVehicles);

var int Version;
var VehiclesConfig Instance;

var() config bool bHideState;
var() config bool bPulseAltHeal;
var() config bool bDisableTeamSpawn;
var() config bool bDisableFastWarShell;
var() config bool bAllowTranslocator;
var() config bool bDisableFlagAnnouncer;
var() config bool bAllowCameraShakeInVehicle;

struct ReplInfo
{
	var int Version;
	var() config bool bHideState;
	var() config bool bPulseAltHeal;
	var() config bool bDisableTeamSpawn;
	var() config bool bDisableFastWarShell;
	var() config bool bAllowTranslocator;
	var() config bool bDisableFlagAnnouncer;
	var() config bool bAllowCameraShakeInVehicle;
};
var ReplInfo ReplI;

replication
{
	reliable if (Role == ROLE_Authority)
		ReplI;
}

simulated function PostNetBeginPlay()
{
	default.bHideState = ReplI.bHideState;
	default.bPulseAltHeal = ReplI.bPulseAltHeal;
	default.bDisableTeamSpawn = ReplI.bDisableTeamSpawn;
	default.bDisableFastWarShell = ReplI.bDisableFastWarShell;
	default.bAllowTranslocator = ReplI.bAllowTranslocator;
	default.bDisableFlagAnnouncer = ReplI.bDisableFlagAnnouncer;
	default.bAllowCameraShakeInVehicle = ReplI.bAllowCameraShakeInVehicle;
}

function Store()
{
	ReplI.bHideState = default.bHideState;
	ReplI.bPulseAltHeal = default.bPulseAltHeal;
	ReplI.bDisableTeamSpawn = default.bDisableTeamSpawn;
	ReplI.bDisableFastWarShell = default.bDisableFastWarShell;
	ReplI.bAllowTranslocator = default.bAllowTranslocator;
	ReplI.bDisableFlagAnnouncer = default.bDisableFlagAnnouncer;
	ReplI.bAllowCameraShakeInVehicle = default.bAllowCameraShakeInVehicle;
	
	ReplI.Version = ++default.Version;
}

static function Update(Actor Source)
{
	if (default.Instance == None || default.Instance.bDeleteMe || default.Instance.Level != Source.Level)
		default.Instance = Source.Spawn(class'VehiclesConfig');
	default.Instance.Store();
}

static function bool Init(Actor Source, XVehiclesCTF.EPulseForHeal PulseForHeal)
{
	local bool bPulseAltHeal;
	Local PulseGun Pulse;
	local Mutator M;
	local FlagAnnouncer Announcer;
	
	foreach Source.AllActors(class'FlagAnnouncer', Announcer)
		return false;

	if (!class'VehiclesConfig'.default.bDisableFastWarShell)
		Source.Spawn(class'FastWSNotify'); // Fast WarShell
		
	if (!class'VehiclesConfig'.default.bAllowTranslocator && DeathMatchPlus(Source.Level.Game) != None)
		DeathMatchPlus(Source.Level.Game).bUseTranslocator = false;
	
	if (TeamGamePlus(Source.Level.Game) != None)
		Source.Spawn(class'FlagAnnouncer');
		
	class'XVehiclesHUD'.static.SpawnHUD(Source);
	
	if (PulseForHeal == PFH_Yes)
		bPulseAltHeal = true;
	else if (PulseForHeal == PFH_Auto)
	{
		foreach Source.AllActors(class'PulseGun', Pulse)
			if (Pulse.isA('FixGun'))
				break;
		if (Pulse == None) // on map no any Fixgun?
		{
			foreach Source.AllActors(class'Mutator', M)
				if (M.isA('FixGunMutator'))
					break;
			if (M == None) // FixGunMutator not loaded? (able give FixGun on enter to vehicle)
				bPulseAltHeal = true;
		}
	}
	
	class'VehiclesConfig'.default.bPulseAltHeal = bPulseAltHeal;
	class'VehiclesConfig'.static.Update(Source);
	return true;
}

defaultproperties
{
	bPulseAltHeal=True
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
}
