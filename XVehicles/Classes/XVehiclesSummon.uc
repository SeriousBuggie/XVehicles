//=============================================================================
// XVehiclesSummon.
//=============================================================================
class XVehiclesSummon expands Mutator;

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
