extends Control

class_name DeckCounter

@onready var card_count: Label = $HBoxContainer/CardCount
@onready var nightmare_count: Label = $HBoxContainer/NightmareCount
@onready var dead_end_count: Label = $HBoxContainer/DeadEndCount


func _ready() -> void:
	dead_end_count.visible = GameManager.crossroads_and_dead_ends_on
	SignalManager.new_game.connect(new_game)
	SignalManager.deck_updated.connect(deck_updated)
	
func new_game() -> void:
	update_labels()	
	
func deck_updated() -> void:
	update_labels()
	
func update_labels() -> void:
	card_count.text = "%02d" % GameManager.deck_model.get_number_of_cards()
	nightmare_count.text = "%02d" % GameManager.deck_model.get_number_of(CardManager.CARD_TYPE.NIGHTMARE)
	dead_end_count.text = "%02d" % GameManager.deck_model.get_number_of(CardManager.CARD_TYPE.DEAD_END)
	
