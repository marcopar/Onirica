extends Node2D

@onready var icon: Sprite2D = $Icon
@onready var background: Sprite2D = $Background

@export var texture: Texture2D

var selected: bool = false:
	get:
		return selected
	set(value):		
		selected = value
		if selected:
			background.self_modulate = Color(1,1,0)
		else:
			background.self_modulate = Color(1,1,1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	icon.texture = texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if selected:
				selected = false
			else:
				selected = true
