extends Node

const HAND_SIZE: int = 5
const SAVE_FILE_NAME: String = "user://savegame.json"

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

#checks the whole labyrinth every time but doesn't need to store extra flags
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
		last3[0].type != last3[1].type and \
		last3[1].type != last3[2].type:
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

func get_save_dict() -> Dictionary:
	var dict = {
		"deck": [],
		"hand": [],
		"labyrinth": [],
		"limbo": [],
		"discard": [],
		"doors_to_be_found": doors_to_be_found,
		"found_doors": {
			CardManager.CARD_COLOR.RED: [],
			CardManager.CARD_COLOR.GREEN: [],
			CardManager.CARD_COLOR.BLUE: [],
			CardManager.CARD_COLOR.YELLOW: []
		}
	}
	for c in deck_model.deck:
		dict["deck"].append({"type": c.type, "color": c.color})
	for c in hand:
		if c == null:
			dict["hand"].append(null)
		else:
			dict["hand"].append({"type": c.type, "color": c.color})
	for c in labyrinth:
		dict["labyrinth"].append({"type": c.type, "color": c.color})
	for c in limbo:
		dict["limbo"].append({"type": c.type, "color": c.color})
	for c in discard:
		dict["discard"].append({"type": c.type, "color": c.color})
	for color in found_doors.keys():
		for c in found_doors[color]:
			dict["found_doors"][color].append({"type": c.type, "color": c.color})
	return dict

func save_file_exists() -> bool:
	return FileAccess.file_exists(SAVE_FILE_NAME)
	
func delete_save_file() -> void:
	DirAccess.remove_absolute(SAVE_FILE_NAME)	
	
func save_game() -> void:
	var dict = get_save_dict()
	var file = FileAccess.open(SAVE_FILE_NAME, FileAccess.WRITE)
	file.store_string(JSON.stringify(dict))
	file.close()

func load_game() -> void:
	if not save_file_exists():
		GameManager.new_game()
		return
	var file = FileAccess.open(SAVE_FILE_NAME, FileAccess.READ)
	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var dict = json.data
		if dict.has("deck"):
			deck_model = DeckModel.new()
			deck_model.deck.clear()
			for c_data in dict["deck"]:
				deck_model.deck.append(CardManager.create_card(int(c_data["type"]), int(c_data["color"])))
			
			hand.clear()
			for c_data in dict["hand"]:
				if c_data == null:
					hand.append(null)
				else:
					hand.append(CardManager.create_card(int(c_data["type"]), int(c_data["color"])))
					
			labyrinth.clear()
			for c_data in dict["labyrinth"]:
				labyrinth.append(CardManager.create_card(int(c_data["type"]), int(c_data["color"])))
				
			limbo.clear()
			for c_data in dict["limbo"]:
				limbo.append(CardManager.create_card(int(c_data["type"]), int(c_data["color"])))
				
			discard.clear()
			for c_data in dict["discard"]:
				discard.append(CardManager.create_card(int(c_data["type"]), int(c_data["color"])))
				
			doors_to_be_found = dict["doors_to_be_found"]
			
			found_doors = {
				CardManager.CARD_COLOR.RED: [],
				CardManager.CARD_COLOR.GREEN: [],
				CardManager.CARD_COLOR.BLUE: [],
				CardManager.CARD_COLOR.YELLOW: []
			}
			var fd = dict["found_doors"]
			for color_str in fd.keys():
				var color_idx = int(color_str)
				for c_data in fd[color_str]:
					found_doors[color_idx].append(CardManager.create_card(int(c_data["type"]), int(c_data["color"])))
			file.close()
			return
	file.close()
	delete_save_file()
	GameManager.new_game()
	


func dump() -> void:
	print("######################################################################")
	print("== HAND ==")
	for card_model in hand:
		if card_model != null:
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
