extends CharacterBody3D



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

const GRAPPLE_RAY_MAX := 10

var dynamite := load("res://Nodes/PCs/Dynamite.tscn")
var instance : RigidBody3D

var run_mode := false
var current_direction : Vector3 

@onready var current_level := $".."

func _ready() -> void:
	
	#camera_cast.set_target_position(Vector3(0, -1 * GRAPPLE_RAY_MAX, 0))
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if current_level.name == "Level1":
		aztecmap.set_visible(false)
		aztecmap.collision_layer = 2
		sandboxmap.set_visible(false)
		sandboxmap.collision_layer = 2
		futuremap.set_visible(false)
		futuremap.collision_layer = 2
		current_anim = "None"
	else:
		aztecmap.set_visible(true)
		aztecmap.collision_layer = 1
		sandboxmap.set_visible(false)
		sandboxmap.collision_layer = 2
		futuremap.set_visible(false)
		futuremap.collision_layer = 2
		current_anim = "GrappleUse"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-50), deg_to_rad(80))


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
	
	if Input.is_action_just_pressed("M1"):
		if !hand_anim.is_playing():
			hand_anim.play("PowerButtonPress")
			burunyuu_sfx.play()



	elif Input.is_action_just_pressed("M2"):
		if current_anim != "None":
			if !hand_anim.is_playing():
				action_anim.play(current_anim)
				
				

				# GRAPPLING HOOK

				if aztecmap.collision_layer == 1:
					pass


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





	if Input.is_action_just_pressed("Ch1"):
		if !hand_anim.is_playing():
			aztecmap.set_visible(true)
			aztecmap.collision_layer = 1
			sandboxmap.set_visible(false)
			sandboxmap.collision_layer = 2
			futuremap.set_visible(false)
			futuremap.collision_layer = 2
			plainmap.set_visible(false)
			plainmap.collision_layer = 2
			hand_anim.play("ChannelButtonAnimation")
			
			current_anim = "GrappleUse"
			channel_sfx.play()
			action_anim.play("GrappleLoop")
		
	if Input.is_action_just_pressed("Ch2"):
		if !hand_anim.is_playing():
			aztecmap.set_visible(false)
			aztecmap.collision_layer = 2
			sandboxmap.set_visible(true)
			sandboxmap.collision_layer = 1
			futuremap.set_visible(false)
			futuremap.collision_layer = 2
			plainmap.set_visible(false)
			plainmap.collision_layer = 2
			hand_anim.play("ChannelButtonAnimation")
			
			current_anim = "ThrowDynamite"
			channel_sfx.play()
		
	if Input.is_action_just_pressed("Ch3"):
		if !hand_anim.is_playing():
			aztecmap.set_visible(false)
			aztecmap.collision_layer = 2
			sandboxmap.set_visible(false)
			sandboxmap.collision_layer = 2
			futuremap.set_visible(true)
			futuremap.collision_layer = 1
			plainmap.set_visible(false)
			plainmap.collision_layer = 2
			hand_anim.play("ChannelButtonAnimation")
			
			current_anim = "Pump"
			channel_sfx.play()

	move_and_slide()


func _headbob(time: float) -> Vector3:
	var pos := Vector3.ZERO
	pos.y = (sin(time * BOB_FREQ) * BOB_AMP) + 0.8
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
