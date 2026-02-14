extends Node

const HAND_SIZE: int = 5

var deck_model: DeckModel:
	get:
		return deck_model
	set(value):
		deck_model = value
		
var hand: Array[CardModel]:
	get:
		return hand
	set(value):
		hand = value
		
var labyrinth: Array[CardModel]:
	get:
		return labyrinth
	set(value):
		labyrinth = value

var limbo: Array[CardModel]:
	get:
		return limbo
	set(value):
		limbo = value

var discard: Array[CardModel]:
	get:
		return discard
	set(value):
		discard = value
		
var doors_to_be_found: int
		
#Variant because  we want to have an  Array as value
var found_doors: Dictionary[CardManager.CARD_COLOR, Variant] = {
	CardManager.CARD_COLOR.RED: [],
	CardManager.CARD_COLOR.GREEN: [],
	CardManager.CARD_COLOR.BLUE: [],
	CardManager.CARD_COLOR.YELLOW: []
	}:
	get:
		return found_doors
	set(value):
		found_doors = value
		
func _ready() -> void:
	pass

func new_game() -> void:
	deck_model = DeckModel.new()
	deck_model.deck = CardManager.create_base_deck()
	doors_to_be_found = deck_model.get_number_of(CardManager.CARD_TYPE.DOOR)
	deck_model.shuffle()
	
	hand.clear()	
	#refill hand with null
	for hand_position in range(0, HAND_SIZE):
		hand.push_back(null)
	
	labyrinth.clear()
	limbo.clear()
	discard.clear()
	
	found_doors = {
		CardManager.CARD_COLOR.RED: [],
		CardManager.CARD_COLOR.GREEN: [],
		CardManager.CARD_COLOR.BLUE: [],
		CardManager.CARD_COLOR.YELLOW: []
	}

func shuffle() -> void:
	deck_model.shuffle()

#checks the whole lanyrinth every time but doesn't need to store extra flags
func check_door_found() -> CardModel:
	var last3: Array[CardModel] = []
	for card_model in labyrinth:
		last3.push_back(card_model)
		if last3.size() != 3:
			continue		
		if check_for_door_combo(last3):
			#if it's the last 3 then we found a combo
			if labyrinth.find(card_model) == labyrinth.size() - 1:
				#get the door from the deck
				var door: CardModel = deck_model.search(CardManager.CARD_TYPE.DOOR, card_model.color)
				if door != null:
					set_door_as_found(door)
					return door
			#we found an old combo, clear the last3 and start from scratch
			last3.clear()
		else:
			#remove the first card as we didn't find a combo (slide forward one step)
			last3.pop_front()
	return null

func set_door_as_found(door: CardModel) -> void:
	#remove the door (model) from the deck and add it to the found doors
	deck_model.deck.erase(door)
	found_doors[door.color].push_back(door)

func check_for_door_combo(last3: Array[CardModel]) -> bool:
	var colors: Dictionary[CardManager.CARD_COLOR, bool] = {}
	#count the different colors
	for card_model in last3:
		if card_model.color == CardManager.CARD_COLOR.MULTI:
			continue
		colors[card_model.color] = true
	#check the colors number and the types
	if colors.keys().size() == 1 and \
		last3[0].card_model.type != last3[1].card_model.type and \
		last3[1].card_model.type != last3[2].card_model.type:
			return true
	return false
	
func card_added_to_discard(card_model: CardModel) -> void:
	var hand_position: int = hand.find(card_model)
	if hand_position != -1:
		hand[hand_position] = null
	discard.push_back(card_model)
	
func card_added_to_labyrinth(card_model: CardModel) -> void:
	var hand_position: int = hand.find(card_model)
	if hand_position != -1:
		hand[hand_position] = null
	labyrinth.push_back(card_model)

func card_added_to_limbo(card_model: CardModel) -> void:
	var hand_position: int = hand.find(card_model)
	if hand_position != -1:
		hand[hand_position] = null
	limbo.push_back(card_model)

func check_won_game() -> bool:
	var found_doors_count: int = 0
	for color in found_doors.keys():
		found_doors_count += found_doors[color].size()
	return found_doors_count == doors_to_be_found
	
		
