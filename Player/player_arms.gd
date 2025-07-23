extends Node3D


@onready var arms_mesh: MeshInstance3D = $Arms_Mesh
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var muzzle_flash: MeshInstance3D = $Arms_Mesh/MuzzleFlash


func _ready() -> void:
	muzzle_flash.hide()

signal reload

func update_mesh(new_mesh : ArrayMesh, type):
	arms_mesh.mesh = new_mesh
	
	if type == Gun.GunType.PISTOL:
		muzzle_flash.position = Vector3(0.46,3.05,-1.374)
	elif type == Gun.GunType.SHOTGUN:
		muzzle_flash.position = Vector3(0.214,3.026,-1.367)
	elif type == Gun.GunType.MELEE:
		muzzle_flash.position = Vector3(0,0,0)
	


func play_gun_anim(animation_name : String, speed_scale : float = 1):
	
	if animation_name == "recoil":
		muzzle_flash.visible = true
		await get_tree().create_timer(0.05).timeout
		muzzle_flash.visible = false
	
	animation_player.stop()
	
	animation_player.speed_scale = speed_scale
	animation_player.play(animation_name)
	
func reload_finished():
	reload.emit()
