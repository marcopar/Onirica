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

#checks the whole lanyrinth every time but doesn't need to store extra flags
func check_labyrinth() -> CardManager.CARD_COLOR:
	var last3: Array[Card] = []
	for card in labyrinth:
		last3.push_back(card)
		if last3.size() != 3:
			continue		
		if check_for_door_combo(last3):
			#if it's the last 3 then we found a combo
			if labyrinth.find(card) == labyrinth.size() - 1:				
				return card.card_model.color
			#we found an old combo, clear the last3 and start from scratch
			last3.clear()
		else:
			#remove the first card as we didn't find a combo (slide forward one step)
			last3.pop_front()
	return CardManager.CARD_COLOR.NONE
	
func check_for_door_combo(last3: Array[Card]) -> bool:
	var colors: Dictionary = {}
	for card in last3:
		if card.card_model.color == CardManager.CARD_COLOR.MULTI:
			continue
		colors[card.card_model.color] = true
	if colors.keys().size() == 1 and \
		last3[0].card_model.type != last3[1].card_model.type and \
		last3[1].card_model.type != last3[2].card_model.type:
			return true
	return false
	
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
