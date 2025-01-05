extends Node

const HAND_SIZE: int = 5

var deck_model: DeckModel:
	get:
		return deck_model
	set(value):
		deck_model = value
		
var game_over: bool:
	get:
		return game_over
	set(value):
		game_over = value
		
var hand: Array[Card]:
	get:
		return hand
	set(value):
		hand = value
		
var labyrinth: Array[Card]:
	get:
		return labyrinth
	set(value):
		labyrinth = value

var limbo: Array[Card]:
	get:
		return limbo
	set(value):
		limbo = value

var discard: Array[Card]:
	get:
		return discard
	set(value):
		discard = value
		
func _ready() -> void:
	SignalManager.card_added_to_discard.connect(card_added_to_discard)
	SignalManager.card_added_to_labyrinth.connect(card_added_to_labyrinth)
	SignalManager.card_added_to_limbo.connect(card_added_to_limbo)

func new_game() -> void:
	deck_model = DeckModel.new()
	deck_model.deck = CardManager.create_base_deck()
	deck_model.shuffle()
	
	for card in hand:
		if card != null:
			card.queue_free()
	hand.clear()	
	#refill hand with null
	for hand_position in range(0, HAND_SIZE):
		hand.push_back(null)
		
	for card in labyrinth:
		card.queue_free()
	labyrinth.clear()
	
	for card in limbo:
		card.queue_free()
	limbo.clear()
	
	SignalManager.new_game.emit()

func shuffle() -> void:
	deck_model.shuffle()
	SignalManager.shuffle.emit()
	
func card_added_to_discard(card: Card) -> void:
	var hand_position: int = hand.find(card)
	hand[hand_position] = null
	discard.push_back(card)
	
func card_added_to_labyrinth(card: Card) -> void:
	var hand_position: int = hand.find(card)
	hand[hand_position] = null
	labyrinth.push_back(card)

func card_added_to_limbo(card: Card) -> void:
	var hand_position: int = hand.find(card)
	hand[hand_position] = null
	limbo.push_back(card)
