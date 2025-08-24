extends Node2D

class_name ProphecyPanel

@onready var card_position_1: Marker2D = $CardContainer/CardPosition1
@onready var card_position_2: Marker2D = $CardContainer/CardPosition2
@onready var card_position_3: Marker2D = $CardContainer/CardPosition3
@onready var card_position_4: Marker2D = $CardContainer/CardPosition4
@onready var card_position_5: Marker2D = $CardContainer/CardPosition5

@onready var card_container: Node2D = $CardContainer

const PROPHECY_CARD = preload("res://scenes/prophecy_panel/prophecy_card.tscn")

const PROPHECY_SIZE: Vector2 = Vector2(0.70, 0.70)

var card_markers: Array[Marker2D]

var cards: Array[CardModel]:
	get:
		return cards
	set(value):
		cards = value

func _ready() -> void:
	card_markers.push_back(card_position_1)
	card_markers.push_back(card_position_2)
	card_markers.push_back(card_position_3)
	card_markers.push_back(card_position_4)
	card_markers.push_back(card_position_5)
	
func set_panel_enabled(enabled: bool):
	visible = enabled
	if visible:
		process_mode = Node.PROCESS_MODE_INHERIT
		for card_model in cards:
			var marker: Marker2D = card_markers[cards.find(card_model)]
			var prophecy_card: ProphecyCard = create_prophecy_card(card_model, card_container, marker.position, PROPHECY_SIZE, true, 0)
			prophecy_card.rotation = marker.rotation
			pass
	else:
		process_mode = Node.PROCESS_MODE_DISABLED

func create_prophecy_card(model: CardModel, parent: Node2D, position: Vector2, scale: Vector2, pickable: bool, z_index: int) -> ProphecyCard:
	var card: ProphecyCard = PROPHECY_CARD.instantiate()	
	card.card_model = model
	card.position = position
	card.scale = scale
	card.input_pickable = pickable
	card.z_index = z_index
	parent.add_child(card)
	return card
