extends Node3D

var time := 0.0

func _physics_process(_delta: float) -> void:
	time += 0.01
	if time > 360:
		time = 0
	rotation.y = time
	position.y = (sin(time)*4) + 2
