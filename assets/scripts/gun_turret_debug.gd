@tool # Tool script can run inside the editor.

extends Node3D

## Enable/Disable [code]_physics_process()[/code].
@export var enable_physics_process: bool = true

## Target node.
@export var target_node: Node3D
## Gun turret to debug.
@export var gun_turret: _GunTurret
## Target YZ plane mesh.
@export var targetYZ: Node3D

func _physics_process(_delta: float) -> void:
	if (not enable_physics_process):
		return
	
	if (not (target_node and gun_turret and targetYZ)):
		return
	
	gun_turret.aim_at(target_node.global_position)
	
	targetYZ.rotation.y = gun_turret.target_yaw_angle
	#pass
