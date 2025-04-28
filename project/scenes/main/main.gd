extends Node2D

@onready var hand_marker_1: Marker2D = $HandMarkers/HandMarker1
@onready var hand_marker_2: Marker2D = $HandMarkers/HandMarker2
@onready var hand_marker_3: Marker2D = $HandMarkers/HandMarker3
@onready var hand_marker_4: Marker2D = $HandMarkers/HandMarker4
@onready var hand_marker_5: Marker2D = $HandMarkers/HandMarker5
@onready var deck: Deck = $Deck
@onready var limbo: Limbo = $Limbo
@onready var card_container: Node2D = $CardContainer
@onready var doors_panel: DoorsPanel = $DoorsPanel
@onready var door_found_marker: Marker2D = $DoorFoundMarker
@onready var nightmare_found_marker: Marker2D = $NightmareFoundMarker
@onready var nightmare_panel: Node2D = $NightmarePanel
@onready var discard: Discard = $Discard

const CARD = preload("res://scenes/card/card.tscn")

var hand_markers: Array[Marker2D]

var nightmare_action_discard_selected: Constants.NIGHTMARE_DISCARD = Constants.NIGHTMARE_DISCARD.NONE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.card_return_to_hand.connect(card_return_to_hand)
	SignalManager.card_added_to_discard.connect(card_added_to_discard)
	SignalManager.card_added_to_labyrinth.connect(card_added_to_labyrinth)
	SignalManager.card_added_to_limbo.connect(card_added_to_limbo)
	SignalManager.door_discarded.connect(door_discarded)
	SignalManager.nightmare_action_selected.connect(nightmare_action_selected)
	SignalManager.touch_event.connect(touch_event)
	
	hand_markers.push_back(hand_marker_1)
	hand_markers.push_back(hand_marker_2)
	hand_markers.push_back(hand_marker_3)
	hand_markers.push_back(hand_marker_4)
	hand_markers.push_back(hand_marker_5)
	#this is to handle overlapping cards properly
	get_viewport().physics_object_picking_sort = true
	GameManager.new_game()		
	SignalManager.new_game.emit()
	doors_panel.setup(GameManager.deck_model.get_number_of(CardManager.CARD_TYPE.DOOR))
	draw_full_hand()
	#enable cards to be picked
	set_hand_freezed(false)
	
func draw_card(empty_limbo_enabled: bool, nightmares_enabled: bool) -> bool:
	var card_drawn: bool = false
	for hand_position in range(0, GameManager.HAND_SIZE):
		if not GameManager.hand[hand_position] == null:
			continue
		while GameManager.hand[hand_position] == null:
			if GameManager.deck_model.get_number_of_cards() == 0:
				return false
			var card_model: CardModel = GameManager.deck_model.get_next_card()
			var card: Card = CARD.instantiate()
			card.input_pickable = true
			card.card_model = card_model
			card_container.add_child(card)
			if card_model.can_be_in_hand:
				card.hand_position = hand_position	
				GameManager.hand[hand_position] = card
				await animate_card_draw(card)
				SignalManager.card_drawed.emit(card)
				card_drawn = true
				break
			else:
				card.hand_position = hand_position
				await animate_card_draw(card)
				if nightmares_enabled and card.card_model.type == CardManager.CARD_TYPE.NIGHTMARE:
					await animate_nightmare(card)
					set_hand_freezed(true)
					nightmare_panel.visible = true
					return true
				else:					
					await animate_card_to_limbo(card)
					SignalManager.card_added_to_limbo.emit(card)
		if empty_limbo_enabled and not GameManager.limbo.is_empty():
			await empty_limbo()
		return card_drawn
	return false

func draw_full_hand():
	while await draw_card(false, false):
		pass
	if not GameManager.limbo.is_empty():
		await empty_limbo()
		
