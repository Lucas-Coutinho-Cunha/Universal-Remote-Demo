extends Node3D

@onready var arm = $"../Action_Arm"

var dynamite := load("res://Nodes/PCs/Dynamite.tscn")
var instance : RigidBody3D


func _on_player_on_dash() -> void:
	pass # Replace with function body.


func _on_player_on_dynamite_toss() -> void:
	await get_tree().create_timer(0.9).timeout
	instance = dynamite.instantiate()
	instance.position = global_position
	instance.position.y += 0.2
	instance.transform.basis = global_transform.basis
	get_parent().add_child(instance)


func _on_player_on_grapple() -> void:
	pass # Replace with function body.
