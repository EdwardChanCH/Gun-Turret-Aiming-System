@tool # Tool script can run inside the editor.

extends Node3D

## Enable/Disable [code]_physics_process()[/code].
@export var enable_physics_process: bool = true
## Enable/Disable moving node position update.
@export var enable_moving_node_position: bool = false
## Enable/Disable moving node rotation update.
@export var enable_moving_node_rotation: bool = false

## Target node for the gun turret to aim at.
@export var target_node: Node3D
## Moving node for moving gun turrets.
@export var moving_node: Node3D
## List of gun turrets.
@export var gun_turrets: Array[_GunTurret] = []

var moving_angle: float = 0.0


func _physics_process(_delta: float) -> void:
	# Note: moving_node.scale must be equal to Vector3.ONE !
	
	if (not enable_physics_process):
		return
	
	moving_angle = fposmod(moving_angle + _delta * 0.25, TAU)
	
	if (moving_node):
		if (enable_moving_node_position):
			moving_node.position = Vector3(cos(moving_angle) * 100.0, 0.0, sin(moving_angle) * 100.0)
		
		if (enable_moving_node_rotation):
			moving_node.rotate(Vector3.ONE.normalized(), deg_to_rad(1.0))
	
	for gun_turret in gun_turrets:
		if (not gun_turret):
			continue
		
		if (target_node):
			gun_turret.aim_at(target_node.global_position)
		else:
			gun_turret.aim_reset()
	#pass
