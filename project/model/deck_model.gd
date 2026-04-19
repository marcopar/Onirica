extends Node

class_name DeckModel

#for tresting
var shuffle_disabled: bool = false

var deck: Array[CardModel]:
	get:
		return deck
	set(value):
		deck = value

#https://www.reddit.com/r/godot/comments/17gq5vq/shuffling_a_deck_of_52_cards_correctly_what_are/
func shuffle() -> void:
	_shuffle()
	_shuffle()
	_shuffle()
	_shuffle()

func _shuffle() -> void:
	if shuffle_disabled:
		return
	var n: int = deck.size()
	randomize() # <- we only have 2**64 possible seeds available, 2**226 are needed
	for i: int in range(n - 1, 0, -1):
		var j: int = randi() % (i + 1)
		var temp: CardModel = deck[i]
		deck[i] = deck[j]
		deck[j] = temp
			
func get_number_of_cards() -> int:
	return deck.size()

func get_next_card() -> CardModel:
	var card_model: CardModel = deck.pop_front()
	SignalManager.deck_updated.emit()
	return card_model
	
func add_card_front(card: CardModel) -> void:
	deck.push_front(card)
	SignalManager.deck_updated.emit()

func add_card_back(card: CardModel) -> void:
	deck.push_back(card)
	SignalManager.deck_updated.emit()
	
func get_number_of(type: CardManager.CARD_TYPE) -> int:
	var count: int = 0
	for card: CardModel in deck:
		if card.type == type:
			count += 1
	return count
	
func search(type: CardManager.CARD_TYPE, color: CardManager.CARD_COLOR) -> CardModel:
	for card: CardModel in deck:
		if card.type == type and card.color == color:
			return card
	return null

func search_and_remove(type: CardManager.CARD_TYPE, color: CardManager.CARD_COLOR) -> CardModel:
	for card: CardModel in deck:
		if card.type == type and card.color == color:
			deck.erase(card)
			return card
	return null
