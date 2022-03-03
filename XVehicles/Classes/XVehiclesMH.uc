//=============================================================================
// XVehiclesMH.
//=============================================================================
class XVehiclesMH expands Mutator;

event PreBeginPlay()
{	
	Super.PreBeginPlay();
	
	SetShield();
}

Function SetShield()
{
	local class<Vehicle> classes[6], cl;
	local int i;
	
	class'VehiclesConfig'.default.bHideState = true;
	class'VehiclesConfig'.default.bDisableTeamSpawn = true;
	
	classes[0] = Class'JeepSDX';
	classes[1] = Class'JeepTDX';
	classes[2] = Class'Kraht';
	classes[3] = Class'Shrali';
	classes[4] = Class'TankGKOne';
	classes[5] = Class'TankML';
	
	for (i = 0; i < ArrayCount(classes); i++)
	{
		cl = classes[i];
		if (cl != None)
		{
			cl.Default.bEnableShield = true;
			cl.Default.bProtectAgainst = true;

			cl.Default.ShieldLevel = 0.9;
			
			cl.Default.ShieldType[0] = 'Decapitated';
			cl.Default.ShieldType[1] = 'shot';
			cl.Default.ShieldType[2] = 'RipperAltDeath';
			cl.Default.ShieldType[3] = 'RocketDeath';
			cl.Default.ShieldType[4] = 'Jolted';
			cl.Default.ShieldType[5] = 'Shredded';
			cl.Default.ShieldType[6] = 'Corroded';
			cl.Default.ShieldType[7] = 'GrenadeDeath';
			cl.Default.ShieldType[8] = 'Mortared';
			cl.Default.ShieldType[9] = 'Burned';
			cl.Default.ShieldType[10] = 'Exploded';
			cl.Default.ShieldType[11] = 'hacked';
			cl.Default.ShieldType[12] = 'stomped';
			cl.Default.ShieldType[13] = 'crushed';
			cl.Default.ShieldType[14] = 'zapped';
			cl.Default.ShieldType[15] = 'stung';
			
			cl.Default.ArmorType[0].ArmorLevel = 0.9;
			cl.Default.ArmorType[0].ProtectionType = 'Frozen';
			
			cl.Default.ArmorType[1].ArmorLevel = 0.9;
			cl.Default.ArmorType[1].ProtectionType = 'RedeemerDeath';			
		}
	}	
	
	Class'JSDXLPlasma'.Default.Damage = 70;
	Class'JTDXLPlasma'.Default.Damage = 140;
}

defaultproperties
{
}
