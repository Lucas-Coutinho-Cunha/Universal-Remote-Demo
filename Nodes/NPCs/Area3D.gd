extends Area3D

@onready var flag := $".."
@onready var anims := $"../AnimationPlayer"
var touched := false

func _ready() -> void:
	anims.play("Untouched")

func _on_body_entered(body: CharacterBody3D) -> void:
	if body.name == "Player" and touched == false:
		body.checkpoint = flag.position + Vector3(0, 0.4, 1)
		anims.play("Touched")
		touched = true
		body.checkpoints_taken += 1
