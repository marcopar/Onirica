extends Node2D

class_name DeckCounter

@onready var label: Label = $Label

func _ready() -> void:
	SignalManager.new_game.connect(new_game)
	SignalManager.deck_updated.connect(deck_updated)
	
func new_game() -> void:
	label.text = "%02d" % GameManager.deck_model.get_number_of_cards()
	
func deck_updated() -> void:
	label.text = "%02d" % GameManager.deck_model.get_number_of_cards()
