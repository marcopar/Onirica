extends DraggableSprite

class_name Card

const NO_SIZE: Vector2 = Vector2.ZERO
const FULL_SIZE: Vector2 = Vector2.ONE
const LABYRINTH_SIZE: Vector2 = Vector2(0.60, 0.60)
const DISCARD_SIZE: Vector2 = Vector2(0.50, 0.50)
const LIMBO_SIZE: Vector2 = Vector2(0.50, 0.50)

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	front_texture = load(card_model.sprite_name)
	back_texture = load("res://assets/sprites/cards/back.png")
	set_full_size()
	set_back_texture()

func can_drag() -> bool:
	return card_model.can_play or card_model.can_discard
	
func abort_dragging_action() -> void:
	super.abort_dragging_action()
	#this resets the card to its hand position
	SignalManager.card_return_to_hand.emit(self)

func touch_action() -> void:
	SignalManager.touch_event.emit(self)

func handle_overlapping_areas() -> bool:
	for area in get_overlapping_areas():
		if area.is_in_group(Constants.GROUP_LABYRINTH) and card_model.can_play:
			#can't play the same type of an existing card already in the labyrinth last position
			if GameManager.labyrinth.size() == 0 or card_model.type != GameManager.labyrinth[GameManager.labyrinth.size()-1].card_model.type:
				SignalManager.card_added_to_labyrinth.emit(self)
				dragging = false
				return true
		elif area.is_in_group(Constants.GROUP_DISCARD) and card_model.can_discard:
			SignalManager.card_added_to_discard.emit(self, true)
			dragging = false
			return true
	return false

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
