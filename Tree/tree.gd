extends Node3D

var health : int = 100

@onready var hud: Control = $"../HUD"


func _on_simple_enemy_collided_with_static_on_layer_5() -> void:
	health = health - 1.0
	hud.update_hud()
	
	if health <= 0:
		get_tree().reload_current_scene()