func empty_limbo() -> void:
	var limbo_copy: Array[Card]
	limbo_copy.append_array(GameManager.limbo)
	#remove cards from the top one, it's visually nicer
	limbo_copy.reverse()
	for card in limbo_copy:
		await animate_card_from_limbo_to_deck(card)
		GameManager.deck_model.add_card_back(card.card_model)
		SignalManager.card_removed_from_limbo.emit(card)
		GameManager.limbo.erase(card)
		card.queue_free()
	await animate_shuffle()
	GameManager.shuffle()
	
func card_return_to_hand(card: Card) -> void:
	card.position = hand_markers[card.hand_position].global_position
	card.rotation = hand_markers[card.hand_position].rotation
	card.z_index = card.hand_position + Constants.HAND_BASE_Z

func card_added_to_labyrinth(card: Card) -> void:
	GameManager.card_added_to_labyrinth(card)
	var color: CardManager.CARD_COLOR = GameManager.check_door_found()
	if color != CardManager.CARD_COLOR.NONE:
		await animate_door_found(color)
		doors_panel.set_doors_found(color, GameManager.found_doors[color].size())
		if GameManager.check_won_game():
			print("game won")
			pass
		else:
			await animate_shuffle()
			GameManager.shuffle()
			await draw_card(true, true)
	else:
		await draw_card(true, true)
	
func card_added_to_discard(card: Card, draw_card: bool) -> void:
	GameManager.card_added_to_discard(card)
	if draw_card:
		await draw_card(true, true)

func card_added_to_limbo(card: Card) -> void:
	GameManager.card_added_to_limbo(card)

func set_hand_freezed(value: bool) -> void:
	for child in card_container.get_children():
		var card: Card = child
		card.freezed = value

func door_discarded(color: CardManager.CARD_COLOR) -> void:
	GameManager.door_discarded(color)
	doors_panel.set_doors_found(color, GameManager.found_doors[color].size())

func nightmare_action_selected(type: Constants.NIGHTMARE_DISCARD) -> void:
	nightmare_action_discard_selected = type
	match(type):
		Constants.NIGHTMARE_DISCARD.NONE:
			deck.set_outline(false)
			doors_panel.set_outline(false)
			set_hand_outline(false)
		Constants.NIGHTMARE_DISCARD.DECK:
			deck.set_outline(true)
			doors_panel.set_outline(false)
			set_hand_outline(false)
		Constants.NIGHTMARE_DISCARD.DOOR:
			deck.set_outline(false)
			doors_panel.set_outline(true)
			set_hand_outline(false)
		Constants.NIGHTMARE_DISCARD.KEY:
			deck.set_outline(false)
			doors_panel.set_outline(false)
			set_hand_outline(false)
			set_keys_outline(true)
		Constants.NIGHTMARE_DISCARD.HAND:
			deck.set_outline(false)
			doors_panel.set_outline(false)
			set_hand_outline(true)

func touch_event(object: Variant) -> void:
	if nightmare_action_discard_selected != Constants.NIGHTMARE_DISCARD.NONE:
		# nightmare action was selected so we check if we should activate the action
		handle_nightmare_action(nightmare_action_discard_selected, object)
		return
	pass

func handle_nightmare_action(type: Constants.NIGHTMARE_DISCARD, object: Variant) -> void:
	if type == Constants.NIGHTMARE_DISCARD.HAND and object is Card:
		for card in GameManager.hand:			
			if card != null:
				await animate_card_to_discard(card)
				SignalManager.card_added_to_discard.emit(card, false)
		await discard_nightmare_card()
		draw_full_hand()
	if type == Constants.NIGHTMARE_DISCARD.KEY and object is Card:
		var card: Card = object
		if card.card_model.type == CardManager.CARD_TYPE.KEY:
			await animate_card_to_discard(card)
			SignalManager.card_added_to_discard.emit(card, false)
			await discard_nightmare_card()
			draw_full_hand()
	if type == Constants.NIGHTMARE_DISCARD.DECK and object is Deck:
		for i in range(0, 5):
			if GameManager.deck_model.get_number_of_cards() == 0:
				#TODO game over
				pass
			var card_model: CardModel = GameManager.deck_model.get_next_card()
			var card: Card = CARD.instantiate()
			card.card_model = card_model
			card.input_pickable = false
			card_container.add_child(card)
			card.z_index = Constants.DRAGGING_BASE_Z
			card.position = deck.position
			card.set_front_texture()
			if card_model.can_be_in_hand:
				await animate_card_to_discard(card)
				SignalManager.card_added_to_discard.emit(card, false)
			else:
				await animate_card_to_limbo(card)
				SignalManager.card_added_to_limbo.emit(card)
		await discard_nightmare_card()
		draw_full_hand()
	if type == Constants.NIGHTMARE_DISCARD.DOOR and object is DoorsButton:
		var doors_button: DoorsButton = object
		var color: CardManager.CARD_COLOR = doors_button.color
		if doors_button.is_lighted() and GameManager.found_doors[color].size() > 0:
			#put back the door in deck
			GameManager.door_discarded(color)
			doors_panel.set_doors_found(color, GameManager.found_doors[color].size())
			await animate_door_discarded(color)
			await discard_nightmare_card()
			draw_full_hand()
	pass

