extends Control

func _ready() -> void:
	$AnimationPlayer.play("RESET")
	hide()

@onready var player_character: PlayerCharacter = $"../.."


func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hide()

func pause():
	show()
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	Input.set_mouse_mode(Input.MouseMode.MOUSE_MODE_VISIBLE)
func testEsc():
	if Input.is_action_just_pressed("ui_cancel") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("ui_cancel") and get_tree().paused:
		resume()


func _on_resume_pressed() -> void:
	resume()


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()


func _process(delta: float) -> void:
	testEsc()


func _on_dev_pressed() -> void:
	if $"../../CameraHolder/Camera/PSXMesh".visible:	
		$"../../fpsLabel".hide()
		$"../../CameraHolder/Camera/PSXMesh".hide()
	else:
		$"../../fpsLabel".show()
		$"../../CameraHolder/Camera/PSXMesh".show()
	
