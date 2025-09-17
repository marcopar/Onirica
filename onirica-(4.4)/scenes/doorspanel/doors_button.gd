extends Area2D

class_name DoorsButton

const LIGHT_DOOR: float = 1
const DARK_DOOR: float = 0.2

const RED_DOOR = preload("res://assets/sprites/cards/red_door.png")
const GREEN_DOOR = preload("res://assets/sprites/cards/green_door.png")
const BLUE_DOOR = preload("res://assets/sprites/cards/blue_door.png")
const YELLOW_DOOR = preload("res://assets/sprites/cards/yellow_door.png")

const DOOR_TEXTURES: Dictionary[CardManager.CARD_COLOR, Resource] = {
	CardManager.CARD_COLOR.RED: RED_DOOR,
	CardManager.CARD_COLOR.GREEN: GREEN_DOOR,
	CardManager.CARD_COLOR.BLUE: BLUE_DOOR,
	CardManager.CARD_COLOR.YELLOW: YELLOW_DOOR
}

@onready var sprite_2d: Sprite2D = $Sprite2D

var color: CardManager.CARD_COLOR
	
func set_color(color: CardManager.CARD_COLOR) -> void:
	self.color = color
	sprite_2d.texture = DOOR_TEXTURES[color]

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
	if event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event
		if touch_event.index > 0:
			return
		get_viewport().set_input_as_handled()
		if(not touch_event.pressed):
			SignalManager.touch_event.emit(self)
