extends DraggableSprite

class_name ProphecyCard

var front_texture: Texture2D

var card_model: CardModel:
	get:
		return card_model
	set(value):
		card_model = value
		
func _ready() -> void:
	front_texture = load("res://assets/sprites/cards/nightmare.png")

func handle_position_update(drag_event: InputEventScreenDrag) -> void:
	z_index = Constants.DRAGGING_BASE_Z
	global_position.x = drag_event.position.x
	rotation = 0
	
func abort_dragging_action() -> void:
	super.abort_dragging_action()
	z_index = 0
