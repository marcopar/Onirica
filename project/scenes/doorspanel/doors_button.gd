extends Area2D

class_name DoorsButton

const LIGHT_DOOR: float = 1
const DARK_DOOR: float = 0.2

@onready var sprite_2d: Sprite2D = $Sprite2D
	
func set_texture(texture: Texture2D) -> void:
	sprite_2d.texture = texture

func set_outline(enabled: bool) -> void:
	##the shader has an instance parameter to enable it or not on the single card
	sprite_2d.set_instance_shader_parameter("enabled", enabled)
	
func set_lighted(enabled: bool) -> void:
	if enabled:
		sprite_2d.self_modulate = Color(LIGHT_DOOR, LIGHT_DOOR, LIGHT_DOOR,1)
	else:
		sprite_2d.self_modulate = Color(DARK_DOOR, DARK_DOOR, DARK_DOOR, 1)
	
func is_lighted() -> bool:
	return sprite_2d.self_modulate.r == LIGHT_DOOR
	
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print("Aaaa")
	if event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event
		if touch_event.index > 0:
			return
		if(not touch_event.pressed):
			print("touch ", viewport)
		get_viewport().set_input_as_handled()
