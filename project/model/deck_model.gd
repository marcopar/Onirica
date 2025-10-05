extends Node

class_name DeckModel

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
	var n = deck.size()
	randomize() # <- we only have 2**64 possible seeds available, 2**226 are needed
	for i in range(n - 1, 0, -1):
		var j = randi() % (i + 1)
		var temp = deck[i]
		deck[i] = deck[j]
		deck[j] = temp
			
func get_number_of_cards() -> int:
	return deck.size()

func get_next_card() -> CardModel:
	var card_model = deck.pop_front()
	return card_model
	
func add_card_front(card: CardModel):
	deck.push_front(card)

func add_card_back(card: CardModel):
	deck.push_back(card)
	
func get_number_of(type: CardManager.CARD_TYPE) -> int:
	var count: int = 0
	for card in deck:
		if card.type == type:
			count += 1
	return count
	
func search(type: CardManager.CARD_TYPE, color: CardManager.CARD_COLOR) -> CardModel:
	for card in deck:
		if card.type == type and card.color == color:
			return card
	return null
			
