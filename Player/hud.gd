extends Control

#HUD Objects
@onready var player_health: ProgressBar = $PlayerHealth
@onready var ammo: Label = $Ammo
@onready var tree_health: ProgressBar = $TreeContainer/TreeHealth

#Stat Objects
@onready var player_character: PlayerCharacter = $"../PlayerCharacter"
@onready var tree: Node3D = $"../Tree"


func _ready() -> void:
	update_hud()


func update_hud():
	player_health.value = player_character.health
	tree_health.value = tree.health

	if player_character.current_gun.type == Gun.GunType.MELEE:
		ammo.visible = false
	else:
		ammo.visible = true
	ammo.text = "%s / %s" % [player_character.current_bullets, player_character.ammo[player_character.current_gun.ammo]]
