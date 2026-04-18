@tool # Tool script can run inside the editor.

## This class represents a gun turret.
class_name _GunTurret
extends Node3D

## Step size for [code]export_range()[/code].
const STEP: float = 0.0001

## Turret joint.
@export var turret_joint: Node3D
## Array of barrel joints.
## Index 0 is the gun sight.
@export var barrel_joints: Array[Node3D] = []

## Pitch angular velocity.
@export_range(0.0, TAU, STEP, "or_greater", "suffix:rad/s")
var yaw_speed: float = deg_to_rad(30.0)
## Yaw angular velocity.
@export_range(0.0, TAU, STEP, "or_greater", "suffix:rad/s")
var pitch_speed: float = deg_to_rad(30.0)

## Yaw left limit.
@export_range(-TAU, TAU, STEP, "suffix:rad")
var max_yaw_angle: float = deg_to_rad(180.0)
## Yaw right limit.
@export_range(-TAU, TAU, STEP, "suffix:rad")
var min_yaw_angle: float = deg_to_rad(-180.0)
## Pitch up limit.
@export_range(-TAU, TAU, STEP, "suffix:rad")
var max_pitch_angle: float = deg_to_rad(90.0)
## Pitch down limit.
@export_range(-TAU, TAU, STEP, "suffix:rad")
var min_pitch_angle: float = deg_to_rad(0.0)

## [private] Yaw angle (gun traverse) relative to [code]turret_joint[/code].
var target_yaw_angle: float
## [private] Pitch angle (gun elevation) relative to [code]barrel_joints[0][/code].
var target_pitch_angle: float


func _ready() -> void:
	# Initialise variables.
	target_yaw_angle = turret_joint.rotation.y
	target_pitch_angle = barrel_joints[0].rotation.x
	#pass


func _physics_process(_delta: float) -> void:
	# --- Update Yaw (Gun Traverse) --- #
	if (turret_joint.rotation.y != target_yaw_angle):
		turret_joint.rotation.y = rotate_toward_any(
			turret_joint.rotation.y,
			target_yaw_angle,
			yaw_speed * _delta
		)
	# --- --- #
	
	# --- Update Pitch (Gun Elevation) --- #
	if (barrel_joints[0].rotation.x != target_pitch_angle):
		for barrel_joint: Node3D in barrel_joints:
			barrel_joint.rotation.x = rotate_toward_arc(
				barrel_joint.rotation.x,
				clampf(target_pitch_angle, min_pitch_angle, max_pitch_angle),
				pitch_speed * _delta
			)
	# --- --- #
	#pass


## Resets to default pitch and yaw angles.
func aim_reset() -> void:
	target_pitch_angle = 0.0
	target_yaw_angle = 0.0
	#pass


## Aims the cannon turret and cannon barrels at [param global_point].
## Updates [code]target_yaw_angle[/code] and [code]target_pitch_angle[/code].
func aim_at(global_point: Vector3) -> void:
	# --- Find new yaw angle --- #
	var old_turret_basis: Basis = self.global_basis
	var yaw_vector: Vector3 = (global_point - turret_joint.global_position).slide(old_turret_basis.y) - (turret_joint.global_basis.x * barrel_joints[0].position.x)
	var new_yaw_angle: float
	
	if (yaw_vector.is_zero_approx()):
		new_yaw_angle = turret_joint.rotation.y # Directly above, so no need to yaw.
	else:
		new_yaw_angle = (-old_turret_basis.z).signed_angle_to(yaw_vector, old_turret_basis.y)
	# --- --- #
	
	# --- Find new pitch angle --- #
	# Uses pitch prediction, i.e. assumes the turret has the new yaw angle.
	var new_turret_basis: Basis = old_turret_basis.rotated(old_turret_basis.y, new_yaw_angle).orthonormalized()
	var pitch_vector: Vector3 = (global_point - (turret_joint.global_position + new_turret_basis * barrel_joints[0].position)).slide(new_turret_basis.x)
	var new_pitch_angle: float
	
	if (pitch_vector.is_zero_approx()):
		new_pitch_angle = barrel_joints[0].rotation.x # Directly to the side, so no need to pitch.
	else:
		new_pitch_angle = (-new_turret_basis.z).signed_angle_to(pitch_vector, new_turret_basis.x)
	# --- --- #
	
	# Return results.
	target_yaw_angle = clampf(new_yaw_angle, min_yaw_angle, max_yaw_angle)
	target_pitch_angle = clampf(new_pitch_angle, min_pitch_angle, max_pitch_angle)
	#pass


## Find the new rotation angle linearly.
## Use this if a joint has max angle limit, i.e. [code]-PI != PI[/code].
## See also [method rotate_toward_any].
func rotate_toward_arc(from: float, to: float, amount: float) -> float:
	return move_toward(from, to, amount)
	#pass


## Find the new rotation angle circularly.
## Use this if a joint has no angle limit, i.e. [code]-PI == PI (mod TAU)[/code].
## See also [method rotate_toward_arc].
func rotate_toward_any(from: float, to: float, amount: float) -> float:
	# Map [-PI, PI] to [0, TAU].
	var a: float = fposmod(from + PI, TAU)
	var b: float = fposmod(to + PI, TAU)
	if (a == b):
		return to
	else:
		return fposmod(rotate_toward(a, b, amount), TAU) - PI
	#pass
