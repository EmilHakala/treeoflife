extends CharacterBody3D

class_name PlayerCharacter 

@onready var fps_label: Label = $fpsLabel
@onready var player_arms: Node3D = $CameraHolder/Camera/Player_Arms

var health : int = 100

@onready var hud: Control = $"../HUD"


#SystemNodes
@onready var gun: Node = $GunSystem


#GunRaycast
@onready var bullet_raycast: RayCast3D = $CameraHolder/Camera/Bullet_Raycast



#guns
var current_gun : Gun = PISTOL
var can_shoot : bool = true
var is_reloading : bool = false
var current_bullets : int = current_gun.max_mag

const MELEE = preload("res://resources/Guns/melee.tres")
const PISTOL = preload("res://resources/Guns/pistol.tres")
const SHOTGUN = preload("res://resources/Guns/shotgun.tres")

var ammo : Dictionary = {
	"melee" : 1,
	"pistol" : 60,
	"shotgun" : 80
}


@export_group("Movement variables")
var moveSpeed : float
var moveAccel : float
var moveDeccel : float
var desiredMoveSpeed : float 
@export var desiredMoveSpeedCurve : Curve
@export var maxSpeed : float
@export var inAirMoveSpeedCurve : Curve
var inputDirection : Vector2
var moveDirection : Vector3
@export var hitGroundCooldown : float #amount of time the character keep his accumulated speed before losing it (while being on ground)
var hitGroundCooldownRef : float 
@export var bunnyHopDmsIncre : float #bunny hopping desired move speed incrementer
@export var autoBunnyHop : bool = false
var lastFramePosition : Vector3 
var lastFrameVelocity : Vector3
var wasOnFloor : bool
var walkOrRun : String = "WalkState" #keep in memory if play char was walking or running before being in the air
#for crouch visible changes
@export var baseHitboxHeight : float
@export var baseModelHeight : float
@export var heightChangeSpeed : float

@export_group("Crouch variables")
@export var crouchSpeed : float
@export var crouchAccel : float
@export var crouchDeccel : float
@export var continiousCrouch : bool = false #if true, doesn't need to keep crouch button on to crouch
@export var crouchHitboxHeight : float
@export var crouchModelHeight : float

@export_group("Walk variables")
@export var walkSpeed : float
@export var walkAccel : float
@export var walkDeccel : float

@export_group("Run variables")
@export var runSpeed : float
@export var runAccel : float 
@export var runDeccel : float 
@export var continiousRun : bool = false #if true, doesn't need to keep run button on to run

@export_group("Jump variables")
@export var jumpHeight : float
@export var jumpTimeToPeak : float
@export var jumpTimeToFall : float
@onready var jumpVelocity : float = (2.0 * jumpHeight) / jumpTimeToPeak
@export var jumpCooldown : float
var jumpCooldownRef : float 
@export var nbJumpsInAirAllowed : int 
var nbJumpsInAirAllowedRef : int 
var jumpBuffOn : bool = false
var bufferedJump : bool = false
@export var coyoteJumpCooldown : float
var coyoteJumpCooldownRef : float
var coyoteJumpOn : bool = false

@export_group("Gravity variables")
@onready var jumpGravity : float = (-2.0 * jumpHeight) / (jumpTimeToPeak * jumpTimeToPeak)
@onready var fallGravity : float = (-2.0 * jumpHeight) / (jumpTimeToFall * jumpTimeToFall)

@export_group("Keybind variables")
@export var moveForwardAction : String = ""
@export var moveBackwardAction : String = ""
@export var moveLeftAction : String = ""
@export var moveRightAction : String = ""
@export var runAction : String = ""
@export var crouchAction : String = ""
@export var jumpAction : String = ""

#references variables
@onready var camHolder : Node3D = $CameraHolder
@onready var model : MeshInstance3D = $Model
@onready var hitbox : CollisionShape3D = $Hitbox
@onready var stateMachine : Node = $StateMachine
#@onready var hud : CanvasLayer = $HUD
@onready var ceilingCheck : RayCast3D = $Raycasts/CeilingCheck
@onready var floorCheck : RayCast3D = $Raycasts/FloorCheck

func _ready():
	
	gun.player_ready()
	
	#set move variables, and value references
	moveSpeed = walkSpeed
	moveAccel = walkAccel
	moveDeccel = walkDeccel
	
	hitGroundCooldownRef = hitGroundCooldown
	jumpCooldownRef = jumpCooldown
	nbJumpsInAirAllowedRef = nbJumpsInAirAllowed
	coyoteJumpCooldownRef = coyoteJumpCooldown
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reload") and is_reloading == false:
		gun.reload()
		hud.update_hud()
		
	if event.is_action_pressed("slot_1") and is_reloading == false:
		switch_weapon(MELEE) #CHANGE TO DYNAMIC
		
	if event.is_action_pressed("slot_2") and is_reloading == false:
		switch_weapon(PISTOL) #CHANGE TO DYNAMIC
		
	if event.is_action_pressed("slot_3") and is_reloading == false:
		switch_weapon(SHOTGUN) #CHANGE TO DYNAMIC
		
		

func _physics_process(_delta : float):
	modifyPhysicsProperties()
	
	move_and_slide()
	
	#SemiAuto gun
	if Input.is_action_just_pressed("Fire") and current_gun.automatic == false:
		gun.shoot()
		
	hud.update_hud()
		
func modifyPhysicsProperties():
	lastFramePosition = position #get play char position every frame
	lastFrameVelocity = velocity #get play char velocity every frame
	wasOnFloor = !is_on_floor() #check if play char was on floor every frame
	
func gravityApply(delta : float):
	#if play char goes up, apply jump gravity
	#otherwise, apply fall gravity
	if velocity.y >= 0.0: velocity.y += jumpGravity * delta
	elif velocity.y < 0.0: velocity.y += fallGravity * delta

func _process(delta: float) -> void:
	fps_label.text="FPS: " + str(Engine.get_frames_per_second())


func _on_simple_enemy_collided_with_player() -> void:
	health = health - 5
	hud.update_hud()


func switch_weapon(new_weapon : Gun):
	if new_weapon == current_gun:
		return
	
	hud.update_hud()
	
	#Add bullets back to total ammo
	ammo[current_gun.ammo] += current_bullets
	current_bullets = 0
	
	#switch gun resource
	current_gun = new_weapon
	
	player_arms.update_mesh(current_gun.mesh, current_gun.type)
	
	#load bullets to new gun
	match ammo[current_gun.ammo] >= current_gun.max_mag:
		true:
			current_bullets = current_gun.max_mag
			ammo[current_gun.ammo] -= current_gun.max_mag
		false:
			current_bullets += ammo[current_gun.ammo]
			ammo[current_gun.ammo] = 0
	
	
