//=============================================================================
// XVehiclesSummon.
//=============================================================================
class XVehiclesSummon expands Mutator;

event PreBeginPlay()
{
	local Actor A;
	
	Super.PreBeginPlay();
	
	foreach AllActors(Class, A)
		break;
	if (A != self)
		return;
		
	Level.Game.BaseMutator.AddMutator(self);
	
	class'XVehiclesHUD'.static.SpawnHUD(self);
}

function Mutate(string MutateString, PlayerPawn Sender)
{
	local string V;
	local class<actor> NewClass;
	
	if (MutateString ~= "veh 1") V = "XWheelVeh.JeepSDX";
	if (MutateString ~= "veh 2") V = "XWheelVeh.JeepTDX";
	if (MutateString ~= "veh 3") V = "XTreadVeh.Kraht";
	if (MutateString ~= "veh 4") V = "XTreadVeh.TankGKOne";
	if (MutateString ~= "veh 5") V = "XTreadVeh.TankML";
	if (MutateString ~= "veh 6") V = "XTreadVeh.Shrali";
	if (MutateString ~= "veh 7") V = "XChopVeh.CybotHelico";
	if (MutateString ~= "veh 8") V = "XStatVeh.MinigunTurret";
	if (MutateString ~= "veh 9") V = "XStatVeh.EnergyTurret";
	if (MutateString ~= "veh 0") V = "XHoverVeh.XManta";
	if (MutateString ~= "veh 10") V = "XChopVeh.Raptor";
	if (MutateString ~= "veh 11") V = "XXMP.Grinder";
	if (MutateString ~= "veh 12") V = "XTreadVeh.Goliath";
	if (MutateString ~= "veh 13") V = "XXMP.Juggernaut";
	
	if (V != "")
	{
		NewClass = class<actor>( DynamicLoadObject( V, class'Class' ) );
		if( NewClass!=None )
			Sender.Spawn(NewClass);
	}
	
	Super.Mutate(MutateString, Sender);
}

defaultproperties
{
}
