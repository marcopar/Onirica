extends Area2D

class_name Deck

@onready var sprite_2d: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event
		if touch_event.index > 0:
			return
		if(not touch_event.pressed):
			print("touch ", self)
		get_viewport().set_input_as_handled()

func set_outline(enabled: bool) -> void:
	##the shader has an instance parameter to enable it or not on the single card
	sprite_2d.set_instance_shader_parameter("enabled", enabled)
