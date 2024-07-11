extends SubViewport

@onready var display := $Label

var flashing := 0
var frames := 0
var seconds := 0
var minutes := 0
var format_text : String
var game_running := true

func _ready() -> void:
	pass
	
func _process(_delta: float) -> void:
	if game_running:
		frames += 1
		if frames == 60:
			seconds += 1
			frames = 0
		if seconds == 60:
			minutes += 1
			seconds = 0
	else:
		flashing += 1
		if flashing > 60:
			display.set_visible(true)
			flashing = 0
		elif flashing > 30:
			display.set_visible(false)
		
		
	
	format_text = "        %02d:%02d:%02d"
	
	display.text = format_text % [minutes, seconds, frames]
