extends Node

@export var parent : CharacterBody3D
@onready var cooldown: Timer = $Cooldown
@onready var player_arms: Node3D = $"../CameraHolder/Camera/Player_Arms"


const BULLET_DECALS = preload("res://Assets/Decals/bullet_decals.tscn")

var current_gun : Gun

func player_ready():
	if parent.name == "PlayerCharacter":
		player_arms.reload.connect(player_reload)

func player_reload():
	current_gun = parent.current_gun
	
	 #ammo var
	var ammo_amt : int = parent.ammo[current_gun.ammo]
	var missing_ammo : int = current_gun.max_mag - parent.current_bullets
	
	match ammo_amt >= current_gun.max_mag:
		true:
			parent.current_bullets = current_gun.max_mag
			parent.ammo[current_gun.ammo] -= missing_ammo
		false:
			parent.current_bullets += parent.ammo[current_gun.ammo]
			parent.ammo[current_gun.ammo] = 0
			
	parent.can_shoot = true
	parent.is_reloading = false
	

func shoot():
	current_gun = parent.current_gun
	
	if parent.can_shoot and parent.current_bullets > 0:
		var valid_bullets : Array[Dictionary] = get_bullet_raycasts()
		
		player_arms.play_gun_anim("recoil")
		
		if current_gun.type != Gun.GunType.MELEE:
			parent.current_bullets = parent.current_bullets - 1
			
		parent.can_shoot = false
		cooldown.start(current_gun.cooldown)
		
		if valid_bullets.is_empty() == false:
			for b in valid_bullets:
				
				var bullet = BULLET_DECALS.instantiate()
				
				#Enemy damage
				if b.hit_target.is_in_group("Enemy"): #check if enemy
					b.hit_target.change_health(current_gun.damage, b.collision_point, b.collision_normal)
					
					b.hit_target.get_node("bulletAnchor").add_child(bullet)

				else:
					get_tree().current_scene.add_child(bullet)



				bullet.global_transform.origin = b.collision_point
				
				#Match decal to normal
				if b.collision_normal == Vector3(0,1,0):
					bullet.look_at(b.collision_point + b.collision_normal, Vector3.RIGHT)
				elif b.collision_normal == Vector3(0,-1,0):
					bullet.look_at(b.collision_point + b.collision_normal, Vector3.RIGHT)
				else:
					bullet.look_at(b.collision_point + b.collision_normal, Vector3.DOWN)
				
				
				#Add to decal counting array
				GlobalSettings.spawned_decals.append(bullet)
				
				#Check for Decal amount
				if GlobalSettings.spawned_decals.size() > GlobalSettings.max_decals:
					if is_instance_valid(GlobalSettings.spawned_decals[0]):
						GlobalSettings.spawned_decals[0].queue_free()
						GlobalSettings.spawned_decals.remove_at(0)
					else:
						GlobalSettings.spawned_decals.remove_at(0)

					

					
					
func get_bullet_raycasts():
	current_gun = parent.current_gun
	
	var bullet_raycast = parent.bullet_raycast
	var valid_bullets : Array[Dictionary]
	
	#get bullet spread
	for b in current_gun.bullet_amount:
		var spread_x : float = randf_range(current_gun.spread * -1, current_gun.spread)
		var spread_y : float = randf_range(current_gun.spread * -1, current_gun.spread)
		
		bullet_raycast.target_position = Vector3(spread_x, spread_y,-current_gun.bullet_range)
		
		#get collided data
		bullet_raycast.force_raycast_update()
		var hit_target = bullet_raycast.get_collider()
		var collision_point = bullet_raycast.get_collision_point()
		var collision_normal = bullet_raycast.get_collision_normal()
		
		#if Bullet hit an object, get its data
		if hit_target != null:
			var valid_bullet : Dictionary = {
				"hit_target" : hit_target,
				"collision_point" : collision_point,
				"collision_normal" : collision_normal
			}
			
			#Add valid bullets to array
			valid_bullets.append(valid_bullet)
		
	return valid_bullets
		

func reload():
	current_gun = parent.current_gun
	
	if current_gun.type != Gun.GunType.MELEE:
		#If gun is missing bullets and player has required bullets:
			if parent.current_bullets < current_gun.max_mag:
				parent.can_shoot = false
				parent.is_reloading = true
				
				if parent.ammo[current_gun.ammo] > 0:
					#Play reload animation and sfx
					player_arms.play_gun_anim("reload")
					return



func _on_cooldown_timeout() -> void:
	parent.can_shoot = true
