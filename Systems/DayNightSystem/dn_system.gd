extends Node3D


@onready var hud: Control = $"../HUD"

@export var day_length : float = 60.0 # 6 minute 24h cycle
var time_of_day : float = 0.0 # 0.0 to 1.0
var day_counter : int = 1

var enemies_to_spawn := 0
var enemies_spawned := 0
var spawn_interval := 0.0
var spawn_timer := 0.0
var next_spawn_delay := 0.0
const enemy_scene = preload("res://enemies/simple_enemy.tscn")
@onready var player_character: PlayerCharacter = $"../PlayerCharacter"
@onready var tree: Node3D = $"../Tree"
@onready var directional_light_3d: DirectionalLight3D = $DirectionalLight3D
@onready var world_environment: WorldEnvironment = $WorldEnvironment



func _process(delta):
	time_of_day += delta / day_length
	if time_of_day > 1.0:
		time_of_day = 0.0
		day_counter += 1
		hud.new_day(day_counter)
		setup_day_spawn(day_counter)
		update_environment(time_of_day)
		
	# Only spawn during daytime (0.0 - 0.5)
	if time_of_day <= 0.5 and enemies_spawned < enemies_to_spawn:
		spawn_timer += delta
		if spawn_timer >= next_spawn_delay:
			spawn_enemy()
			spawn_timer = 0.0
			next_spawn_delay = randf_range(2.0, 5.0) # Adjust range to your liking
	#sun.rotation_degrees.x = angle

	update_environment(time_of_day)
	
func setup_day_spawn(day: int):
	enemies_to_spawn = 2 + int(day * 1.5)
	enemies_spawned = 0
	spawn_timer = 0.0
	next_spawn_delay = randf_range(1.0, 3.0) # First delay of the day

func spawn_enemy():
	var spawn_point: Vector3 = global_transform.origin
	var enemy = enemy_scene.instantiate()
	enemy.player_character = player_character
	enemy.tree = tree
	enemy.add_to_group("Enemy")
	add_child(enemy)
	enemy.global_transform.origin = spawn_point
	enemies_spawned += 1
	

func update_environment(t: float) -> void:
	# Rotate sun: 0.0 = sunrise, 0.5 = sunset, 1.0 = next sunrise
	var sun_angle = lerp(-90.0, 270.0, t)  # Rises in front, sets behind
	directional_light_3d.rotation_degrees.x = sun_angle - 90.0
