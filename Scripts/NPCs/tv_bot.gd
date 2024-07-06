extends Node3D

@onready var start_button := $Node/Hip/Head/Buttons/ButtonStart
@onready var options_button := $Node/Hip/Head/Buttons/ButtonOptions
@onready var exit_button := $Node/Hip/Head/Buttons/ButtonExit
@onready var anim_tree := $AnimationTree


var start_clicked := false
var options_clicked := false
var exit_clicked := false
var timer := 0
var goto : String
#var state_machine := anim_tree.get("parameters/playback")


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	
	anim_tree.set("parameters/conditions/pressed", (start_clicked or options_clicked or exit_clicked))
	
	if goto == "Game":
		timer += 1
		if timer == 60:
			get_tree().change_scene_to_file("res://Maps/world.tscn")
			
	elif goto == "Options":
		timer += 1
		if timer == 60:
			get_tree().quit()
			
	elif goto == "Exit":
		timer += 1
		if timer == 60:
			get_tree().quit()

func _on_start_col_mouse_entered() -> void:
	start_button.set_visible(false)
	options_button.set_visible(true)
	exit_button.set_visible(true)

func _on_options_col_mouse_entered() -> void:
	start_button.set_visible(true)
	options_button.set_visible(false)
	exit_button.set_visible(true)
	
func _on_exit_col_mouse_entered() -> void:
	start_button.set_visible(true)
	options_button.set_visible(true)
	exit_button.set_visible(false)



func _on_start_2_col_mouse_entered() -> void:
	start_button.set_visible(false)
	options_button.set_visible(true)
	exit_button.set_visible(true)

func _on_options_2_col_mouse_entered() -> void:
	start_button.set_visible(true)
	options_button.set_visible(false)
	exit_button.set_visible(true)

func _on_exit_2_col_mouse_entered() -> void:
	start_button.set_visible(true)
	options_button.set_visible(true)
	exit_button.set_visible(false)



func _on_start_2_col_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
			goto = "Game"
			start_clicked = true

func _on_options_2_col_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
			goto = "Options"
			options_clicked = true

func _on_exit_2_col_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
			goto = "Exit"
			exit_clicked = true



