extends Node3D


@export var day_length : float = 120.0 # In seconds, full day cycle
var time_of_day : float = 0.0 # 0.0 to 1.0

func _process(delta):
	time_of_day += delta / day_length
	if time_of_day > 1.0:
		time_of_day = 0.0

	
	#sun.rotation_degrees.x = angle

	#update_environment(time_of_day)
