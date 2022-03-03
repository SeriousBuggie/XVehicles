// if bot drive vehicle, cost for such nodes is high
class WalkPathNode expands PathNode;

event int SpecialCost(Pawn Seeker)
{
	if ( Seeker != None && DriverWeapon(Seeker.Weapon) != None)
		return 100000;
		
	return ExtraCost;
}

defaultproperties
{
      bSpecialCost=True
}
