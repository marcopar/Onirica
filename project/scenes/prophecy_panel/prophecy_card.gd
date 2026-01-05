extends DraggableSprite

class_name ProphecyCard
@onready var label: TextureRect = $Label

var card_model: CardModel:
	get:
		return card_model
	set(value):
		card_model = value
		
func _ready() -> void:
	super._ready()
	sprite_2d.texture = load(card_model.sprite_name)
	label.texture = Commons.get_colorblid_symbol(card_model.color)
	if label.texture != null:
		match card_model.type:
			CardManager.CARD_TYPE.DOOR:
				label.position.x = sprite_2d.texture.get_width() / 2.0 - label.texture.get_width() / 2.0
				# arbitrary value 3 that works
				label.position.y = sprite_2d.texture.get_height() / 3.0
			_:
				#texture dependant
				label.position.x = -89
				label.position.y = -90

func handle_position_update(drag_event: InputEventScreenDrag) -> void:
	z_index = Constants.DRAGGING_BASE_Z
	global_position.x = drag_event.position.x
	rotation = 0
	
func abort_dragging_action() -> void:
	super.abort_dragging_action()
	z_index = 0
	SignalManager.prophecy_cards_reset_position.emit(self)

func handle_overlapping_areas() -> bool:
	for area in get_overlapping_areas():
		if area.is_in_group(Constants.GROUP_PROPHECY_CARDS):
			self.z_index = 0
			SignalManager.swap_prophecy_cards.emit(self, area)
			return true
	return false
	
func _to_string() -> String:
	return card_model.to_string()
