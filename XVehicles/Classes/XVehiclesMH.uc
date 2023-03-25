//=============================================================================
// XVehiclesMH.
//=============================================================================
class XVehiclesMH expands Mutator;

var class<Actor> DynClass;

event PreBeginPlay()
{
	local Actor A;
	
	Super.PreBeginPlay();
	
	foreach AllActors(Class, A)
		break;
	if (A != self)
		return;
		
	class'XVehiclesHUD'.static.SpawnHUD(self);
	
	SetShield();
}

Function SetShield()
{
	local class<Vehicle> cl;
	local int i, s, total;
	local string str, list;
	
	list = Caps(Level.ConsoleCommand("OBJ CLASSES"));
	total = Len(list);
	i = InStr(list, " VEHICLE ");
	if (i == -1)
	{
		Warn(self @ "There no Vehicle class in list!");
		return;
	}
	while (true)
	{
		while (Asc(Mid(list, i, 1)) <= 32 && i < total)
			i++;
		if (i >= total)
			break;
		s = 0;
		while (Asc(Mid(list, i + s, 1)) > 32 && i + s < total)
			s++;
		str = Mid(list, i, s);
		i += s;
		SetPropertyText("DynClass", "Class'" $ str $ "'");
		cl = Class<vehicle>(DynClass);
		if (cl == None)
			break;
		SetupVehicleClass(cl);
		//log(cl);
	}
	
	class'VehiclesConfig'.default.bHideState = true;
	class'VehiclesConfig'.default.bDisableTeamSpawn = true;
	class'VehiclesConfig'.static.Update(self);
	
	SetPropertyText("DynClass", "Class'JSDXLPlasma'");
	if (Class<Projectile>(DynClass) != None)
		Class<Projectile>(DynClass).Default.Damage = 70;

	SetPropertyText("DynClass", "Class'JTDXLPlasma'");
	if (Class<Projectile>(DynClass) != None)
		Class<Projectile>(DynClass).Default.Damage = 140;
		
	SetPropertyText("DynClass", "Class'TankCBullet'");
	if (Class<xVehiclesProjectile>(DynClass) != None)
	{
		Class<xVehiclesProjectile>(DynClass).Default.Damage = 600;
		Class<xVehiclesProjectile>(DynClass).Default.DamageRadius = 710;
	}
	
	SetPropertyText("DynClass", "Class'TankMGRot'");
	if (Class<WeaponAttachment>(DynClass) != None)
	{
		Class<WeaponAttachment>(DynClass).Default.WeapSettings[0].HitError = 0.001;
		Class<WeaponAttachment>(DynClass).Default.WeapSettings[0].HitDamage = 20;
	}
	
	SetPropertyText("DynClass", "Class'FixBolt'");
	if (Class<Projectile>(DynClass) != None)
		Class<Projectile>(DynClass).Default.Damage = 100;
		
	SetPropertyText("DynClass", "Class'StarterFixBolt'");
	if (Class<Projectile>(DynClass) != None)
		Class<Projectile>(DynClass).Default.Damage = 200;
}

function SetupVehicleClass(Class<vehicle> cl)
{
	if (cl == None)
		return;
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

defaultproperties
{
}
