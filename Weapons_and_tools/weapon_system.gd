extends Node3D

var recoil_amount := -0.5     # How far back it kicks
var recoil_speed := 15.0     # How fast it kicks back
var recoil_recover := 10.0   # How fast it resets

var recoil_offset := Vector3.ZERO

func _ready() -> void:
	$Muzzleflash.visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_released("Fire"):
		fire_weapon()
	recoil_offset = recoil_offset.lerp(Vector3.ZERO, delta * recoil_recover)
	transform.origin = recoil_offset

	
func fire_weapon():
	recoil_offset = Vector3(
		randf_range(-0.01, 0.01),
		randf_range(-0.01, 0.01),
		-recoil_amount
	)

	var start_position = global_position  # Start at gun muzzle or camera
	var direction = -global_transform.basis.z.normalized()  # Forward direction (assuming -Z is forward)
	var end_position = start_position + direction * 1000.0  # Length of ray
	
	var space_state = get_world_3d().direct_space_state
	
	var query = PhysicsRayQueryParameters3D.create(start_position, end_position)
	query.collide_with_areas = false  # Usually you only want bodies
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	
	if result:
		print("Hit:", result.collider.name)
		# Optional:
		# - result.position → impact point
		# - result.normal → surface normal
		# - result.collider → the object hit
		# Play impact effects, reduce health, etc.
	$Muzzleflash.visible = true
	await get_tree().create_timer(0.05).timeout
	$Muzzleflash.visible = false
