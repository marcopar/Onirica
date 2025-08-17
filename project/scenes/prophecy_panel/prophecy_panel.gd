extends Node2D

class_name ProphecyPanel

@onready var card_position_1: Marker2D = $CardPosition1
@onready var card_position_2: Marker2D = $CardPosition2
@onready var card_position_3: Marker2D = $CardPosition3
@onready var card_position_4: Marker2D = $CardPosition4
@onready var card_position_5: Marker2D = $CardPosition5

var card_markers: Array[Marker2D]

var cards: Array[ProphecyCard]:
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
	else:
		process_mode = Node.PROCESS_MODE_DISABLED
