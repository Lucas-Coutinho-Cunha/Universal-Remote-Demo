extends Node3D

var time := 0.0

func _physics_process(_delta: float) -> void:
	time += 0.1
	if time > 360:
		time = 0
	scale.x = (sin(time/2))/2 + 1
	scale.y = (sin(time/2))/2 + 1
	scale.z = (sin(time/2))/2 + 1
	position.y = (cos(time)/4) + 10
