extends Node3D

func _ready() -> void:
	$GPUParticles3D.restart()
	


func _on_timer_timeout() -> void:
	queue_free()
 
