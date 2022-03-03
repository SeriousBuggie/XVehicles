class TankMLProjFX expands xTreadVehEffects;

#exec MESH IMPORT MESH=TankMLProjFX ANIVFILE=MODELS\TankMLProj_a.3d DATAFILE=MODELS\TankMLProj_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=TankMLProjFX STRENGTH=0.75
#exec MESH ORIGIN MESH=TankMLProjFX X=0 Y=0 Z=0 ROLL=32

#exec MESH SEQUENCE MESH=TankMLProjFX SEQ=All STARTFRAME=0 NUMFRAMES=8
#exec MESH SEQUENCE MESH=TankMLProjFX SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TankMLProjFX SEQ=Revolve STARTFRAME=0 NUMFRAMES=8 RATE=8.0
#exec MESH SEQUENCE MESH=TankMLProjFX SEQ=RevolveLoop STARTFRAME=0 NUMFRAMES=7 RATE=7.0

#exec MESHMAP NEW MESHMAP=TankMLProjFX MESH=TankMLProjFX
#exec MESHMAP SCALE MESHMAP=TankMLProjFX X=2.5 Y=0.35 Z=0.7

defaultproperties
{
      bAnimByOwner=True
      bNetTemporary=False
      bTrailerSameRotation=True
      Physics=PHYS_Trailer
      RemoteRole=ROLE_None
      DrawType=DT_Mesh
      Style=STY_Translucent
      Texture=Texture'XVehicles.Misc.TransInvis'
      Mesh=LodMesh'XTreadVeh.TankMLProjFX'
      DrawScale=0.650000
      ScaleGlow=1.500000
      bUnlit=True
      bParticles=True
      bRandomFrame=True
      MultiSkins(0)=Texture'XVehicles.Misc.TransInvis'
      MultiSkins(1)=Texture'XVehicles.Misc.TransInvis'
      MultiSkins(2)=Texture'XVehicles.Misc.TransInvis'
      MultiSkins(3)=Texture'XVehicles.Misc.TransInvis'
      MultiSkins(4)=Texture'XVehicles.Misc.TransInvis'
      MultiSkins(5)=Texture'XVehicles.Misc.TransInvis'
      MultiSkins(6)=Texture'XVehicles.Misc.TransInvis'
      MultiSkins(7)=Texture'XVehicles.Misc.TransInvis'
}