func check_door_against_hand_keys(door_card_model: CardModel) -> CardModel:
	for card_model in GameManager.hand:
		if card_model != null && card_model.type == CardManager.CARD_TYPE.KEY && card_model.color == door_card_model.color:			
			return card_model
	return null

const SAVE_PATH: String = "user://savegame.json"

func save_game() -> void:
	var save_data: Dictionary = {
		"doors_to_be_found": doors_to_be_found,
		"deck": _serialize_card_models(deck_model.deck),
		"hand": _serialize_card_models(hand),
		"labyrinth": _serialize_card_models(labyrinth),
		"limbo": _serialize_card_models(limbo),
		"discard": _serialize_card_models(discard),
		"found_doors": _serialize_found_doors()
	}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	print("Game saved to: ", SAVE_PATH)

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found")
		return
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var save_data: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	
	doors_to_be_found = save_data["doors_to_be_found"]
	deck_model = DeckModel.new()
	deck_model.deck = _deserialize_card_models(save_data["deck"])
	hand = _deserialize_card_models(save_data["hand"])
	labyrinth = _deserialize_card_models(save_data["labyrinth"])
	hand = _deserialize_card_models(save_data["limbo"])
	discard = _deserialize_card_models(save_data["discard"])
	found_doors = _deserialize_found_doors(save_data["found_doors"])
	
	print("Game loaded from: ", SAVE_PATH)

func _serialize_card_models(cards: Array[CardModel]) -> Array:
	var result: Array = []
	for card_model in cards:
		result.append(_card_model_to_dict(card_model))
	return result
	
func _deserialize_card_models(data: Array) -> Array[CardModel]:
	var result: Array[CardModel] = []
	for item in data:
		result.append(_dict_to_card_model(item))
	return result
	
func _serialize_found_doors() -> Dictionary:
	var result: Dictionary = {}
	for color in found_doors.keys():
		var doors_array: Array = []
		for door in found_doors[color]:
			doors_array.append(_card_model_to_dict(door))
		result[color] = doors_array
	return result

func _deserialize_found_doors(data: Dictionary) -> Dictionary[CardManager.CARD_COLOR, Variant]:
	var result: Dictionary[CardManager.CARD_COLOR, Variant] = {
		CardManager.CARD_COLOR.RED: [],
		CardManager.CARD_COLOR.GREEN: [],
		CardManager.CARD_COLOR.BLUE: [],
		CardManager.CARD_COLOR.YELLOW: []
	}
	for color_idx in data.keys():
		var color: CardManager.CARD_COLOR = CardManager.CARD_COLOR.find_key(int(color_idx))
		for item in data[color]:
			result[color].append(_dict_to_card_model(item))
	return result

func _card_model_to_dict(card_model: CardModel) -> Dictionary:
	return {
		"type": card_model.type,
		"color": card_model.color,
		"sprite_name": card_model.sprite_name
	}

func _dict_to_card_model(data: Dictionary) -> CardModel:
	var card_model := CardModel.new()
	card_model.type = int(data["type"]) as CardManager.CARD_TYPE
	card_model.color = int(data["color"]) as CardManager.CARD_COLOR
	card_model.sprite_name = data["sprite_name"]
	return card_model


func dump() -> void:
	print("######################################################################")
	print("== HAND ==")
	for card_model in hand:
		if card_model !=  null:
			print(card_model)
	print("\n")
	
	print("== LIMBO %d ==" % [limbo.size()])
	for card_model in limbo:
		print(card_model)
	print("\n")
	
	print("== DISCARD %d ==" % [discard.size()])
	for card_model in discard:
		print(card_model)
	print("\n")
	
	print("== LABYRINTH %d ==" % [labyrinth.size()])
	for card_model in labyrinth:
		print(card_model)
	print("\n")

	print("== DECK %d ==" % [deck_model.deck.size()])
	for card_model in deck_model.deck:
		print(card_model)
	print("\n")
	
	print("== FOUND DOORS ==")
	for color in found_doors.keys():
		print(CardManager.CARD_COLOR.keys()[color],  " = ", found_doors[color].size())
	print("\n")
	
