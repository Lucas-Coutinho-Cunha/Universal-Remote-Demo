extends RigidBody3D

@onready var anim := $AnimationPlayer
@onready var sfx := $AudioStreamPlayer
var kablooey := false
var player_inside := false
var player: CharacterBody3D
var blast_direction: Vector3

func _ready() -> void:
	anim.play("Explosion")
	await get_tree().create_timer(1.3).timeout
	queue_free()

func _explode() -> void:
	kablooey = true

func _process(_delta: float) -> void:
	if player_inside == true and kablooey == true:
		blast_direction = player.position - position
		blast_direction.y = 0.8
		player.velocity = blast_direction * 15

func _on_area_3d_body_entered(body: CharacterBody3D) -> void:
	if body.name == "Player":
		player_inside = true
		player = body

func _on_area_3d_body_exited(body: CharacterBody3D) -> void:
	if body.name == "Player":
		player_inside = false