func find_nightmare_card() -> Card:
	for child in card_container.get_children():
		var card: Card = child
		if card.card_model.type == CardManager.CARD_TYPE.NIGHTMARE:
			return card
	return null

func discard_nightmare_card() -> void:
	doors_panel.set_outline(false)
	nightmare_panel.reset()
	nightmare_panel.visible = false	
	var card: Card = find_nightmare_card()
	await animate_card_to_discard(card)
	SignalManager.card_added_to_discard.emit(card, false)
	
	
func set_hand_outline(enabled: bool) -> void:
	set_cards_outline(enabled, false)

func set_keys_outline(enabled: bool) -> void:
	set_cards_outline(enabled, true)
	
func set_cards_outline(enabled: bool, keys_only: bool) -> void:
	for card in GameManager.hand:
		if card != null:
			if not keys_only or card.card_model.type == CardManager.CARD_TYPE.KEY:
				card.set_outline(enabled)
			

####################################################
### Animations
####################################################

func animate_nightmare(card: Card) -> void:
	set_hand_freezed(true)
	card.z_index = Constants.DRAGGING_BASE_Z
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(card, "position", nightmare_found_marker.position, 0.2)
	tween.parallel().tween_property(card, "rotation_degrees", 360, 0.2)
	tween.parallel().tween_property(card, "scale", Vector2(1.3,1.3), 0.2)
	await tween.finished
	set_hand_freezed(false)
	
func animate_door_found(color: CardManager.CARD_COLOR) -> void:
	set_hand_freezed(true)
	#just get the first found of the given color, assuming the door has been put there before this call
	var card_model = GameManager.found_doors[color][0]
	var card: Card = CARD.instantiate()
	card.card_model = card_model
	card.input_pickable = false
	card_container.add_child(card)
	card.z_index = Constants.DRAGGING_BASE_Z
	card.position = deck.position
	card.set_back_texture()
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(card, "position", door_found_marker.position, 0.5)
	tween.tween_property(card, "scale", Vector2(0,1), 0.2)
	tween.tween_callback(card.set_front_texture)
	tween.tween_property(card, "scale", Vector2(1.5,1.5), 0.1)
	tween.tween_interval(0.5)
	tween.tween_property(card, "position", Vector2(door_found_marker.position.x, doors_panel.position.y), 0.1)
	tween.parallel().tween_property(card, "scale", Vector2(0, 0), 0.1)
	await tween.finished
	card.queue_free()
	set_hand_freezed(false)

