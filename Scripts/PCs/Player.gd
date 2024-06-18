extends CharacterBody3D

var speed : float
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

var gravity : float = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var hand_anim = $Head/Camera3D/Arm/AnimationPlayer
@onready var power_sfx = $Head/Camera3D/Arm/power_sfx
@onready var channel_sfx = $Head/Camera3D/Arm/channel_sfx
@onready var burunyuu_sfx = $Head/Camera3D/Arm/burunyuu_sfx

# TEXTURES

var texture_state = 1


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)

		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-50), deg_to_rad(80))


func _physics_process(delta):

	# PHYSICS HANDLING / MOVEMENT

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
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
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)


	# INTERACTION HANDLING
	
	if Input.is_action_just_pressed("M1"):
		if !hand_anim.is_playing():
			hand_anim.play("PowerButtonPress")
			burunyuu_sfx.play()
			
	elif Input.is_action_just_pressed("M2"):
		if !hand_anim.is_playing():
			hand_anim.play("ChannelButtonAnimation")
			channel_sfx.play()
			#Global.channel_state += 1
	
	if Input.is_action_just_pressed("texture"):
		if texture_state < 3:
			texture_state += 1
		else:
			texture_state = 0

	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

