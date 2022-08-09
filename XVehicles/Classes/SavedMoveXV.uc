//=============================================================================
// SavedMoveXV.
//=============================================================================
class SavedMoveXV expands Info;

// use Velocity, Acceleration (as Location)
var SavedMoveXV NextMove;		// Next move in linked list.
var float TimeStamp;		// Time of this move.
var float Delta;			// Distance moved.
var float Yaw;
var int Rise;
var int Turn;
var int Accel;

// Player attributes after applying this move
var vector SavedLocation;   
var vector SavedVelocity;
var float SavedYaw;

final function Clear()
{
	Velocity = vect(0,0,0);
	Acceleration = vect(0,0,0);
	TimeStamp = 0;
	Delta = 0;
	Yaw = 0;
	Rise = 0;
	Turn = 0;
	Accel = 0;
}

defaultproperties
{
	RemoteRole=ROLE_None
}