func animate_door_discarded(color: CardManager.CARD_COLOR) -> void:
	set_hand_freezed(true)
	#assuming the card model is back on the deck
	var card_model = GameManager.deck_model.search(CardManager.CARD_TYPE.DOOR, color)
	var card: Card = CARD.instantiate()
	card.card_model = card_model
	card.input_pickable = false
	card_container.add_child(card)
	card.z_index = Constants.DRAGGING_BASE_Z
	card.position = Vector2(door_found_marker.position.x, doors_panel.position.y)
	card.scale = Vector2(0, 0)
	card.set_front_texture()
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(card, "position", door_found_marker.position, 0.1)
	tween.parallel().tween_property(card, "scale", Vector2(1.5,1.5), 0.1)
	tween.tween_interval(0.5)
	#disappear into the deck
	tween.tween_property(card, "position", deck.position, 0.1)
	tween.parallel().tween_property(card, "scale", Vector2(0, 0), 0.1)
	await tween.finished
	card.queue_free()
	set_hand_freezed(false)
		
func animate_shuffle() -> void:
	set_hand_freezed(true)
	var cards: Array[Card] = [CARD.instantiate(), CARD.instantiate(), CARD.instantiate(), CARD.instantiate()]
	var tweens: Array[Tween]
	for card in cards:
		card.card_model = GameManager.deck_model.deck[0]
		deck.add_child(card)
		card.set_back_texture()
		card.set_full_size()
		card.z_index = 1
		var offset: int = 50
		var duration: float = 0.05
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(card, "position", Vector2(randf_range(-offset,offset),randf_range(-offset,offset)), duration)
		tween.tween_property(card, "position", Vector2(randf_range(-offset,offset),randf_range(-offset,offset)), duration)
		tween.tween_property(card, "position", Vector2(randf_range(-offset,offset),randf_range(-offset,offset)), duration)
		tween.tween_property(card, "position", Vector2(randf_range(-offset,offset),randf_range(-offset,offset)), duration)
		tween.tween_property(card, "position", Vector2(randf_range(-offset,offset),randf_range(-offset,offset)), duration)
		tween.tween_property(card, "position", Vector2(randf_range(-offset,offset),randf_range(-offset,offset)), duration)
		tween.tween_property(card, "position", Vector2(randf_range(-offset,offset),randf_range(-offset,offset)), duration)
		tween.tween_property(card, "position", Vector2(randf_range(-offset,offset),randf_range(-offset,offset)), duration)
		tween.tween_property(card, "position", Vector2.ZERO, duration)
		tweens.push_back(tween)
	for tween in tweens:
		await tween.finished
	for card in cards:
		card.queue_free()
	set_hand_freezed(false)
	
func animate_card_draw(card: Card) -> void:
	set_hand_freezed(true)
	card.z_index = card.hand_position + Constants.HAND_BASE_Z
	card.position = deck.position
	card.rotation = hand_markers[card.hand_position].rotation
	var tween: Tween = get_tree().create_tween()
	tween.parallel().tween_property(card, "position", hand_markers[card.hand_position].global_position, 0.2)
	tween.parallel().tween_property(card, "scale", Vector2(0,1), 0.2)
	tween.tween_callback(card.set_front_texture)
	tween.tween_property(card, "scale", Vector2(1,1), 0.1)
	await tween.finished
	set_hand_freezed(false)

func animate_card_to_limbo(card: Card) -> void:
	set_hand_freezed(true)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(card, "global_position", limbo.global_position, 0.2)
	tween.parallel().tween_property(card, "scale", Card.LIMBO_SIZE, 0.2)
	await tween.finished
	set_hand_freezed(false)

func animate_card_to_discard(card: Card) -> void:
	set_hand_freezed(true)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(card, "global_position", discard.global_position, 0.2)
	tween.parallel().tween_property(card, "scale", Card.DISCARD_SIZE, 0.2)
	await tween.finished
	set_hand_freezed(false)
	
func animate_card_from_limbo_to_deck(card: Card) -> void:
	set_hand_freezed(true)
	var tween: Tween = get_tree().create_tween()
	tween.parallel().tween_property(card, "global_position", deck.global_position, 0.2)
	tween.parallel().tween_property(card, "scale", Vector2(0,1), 0.2)
	tween.parallel().tween_property(card, "rotation", 0, 0.2)
	tween.tween_callback(card.set_back_texture)
	tween.tween_property(card, "scale", Vector2(1,1), 0.1)
	await tween.finished
	set_hand_freezed(false)
