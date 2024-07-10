extends SubViewport

@onready var display = $Label
var frames := 0
var seconds := 0
var minutes := 0
var format_text : String

func _ready() -> void:
	pass
	
func _process(_delta: float) -> void:
	frames += 1
	if frames == 60:
		seconds += 1
		frames = 0
	if seconds == 60:
		minutes += 1
		seconds = 0
	
	format_text = "        %02d:%02d:%02d"
	
	display.text = format_text % [minutes, seconds, frames]
