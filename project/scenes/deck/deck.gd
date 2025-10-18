extends Area2D

class_name Deck

@onready var sprite_2d: Sprite2D = $Sprite2D

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event
		if touch_event.index > 0:
			return
		get_viewport().set_input_as_handled()
		if(not touch_event.pressed):
			SignalManager.touch_event.emit(self)

func set_outline(enabled: bool) -> void:
	##the shader has an instance parameter to enable it or not on the single card
	sprite_2d.material.set_shader_parameter("enabled", enabled)
