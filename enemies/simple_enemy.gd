<<<<<<< HEAD
extends CharacterBody3D

signal collided_with_static_on_layer_5
signal collided_with_player


var target_position: Vector3 = Vector3.ZERO
var visible_target: Node3D = null

var last_static_collision: Object = null
var last_player_collision: Object = null

var pushback_velocity: Vector3 = Vector3.ZERO
var pushback_decay: float = 5.0  # Higher = quicker stop

var speed: float = 5.0
var rotation_speed: float = 5.0

func _physics_process(delta: float) -> void:
	if visible_target:
		target_position = visible_target.global_position

	var direction: Vector3 = global_position.direction_to(target_position)
	var flat_direction = direction
	flat_direction.y = 0

	# Rotate
	if flat_direction.length_squared() > 0.01:
		var target_rotation = atan2(flat_direction.x, flat_direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, rotation_speed * delta)

	# Move
	if global_position.distance_to(target_position) > 0.2:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0


	# Apply pushback to velocity
	velocity += pushback_velocity

	# Smoothly reduce pushback
	pushback_velocity = pushback_velocity.move_toward(Vector3.ZERO, pushback_decay * delta)
	#velocity.y += ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	var collision_count = move_and_slide()
	var collided_this_frame := false

	for i in range(collision_count):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		#print("Collided with: ", collider)  # Debug line
		
		if collider is StaticBody3D:
			var collider_layer = collider.collision_layer
			if (collider_layer & (1 << 4)) != 0:
				collided_this_frame = true

				# Only emit if it's a new collision
				if collider != last_static_collision:
					last_static_collision = collider
					emit_signal("collided_with_static_on_layer_5")
					print("Collided with StaticBody3D on layer 5: ", collider.name)
					
					# Apply a smooth pushback
					var push_direction = -collision.get_normal().normalized()
					pushback_velocity = push_direction * -7.0  # Adjust force (5.0 = strong push)

		# Detect collision with player
		if collider.is_in_group("PlayerCharacter"):  # Assumes your player node is in group 'player'
			if collider != last_player_collision:
				last_player_collision = collider
				emit_signal("collided_with_player")
				print("Collided with Player: ", collider.name)
				# Apply a smooth pushback
				var push_direction = -collision.get_normal().normalized()
				pushback_velocity = push_direction * -7.0  # Adjust force (5.0 = strong push)



	# Reset trackers if no collision this frame
	if not collided_this_frame:
		last_static_collision = null
		last_player_collision = null
=======
extends Node3D


@onready var character_body_3d: CharacterBody3D = $CharacterBody3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D
>>>>>>> parent of e8d881b (enemy functionality)


var target_position: Vector3 = Vector3(0,0,0)

func _on_vision_cone_3d_body_sighted(body: Node3D) -> void:
	print("found body")
	print(str(body))
	target_position = body.global_position


func _physics_process(delta: float) -> void:
	#var target_position: Vector3 = Vector3(0,0,0)
	var speed: float = 5
	
	#Unit vector pointing at the target position from the characters position
	var direction = global_position.direction_to(target_position)
	
	character_body_3d.velocity = direction * speed
	character_body_3d.move_and_slide()


func _on_vision_cone_3d_body_hidden(body: Node3D) -> void:
	pass # Replace with function body.
