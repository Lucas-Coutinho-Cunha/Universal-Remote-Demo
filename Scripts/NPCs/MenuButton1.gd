extends Area3D

@onready var bleep := $MenuBleep

func _on_mouse_entered() -> void:
	bleep.play()
