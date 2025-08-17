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
