extends CharacterBody3D

signal open_menu


@onready var head := $Head
@onready var camera := $Head/Camera3D
@onready var subviewport_cam := $PlayerScreen/SubViewportContainer/SubViewport/Subviewport_cam
@onready var action_arm := $Head/Camera3D/Action_Arm

@onready var power_sfx := $Head/Camera3D/Arm/power_sfx
@onready var channel_sfx := $Head/Camera3D/Arm/channel_sfx
@onready var burunyuu_sfx := $Head/Camera3D/Arm/burunyuu_sfx
@onready var aztec_sfx := $Head/Camera3D/Action_Arm/grapple_sfx
@onready var sandbox_sfx := $Head/Camera3D/Action_Arm/dynamite_sfx
@onready var future_sfx := $Head/Camera3D/Action_Arm/pump_sfx

@onready var hand_anim := $Head/Camera3D/Arm/AnimationPlayer
@onready var action_anim := $Head/Camera3D/Action_Arm/AnimationPlayer

@onready var aztecmap := $"../Map/Aztec/AztecGrid"
@onready var sandboxmap := $"../Map/Sandbox/SandboxGrid"
@onready var futuremap := $"../Map/Future/FutureGrid"
@onready var plainmap := $"../Map/Plain/PlainGrid"

@onready var music_aztec := $MusicAztec
@onready var music_sandbox := $MusicSandbox
@onready var music_future := $MusicFuture

@onready var grapplecast := $Head/Camera3D/Grapplecast
@onready var Xcol := $Xcollision
@onready var Ycol := $Ycollision
@onready var Zcol := $Zcollision

@onready var menu := $PlayerScreen/Options
var menu_state := 0

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

var grappling := false
var hookpoint : Vector3
var hookpoint_get = false



var dynamite := load("res://Nodes/PCs/Dynamite.tscn")
var instance : RigidBody3D

var run_mode := false
var current_direction : Vector3 


func _ready() -> void:
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	aztecmap.set_visible(false)
	aztecmap.collision_layer = 2
	music_aztec.set_volume_db(-80)
	sandboxmap.set_visible(false)
	sandboxmap.collision_layer = 2
	music_sandbox.set_volume_db(-80)
	futuremap.set_visible(false)
	futuremap.collision_layer = 2
	music_future.set_volume_db(-80)
	
	menu.set_visible(false)
	
	action_arm.set_visible(false)
	current_anim = "None"


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))


func _process(_delta: float) -> void:
	subviewport_cam.set_global_transform(camera.get_global_transform())


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
	
	if run_mode == false:
		if is_on_floor():
			if direction:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
			else:
				velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
		else:
			velocity.x = lerp(velocity.x, direction.x * speed * 1.3, delta * 3.0)
			velocity.z = lerp(velocity.z, direction.z * speed * 1.3, delta * 3.0)
			
	else:
		velocity.x = lerp(velocity.x, current_direction.x * speed * 3, delta * 3.0)
		velocity.z = lerp(velocity.z, current_direction.z * speed * 3, delta * 3.0)
		
	#Bobbing
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	
	#FOV
	var velocity_clamped : float = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov := BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)


	# INTERACTION HANDLING
	grapple()
	
	if Input.is_action_just_pressed("M1"):
		if !hand_anim.is_playing():
			hand_anim.play("PowerButtonPress")
			burunyuu_sfx.play()



	elif Input.is_action_just_pressed("M2"):
		if current_anim != "None":
			if !hand_anim.is_playing():
				action_arm.set_visible(true)
				action_anim.play(current_anim)
				
				

				# GRAPPLING HOOK

				if aztecmap.collision_layer == 1:
					if grapplecast.is_colliding():
						if !grappling:
							grappling = true

				# DYNAMITE

				elif sandboxmap.collision_layer == 1:
					await get_tree().create_timer(0.9).timeout
					instance = dynamite.instantiate()
					instance.position = action_arm.global_position
					instance.position.y += 0.2
					instance.transform.basis = action_arm.global_transform.basis
					get_parent().add_child(instance)


				# SUPER DASH

				elif futuremap.collision_layer == 1:
					if run_mode == false:
						future_sfx.play()
						run_mode = true
						current_direction.x = clamp(direction.x, -1, 1) * 2
						current_direction.z = clamp(direction.z, -1, 1) * 2
						
					elif run_mode == true:
						run_mode = false



	if Input.is_action_just_pressed("menu"):
		if menu_state == 0:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			menu.set_visible(true)
			menu_state = 1
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			menu.set_visible(false)
			menu_state = 0



	if Input.is_action_just_pressed("Ch1"):
		if !hand_anim.is_playing():
			aztecmap.set_visible(true)
			aztecmap.collision_layer = 1
			music_aztec.set_volume_db(0)
			sandboxmap.set_visible(false)
			sandboxmap.collision_layer = 2
			music_sandbox.set_volume_db(-80)
			futuremap.set_visible(false)
			futuremap.collision_layer = 2
			music_future.set_volume_db(-80)
			plainmap.set_visible(false)
			plainmap.collision_layer = 2
			hand_anim.play("ChannelButtonAnimation")
			action_arm.set_visible(true)
			
			current_anim = "GrappleUse"
			channel_sfx.play()
			action_anim.play("GrappleLoop")
		
		
		
		
		
	if Input.is_action_just_pressed("Ch2"):
		if !hand_anim.is_playing():
			aztecmap.set_visible(false)
			aztecmap.collision_layer = 2
			music_aztec.set_volume_db(-80)
			sandboxmap.set_visible(true)
			sandboxmap.collision_layer = 1
			music_sandbox.set_volume_db(0)
			futuremap.set_visible(false)
			futuremap.collision_layer = 2
			music_future.set_volume_db(-80)
			plainmap.set_visible(false)
			plainmap.collision_layer = 2
			hand_anim.play("ChannelButtonAnimation")
			action_arm.set_visible(false)
			
			current_anim = "ThrowDynamite"
			channel_sfx.play()
		
		
		
		
		
	if Input.is_action_just_pressed("Ch3"):
		if !hand_anim.is_playing():
			aztecmap.set_visible(false)
			aztecmap.collision_layer = 2
			music_aztec.set_volume_db(-80)
			sandboxmap.set_visible(false)
			sandboxmap.collision_layer = 2
			music_sandbox.set_volume_db(-80)
			futuremap.set_visible(true)
			futuremap.collision_layer = 1
			music_future.set_volume_db(0)
			plainmap.set_visible(false)
			plainmap.collision_layer = 2
			hand_anim.play("ChannelButtonAnimation")
			action_arm.set_visible(false)
			
			current_anim = "Pump"
			channel_sfx.play()


	move_and_slide()



func grapple() -> void:
	if grappling:
		gravity = 0
		if !hookpoint_get:
			hookpoint = grapplecast.get_collision_point() + Vector3(0, 2.25, 0)
			hookpoint_get = true
		if hookpoint.distance_to(transform.origin) > 1:
			print(hookpoint.distance_to(transform.origin))
			if hookpoint_get:
				transform.origin = lerp(transform.origin, hookpoint,  0.05)
		else:
			grappling = false
			hookpoint_get = false
			gravity = 9.8



func _headbob(time: float) -> Vector3:
	var pos := Vector3.ZERO
	pos.y = (sin(time * BOB_FREQ) * BOB_AMP) + 0.8
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

