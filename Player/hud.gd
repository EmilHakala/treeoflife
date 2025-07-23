extends Control

#HUD Objects
@onready var player_health: ProgressBar = $PlayerHealth
@onready var ammo: Label = $Ammo
@onready var tree_health: ProgressBar = $TreeContainer/TreeHealth
@onready var pointer: TextureRect = $Clock/pointer
@onready var day_label: Label = $DayLabel


#Other variables
var is_fading : bool = false
var fade_timer : float = 0.0
var fade_duration :float = 3.0 # seconds


#Stat Objects
@onready var player_character: PlayerCharacter = $"../PlayerCharacter"
@onready var tree: Node3D = $"../Tree"
@onready var dn_system: Node3D = $"../DnSystem"


func _process(delta: float) -> void:
	
	if is_fading:
		fade_timer += delta
		var t = 1.0 - clamp(fade_timer / fade_duration, 0.0, 1.0)
		day_label.modulate.a = t
		if t <= 0.0:
			day_label.visible = false
			is_fading = false
			
	var t = dn_system.time_of_day # 0.0 to 1.0
	var angle = t * 360.0 # Full day = full rotation

	var mat := pointer.material as ShaderMaterial
	mat.set_shader_parameter("rotation_deg", angle)	
	
func _ready() -> void:
	update_hud()
	new_day(1)

func new_day(day):
	day_label.visible = true
	day_label.text = "Day: " + str(day)
	fade_timer = 0.0
	is_fading = true

func update_hud():
	player_health.value = player_character.health
	tree_health.value = tree.health

	if player_character.current_gun.type == Gun.GunType.MELEE:
		ammo.visible = false
	else:
		ammo.visible = true
	ammo.text = "%s / %s" % [player_character.current_bullets, player_character.ammo[player_character.current_gun.ammo]]
