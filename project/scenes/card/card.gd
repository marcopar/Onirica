extends Area2D

class_name Card

@onready var sprite_2d: Sprite2D = $Sprite2D

const FULL_SIZE: Vector2 = Vector2.ONE
const LABYRINTH_SIZE: Vector2 = Vector2(0.60, 0.60)
const DISCARD_SIZE: Vector2 = Vector2(0.50, 0.50)
const LIMBO_SIZE: Vector2 = Vector2(0.50, 0.50)
const DEAD_ZONE: float = 20

var front_texture: Texture2D
var back_texture: Texture2D

var hand_position: int:
	get:
		return hand_position
	set(value):
		hand_position = value
		
var card_model: CardModel:
	get:
		return card_model
	set(value):
		card_model = value

var freezed: bool = false:
	get:
		return freezed
	set(value):
		freezed = value
		
var dragging: bool = false
var drag_start: Vector2 = Vector2.INF

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	front_texture = load(card_model.sprite_name)
	back_texture = load("res://assets/sprites/cards/back.png")
	set_full_size()
	set_back_texture()
	
func set_outline(enabled: bool) -> void:
	##the shader has an instance parameter to enable it or not on the single card
	sprite_2d.set_instance_shader_parameter("enabled", enabled)
	
func _notification(what : int):
	if dragging and what == NOTIFICATION_WM_MOUSE_EXIT:
		abort_dragging()

func _input(event: InputEvent) -> void:
	if dragging and event is InputEventScreenDrag:		
		var drag_event: InputEventScreenDrag = event
		if drag_event.index > 0:
			return
		if not get_viewport_rect().has_point(drag_event.position):
			abort_dragging()
			return
		if not drag_start.is_finite():
			drag_start = drag_event.position
		z_index = Constants.DRAGGING_BASE_Z
		position = drag_event.position
		rotation = 0
		get_viewport().set_input_as_handled()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventScreenTouch:
		get_viewport().set_input_as_handled()
		var touch_event: InputEventScreenTouch = event
		if touch_event.index > 0:
			return
		if dragging and touch_event.pressed:
			return
		dragging = touch_event.pressed and (card_model.can_play or card_model.can_discard) and not freezed
		if(not touch_event.pressed):
			if is_no_movement():
				print("touch ", self)
				abort_dragging()
				return
			for area in get_overlapping_areas():
				if area.is_in_group(Constants.GROUP_LABYRINTH) and card_model.can_play:
					#can't play the same type of an existing card already in the labyrinth
					if GameManager.labyrinth.size() == 0 or card_model.type != GameManager.labyrinth[GameManager.labyrinth.size()-1].card_model.type:
						SignalManager.card_added_to_labyrinth.emit(self)
						dragging = false
						return
				elif area.is_in_group(Constants.GROUP_DISCARD) and card_model.can_discard:
					SignalManager.card_added_to_discard.emit(self)
					dragging = false
					return
			abort_dragging()

func is_no_movement() -> bool:
	var delta: Vector2 = drag_start - position
	return (not drag_start.is_finite() or delta.length() < DEAD_ZONE) and not dragging
	
func abort_dragging() -> void:
	dragging = false
	drag_start = Vector2.INF
	SignalManager.card_return_to_hand.emit(self)
	
func set_full_size() -> void:
	scale = FULL_SIZE

func set_labyrinth_size() -> void:
	scale = LABYRINTH_SIZE

func set_discard_size() -> void:
	scale = DISCARD_SIZE
	
func set_limbo_size() -> void:
	scale = LIMBO_SIZE

func set_front_texture():
	sprite_2d.texture = front_texture

func set_back_texture():
	sprite_2d.texture = back_texture
		
func _to_string() -> String:
	return "Card[%s]" % [card_model.sprite_name]
