extends CharacterBody3D



@onready var head := $Head
@onready var camera := $Head/Camera3D

@onready var power_sfx := $Head/Camera3D/Arm/power_sfx
@onready var channel_sfx := $Head/Camera3D/Arm/channel_sfx
@onready var burunyuu_sfx := $Head/Camera3D/Arm/burunyuu_sfx
@onready var sport_sfx := $Head/Camera3D/Action_Arm/woosh_sfx
@onready var cartoon_sfx := $Head/Camera3D/Action_Arm/pizza_sfx
@onready var build_sfx := $Head/Camera3D/Action_Arm/coil_sfx

@onready var hand_anim := $Head/Camera3D/Arm/AnimationPlayer
@onready var action_anim := $Head/Camera3D/Action_Arm/AnimationPlayer

@onready var buildmap := $"../Map/Build/BuildGrid"
@onready var sportmap := $"../Map/Sport/SportGrid"
@onready var cartoonmap := $"../Map/Cartoon/CartoonGrid"
@onready var plainmap := $"../Map/Plain/PlainGrid"


var speed : float
var gravity : float = 9.8
const SPRINT_SPEED : float = 8.0
const WALK_SPEED : float = 5.0
const JUMP_VELOCITY : float = 7.5
const SENSITIVITY : float = 0.003

#Bobbing
const BOB_FREQ : float = 2.0
const BOB_AMP : float = 0.08
var t_bob : float = 0.0

#FOV
const BASE_FOV : float = 75.0
const FOV_CHANGE : float = 1.5

#Skills
var skilltype : int = 1
var current_anim : String
var current_sfx : AudioStreamPlayer


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	sportmap.set_visible(false)
	sportmap.collision_layer = 2
	cartoonmap.set_visible(false)
	cartoonmap.collision_layer = 2
	buildmap.set_visible(false)
	buildmap.collision_layer = 2
	current_anim = "None"
	current_sfx = build_sfx


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-50), deg_to_rad(80))


func _physics_process(delta: float) -> void:

	# PHYSICS HANDLING / MOVEMENT

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction : Vector3 = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
		
	#Bobbing
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	
	#FOV
	var velocity_clamped : float = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov := BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)


	# INTERACTION HANDLING
	
	if Input.is_action_just_pressed("M1"):
		if !hand_anim.is_playing():
			hand_anim.play("PowerButtonPress")
			burunyuu_sfx.play()
			
	elif Input.is_action_just_pressed("M2"):
		if current_anim != "None":
			if !hand_anim.is_playing():
				action_anim.play(current_anim)
				current_sfx.play()


	if Input.is_action_just_pressed("Ch1"):
		if !hand_anim.is_playing():
			buildmap.set_visible(true)
			buildmap.collision_layer = 1
			sportmap.set_visible(false)
			sportmap.collision_layer = 2
			cartoonmap.set_visible(false)
			cartoonmap.collision_layer = 2
			plainmap.set_visible(false)
			plainmap.collision_layer = 2
			hand_anim.play("ChannelButtonAnimation")
			
			current_anim = "UseTrowel"
			current_sfx = build_sfx
			channel_sfx.play()
		
	if Input.is_action_just_pressed("Ch2"):
		if !hand_anim.is_playing():
			buildmap.set_visible(false)
			buildmap.collision_layer = 2
			sportmap.set_visible(true)
			sportmap.collision_layer = 1
			cartoonmap.set_visible(false)
			cartoonmap.collision_layer = 2
			plainmap.set_visible(false)
			plainmap.collision_layer = 2
			hand_anim.play("ChannelButtonAnimation")
			
			current_anim = "ThrowBaseball"
			current_sfx = sport_sfx
			channel_sfx.play()
		
	if Input.is_action_just_pressed("Ch3"):
		if !hand_anim.is_playing():
			buildmap.set_visible(false)
			buildmap.collision_layer = 2
			sportmap.set_visible(false)
			sportmap.collision_layer = 2
			cartoonmap.set_visible(true)
			cartoonmap.collision_layer = 1
			plainmap.set_visible(false)
			plainmap.collision_layer = 2
			hand_anim.play("ChannelButtonAnimation")
			
			current_anim = "ThrowDynamite"
			current_sfx = cartoon_sfx
			channel_sfx.play()

	move_and_slide()


func _headbob(time: float) -> Vector3:
	var pos := Vector3.ZERO
	pos.y = (sin(time * BOB_FREQ) * BOB_AMP) + 1
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
