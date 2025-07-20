extends Node3D

var health : float = 100
@onready var progress_bar: ProgressBar = $"../ProgressBar"

func _on_simple_enemy_collided_with_static_on_layer_5() -> void:
	health = health - 1.0
	progress_bar.value=health
