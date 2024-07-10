extends Control

func _ready():
	set_visible(false)

func _on_player_open_menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	set_visible(true)


func _on_sfx_volume_close_menu():

