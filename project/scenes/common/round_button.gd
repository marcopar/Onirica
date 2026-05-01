extends Node2D

class_name RoundButton

@onready var background: Sprite2D = $Background

@export var selected: bool = false:
	get:
		return selected
	set(value):
		if background == null:
			return
		selected = value
		if selected:
			background.self_modulate = Color(1, 1, 0, 1)
		else:
			background.self_modulate = Color(1, 1, 1, 1)
			
@export var enabled: bool = true:
	get:
		return enabled
	set(value):		
		enabled = value
		if enabled:
			modulate = Color(1, 1, 1, 1)
		else:
			modulate = Color(1, 1, 1, 0.3)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enabled = true

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not enabled:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			if selected:
				selected = false
			else:
				selected = true
