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
	local int i;
	if (cl == None)
		return;
	cl.Default.bEnableShield = true;
	cl.Default.bProtectAgainst = false;

	cl.Default.ShieldLevel = 0.9;
	
	// ignore list
	cl.Default.ShieldType[i++] = 'InitialDamage'; // on spawn
	cl.Default.ShieldType[i++] = 'BumpWall'; // fall and hit walls
	cl.Default.ShieldType[i++] = 'drowned'; // in water
	cl.Default.ShieldType[i++] = 'FuckedUp'; // kill by killing zone
//	cl.Default.ShieldType[i++] = 'crushed'; // hit by vehicle, but also can be titan rocks, so disabled
	// damage from xvehicles
	cl.Default.ShieldType[i++] = 'KrahtEnergy';
	cl.Default.ShieldType[i++] = 'NaliEnergy';
	cl.Default.ShieldType[i++] = 'TankBlast';
	cl.Default.ShieldType[i++] = 'MegaBurned';
	cl.Default.ShieldType[i++] = 'Energy';
	cl.Default.ShieldType[i++] = 'CybotLaser';
	cl.Default.ShieldType[i++] = 'cutted';
	cl.Default.ShieldType[i++] = 'MantaPlasma';
	cl.Default.ShieldType[i++] = 'RedIonize';
	cl.Default.ShieldType[i++] = 'Ballistic';
	cl.Default.ShieldType[i++] = 'Laser';
}

defaultproperties
{
}
