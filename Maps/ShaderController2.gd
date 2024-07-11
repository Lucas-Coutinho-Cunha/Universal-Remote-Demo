extends CanvasLayer

func _ready() -> void:
	set_visible(false)

func _on_player_speed_shader(value : bool) -> void:
	set_visible(value)