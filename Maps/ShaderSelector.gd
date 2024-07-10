extends ColorRect

@export var shader_materials: Array[Material]

func _ready() -> void:
	self.material = shader_materials[0]

func select_shader(index : int) -> void:
	self.material = shader_materials[index]