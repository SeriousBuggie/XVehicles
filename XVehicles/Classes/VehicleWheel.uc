Class VehicleWheel extends VehicleAttachment;

var vector WheelOffset;
var rotator WheelRot;
var byte TurnType;
var bool bMirroredWheel;

defaultproperties
{
      WheelOffset=(X=0.000000,Y=0.000000,Z=0.000000)
      WheelRot=(Pitch=0,Yaw=0,Roll=0)
      TurnType=0
      bMirroredWheel=False
      DrawScale=0.200000
}
