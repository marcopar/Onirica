extends Node2D

class_name IncantationPanel

@onready var card_position_1: Marker2D = $CardContainer/CardPosition1
@onready var card_position_2: Marker2D = $CardContainer/CardPosition2
@onready var card_position_3: Marker2D = $CardContainer/CardPosition3
@onready var card_position_4: Marker2D = $CardContainer/CardPosition4
@onready var card_position_5: Marker2D = $CardContainer/CardPosition5

@onready var card_container: Node2D = $CardContainer

const PANEL_CARD = preload("res://scenes/common/panel_card.tscn")

const PROPHECY_SIZE: Vector2 = Vector2(0.70, 0.70)

var card_markers: Array[Marker2D]

var card_models: Array[CardModel]:
	get:
		return card_models
	set(value):
		card_models = value
		if card_models[4] == null:
			#no cards for the prophecy
			SignalManager.deck_outline_enabled.emit(false)
		else:
			SignalManager.deck_outline_enabled.emit(true)

var panel_cards: Array[PanelCard]:
	get:
		return panel_cards
		
func _ready() -> void:
	SignalManager.swap_incantation_cards.connect(swap_incantation_cards)
	SignalManager.incantation_cards_reset_position.connect(incantation_cards_reset_position)

	card_markers.push_back(card_position_1)
	card_markers.push_back(card_position_2)
	card_markers.push_back(card_position_3)
	card_markers.push_back(card_position_4)
	card_markers.push_back(card_position_5)
	
func set_panel_enabled(enabled: bool) -> void:
	visible = enabled
	if visible:
		process_mode = Node.PROCESS_MODE_INHERIT
		for card_model in card_models:
			if card_model == null:
				#skip empty slots (less than 5 cards prophecy)
				panel_cards.push_back(null)
				continue
			var marker: Marker2D = card_markers[card_models.find(card_model)]
			var panel_card: PanelCard = create_incantation_card(card_model, card_container, marker.position, PROPHECY_SIZE, true, 0)
			panel_card.rotation = marker.rotation
			panel_cards.push_back(panel_card)
			pass
	else:
		process_mode = Node.PROCESS_MODE_DISABLED

func reset() -> void:
	for object in card_container.get_children():
		if object is PanelCard:
			object.queue_free()
	card_models.clear()
	panel_cards.clear()
		
func create_incantation_card(model: CardModel, parent: Node2D, pposition: Vector2, pscale: Vector2, pickable: bool, pz_index: int) -> PanelCard:
	var card: PanelCard = PANEL_CARD.instantiate()	
	card.card_model = model
	card.position = pposition
	card.scale = pscale
	card.input_pickable = pickable
	card.z_index = pz_index
	card.add_to_group(Constants.GROUP_INCANTATION_CARDS)
	parent.add_child(card)
	return card
	

func swap_incantation_cards(card1: PanelCard, card2: PanelCard) -> void:
	var i1: int = card_models.find(card1.card_model)
	var i2: int = card_models.find(card2.card_model)
	var marker1: Marker2D = card_markers[i1]
	var marker2: Marker2D = card_markers[i2]
	
	card1.position = marker2.position
	card1.rotation = marker2.rotation	
	card2.position = marker1.position
	card2.rotation = marker1.rotation
	
	card_models[i1] = card2.card_model
	card_models[i2] = card1.card_model
	
	var panel_card: PanelCard = panel_cards[i1]
	panel_cards[i1] = panel_cards[i2]
	panel_cards[i2] = panel_card

	
func incantation_cards_reset_position(card: PanelCard) -> void:
	var i: int = card_models.find(card.card_model)	
	var marker: Marker2D = card_markers[i]
	
	card.position = marker.position
	card.rotation = marker.rotation	
