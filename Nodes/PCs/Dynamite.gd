extends RigidBody3D

@onready var anim := $AnimationPlayer
@onready var sfx := $AudioStreamPlayer
var player : CharacterBody3D

@export var blast_force : float
@export var falloff : float

var blast_direction_vector: Vector3
var blast_vector : Vector3

func _ready() -> void:
	player = get_node("../Player")
	anim.play("Explosion")
	await get_tree().create_timer(1.3).timeout
	queue_free()

func _explode() -> void:
	blast_direction_vector = player.position - self.position
	blast_vector = blast_direction_vector.normalized() * blast_force / pow(blast_direction_vector.length(), falloff)
	print(blast_vector)
	player.velocity += blast_vector
