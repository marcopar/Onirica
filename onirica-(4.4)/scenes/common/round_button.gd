extends Node2D

class_name RoundButton

@onready var icon: Sprite2D = $Icon
@onready var background: Sprite2D = $Background

@export var texture: Texture2D

var selected: bool = false:
	get:
		return selected
	set(value):		
		selected = value
		if selected:
			background.self_modulate = Color(1, 1, 0, 1)
		else:
			background.self_modulate = Color(1, 1, 1, 1)
			
var enabled: bool = true:
	get:
		return enabled
	set(value):		
		enabled = value
		if enabled:
			modulate = Color(1, 1, 1, 1)
		else:
			modulate = Color(1, 1, 1, 0.5)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	icon.texture = texture
	enabled = true

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not enabled:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			if selected:
				selected = false
			else:
				selected = true
