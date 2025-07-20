extends Node3D


@onready var character_body_3d: CharacterBody3D = $CharacterBody3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D


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
