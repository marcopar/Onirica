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
		#TODO send signal to enable/disable deck outline if last card canm be discarded

func _ready() -> void:
	SignalManager.swap_prophecy_cards.connect(swap_prophecy_cards)
	SignalManager.prophecy_cards_reset_position.connect(prophecy_cards_reset_position)

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

func reset() -> void:
	for object in card_container.get_children():
		if object is ProphecyCard:
			object.queue_free()
	cards.clear()
		
func create_prophecy_card(model: CardModel, parent: Node2D, pposition: Vector2, pscale: Vector2, pickable: bool, pz_index: int) -> ProphecyCard:
	var card: ProphecyCard = PROPHECY_CARD.instantiate()	
	card.card_model = model
	card.position = pposition
	card.scale = pscale
	card.input_pickable = pickable
	card.z_index = pz_index
	card.add_to_group(Constants.GROUP_PROPHECY_CARDS)
	parent.add_child(card)
	return card
	

func swap_prophecy_cards(card1: ProphecyCard, card2: ProphecyCard) -> void:
	var i1: int = cards.find(card1.card_model)
	var i2: int = cards.find(card2.card_model)
	
	var marker1: Marker2D = card_markers[i1]
	var marker2: Marker2D = card_markers[i2]
	
	card1.position = marker2.position
	card1.rotation = marker2.rotation	
	card2.position = marker1.position
	card2.rotation = marker1.rotation
	
	cards[i1] = card2.card_model
	cards[i2] = card1.card_model
	
	#TODO send signal to enable/disable deck outline if last card can be discarded
	
func prophecy_cards_reset_position(card: ProphecyCard) -> void:
	var i: int = cards.find(card.card_model)	
	var marker: Marker2D = card_markers[i]
	
	card.position = marker.position
	card.rotation = marker.rotation	
