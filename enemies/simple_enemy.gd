extends CharacterBody3D


@onready var blood_fx_scene: PackedScene = preload("res://enemies/BloodImpact.tscn")

#Collision calls
var player_character: Node = null
var tree: Node = null




var target_position: Vector3 = Vector3.ZERO
var visible_target: Node3D = null

var last_static_collision: Object = null
var last_player_collision: Object = null  # Track last player collided

var pushback_velocity: Vector3 = Vector3.ZERO
var pushback_decay: float = 5.0  # Higher = quicker stop


var health: int = 100
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

	var collision_count = move_and_slide()
	var collided_this_frame := false

	for i in range(collision_count):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		print(collider)

		# Detect collision with static object on layer 5
		if collider is StaticBody3D:
			var collider_layer = collider.collision_layer
			if (collider_layer & (1 << 4)) != 0:
				collided_this_frame = true

				if collider != last_static_collision:
					last_static_collision = collider
					tree._on_simple_enemy_collided_with_static_on_layer_5()
					print("Collided with StaticBody3D on layer 5: ", collider.name)

					# Apply a smooth pushback
					var push_direction = -collision.get_normal().normalized()
					pushback_velocity = push_direction * -7.0

		# Detect collision with player
		if collider.is_in_group("PlayerCharacter"):  # Assumes your player node is in group 'player'
			if collider != last_player_collision:
				last_player_collision = collider
				player_character._on_simple_enemy_collided_with_player()
				print("Collision with Player: ", collider.name)
				var push_direction = -collision.get_normal().normalized()
				pushback_velocity = push_direction * -7.0

	# Reset trackers if no collision this frame
	if not collided_this_frame:
		last_static_collision = null
		last_player_collision = null


func _on_vision_cone_3d_body_sighted(body: Node3D) -> void:
	#print("found body: " + str(body))
	visible_target = body  # Track the player

func _on_vision_cone_3d_body_hidden(body: Node3D) -> void:
	if body == visible_target:
		visible_target = null
		target_position = Vector3.ZERO  # Go back to idle/home position
		
func change_health(damage: int, hit_position: Vector3, hit_normal: Vector3) -> void:
	show_hit_effect(hit_position, hit_normal)
	health = health-damage
	if health <= 0:
		queue_free()

func show_hit_effect(hit_position: Vector3, hit_normal: Vector3) -> void:
	var blood_fx = blood_fx_scene.instantiate()
	blood_fx.global_transform.origin = hit_position
	
	blood_fx.look_at(hit_position + hit_normal, Vector3.UP)
	get_tree().current_scene.add_child(blood_fx)
