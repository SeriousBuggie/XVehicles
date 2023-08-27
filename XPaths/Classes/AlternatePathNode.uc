//=============================================================================
// AlternatePathNode.
//=============================================================================
class AlternatePathNode expands AlternatePath;

struct SNextNode {
	var() name Tag;
	var() float Weight;
	var AlternatePath Point;
};

var(AlternatePath) SNextNode NextNode[16];
var int MaxNode;

function PostBeginPlay() {
	local BotSpawnNotify BSN;
	local int i;
	
	Super.PostBeginPlay();
	
	MaxNode = 0;
	for (i = 0; i < ArrayCount(NextNode); i++) {
		if (NextNode[i].Weight < 0)
			NextNode[i].Weight = 0;
		if (NextNode[i].Tag == '')
			NextNode[i].Point = None;
		else
			foreach AllActors(class'AlternatePath', NextNode[i].Point, NextNode[i].Tag)
				if (NextNode[i].Point != self) {
					MaxNode = i + 1;
					break;
				}
	}

	foreach AllActors(class'BotSpawnNotify', BSN)
		break;
	if (BSN == None)
		BSN = Spawn(class'BotSpawnNotify');
}

function CheckNext(Bot Bot) {
	local int i;
	local float Weight, MaxWeight, Goal, CurrentWeight[ArrayCount(NextNode)];
	if (MaxNode > 0 && Bot.MoveTarget == self && Bot.AlternatePath == None) {
		for (i = 0; i < MaxNode; i++) {
			if (NextNode[i].Point == None)
				continue;
			CurrentWeight[i] = NextNode[i].Weight;
			if (AlternatePathNode(NextNode[i].Point) != None)
				CurrentWeight[i] = AlternatePathNode(NextNode[i].Point).AlterWeight(Bot, self, CurrentWeight[i]);				
			MaxWeight += CurrentWeight[i];
		}
		Goal = FRand()*MaxWeight;
		for (i = 0; i < MaxNode; i++) {
			if (NextNode[i].Point == None)
				continue;
			if (Weight <= Goal) {
				Bot.AlternatePath = NextNode[i].Point;
				break;
			}
			Weight += CurrentWeight[i];
		}
	}
}

function float AlterWeight(Bot Bot, AlternatePath Source, float Weight) {
	return Weight;
}

defaultproperties
{
	NextNode(0)=(Weight=1.000000)
	NextNode(1)=(Weight=1.000000)
	NextNode(2)=(Weight=1.000000)
	NextNode(3)=(Weight=1.000000)
	NextNode(4)=(Weight=1.000000)
	NextNode(5)=(Weight=1.000000)
	NextNode(6)=(Weight=1.000000)
	NextNode(7)=(Weight=1.000000)
	NextNode(8)=(Weight=1.000000)
	NextNode(9)=(Weight=1.000000)
	NextNode(10)=(Weight=1.000000)
	NextNode(11)=(Weight=1.000000)
	NextNode(12)=(Weight=1.000000)
	NextNode(13)=(Weight=1.000000)
	NextNode(14)=(Weight=1.000000)
	NextNode(15)=(Weight=1.000000)
	SelectionWeight=0.000000
}
