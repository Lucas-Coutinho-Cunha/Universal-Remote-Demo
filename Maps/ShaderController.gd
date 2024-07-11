extends CanvasLayer

var tween : Tween


func _on_player_rewind_shader(value : bool) -> void:
	tween = create_tween()
	tween.tween_method(set_shader_value, 0.0, 1.0, 0.2).set_ease(Tween.EASE_OUT)
	await tween.finished	
	tween = create_tween()
	tween.tween_method(set_shader_value, 1.0, 0.0, 0.5).set_ease(Tween.EASE_OUT)


func set_shader_value(value: float) -> void:
	$ColorRect.material.set_shader_parameter("progress", value);