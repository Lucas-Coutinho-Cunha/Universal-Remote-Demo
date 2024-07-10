extends Area3D

@onready var flag := $".."
@onready var anims := $"../AnimationPlayer"
var touched := false

func _ready() -> void:
	anims.play("Untouched")

func _on_body_entered(body: CharacterBody3D) -> void:
	if body.name == "Player" and touched == false:
		body.checkpoint = flag.position
		body.checkpoint.y += 0.4
		anims.play("Touched")
		touched = true
