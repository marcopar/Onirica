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

const CARD = preload("res://scenes/card/card.tscn")

var hand_markers: Array[Marker2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.card_return_to_hand.connect(card_return_to_hand)
	SignalManager.card_added_to_discard.connect(card_added_to_discard)
	SignalManager.card_added_to_labyrinth.connect(card_added_to_labyrinth)
	SignalManager.card_added_to_limbo.connect(card_added_to_limbo)
	SignalManager.door_discarded.connect(door_discarded)
	SignalManager.nightmare_action_selected.connect(nightmare_action_selected)
	SignalManager.nightmare_action_activated.connect(nightmare_action_activated)
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
	while await draw_card(false, false):
		pass
	if not GameManager.limbo.is_empty():
		await empty_limbo()
	#enable cards to be picked
	set_hand_pickable(true)
	
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
					set_hand_pickable(false)
					nightmare_panel.visible = true
					return true
				else:					
					await animate_card_to_limbo(card)
					SignalManager.card_added_to_limbo.emit(card)
		if empty_limbo_enabled and not GameManager.limbo.is_empty():
			await empty_limbo()
		return card_drawn
	return false

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
			pass
		else:
			await animate_shuffle()
			GameManager.shuffle()
			await draw_card(true, true)
	else:
		await draw_card(true, true)
	
func card_added_to_discard(card: Card) -> void:
	GameManager.card_added_to_discard(card)
	await draw_card(true, true)

func card_added_to_limbo(card: Card) -> void:
	GameManager.card_added_to_limbo(card)

func set_hand_pickable(enabled: bool) -> void:
	for child in card_container.get_children():
		var card: Card = child
		card.can_move = enabled

func door_discarded(color: CardManager.CARD_COLOR) -> void:
	GameManager.door_discarded(color)
	doors_panel.set_doors_found(color, GameManager.found_doors[color].size())

func nightmare_action_selected(type: Constants.NIGHTMARE_DISCARD) -> void:
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

func nightmare_action_activated(type: Constants.NIGHTMARE_DISCARD) -> void:
	pass
	
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
	set_hand_pickable(false)
	card.z_index = Constants.DRAGGING_BASE_Z
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(card, "position", nightmare_found_marker.position, 0.2)
	tween.parallel().tween_property(card, "rotation_degrees", 360, 0.2)
	tween.parallel().tween_property(card, "scale", Vector2(1.3,1.3), 0.2)
	await tween.finished
	set_hand_pickable(true)
	
func animate_door_found(color: CardManager.CARD_COLOR) -> void:
	set_hand_pickable(false)
	#just get the first found of the given color
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
	set_hand_pickable(true)
		
func animate_shuffle() -> void:
	set_hand_pickable(false)
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
	set_hand_pickable(true)
	
func animate_card_draw(card: Card) -> void:
	set_hand_pickable(false)
	card.z_index = card.hand_position + Constants.HAND_BASE_Z
	card.position = deck.position
	card.rotation = hand_markers[card.hand_position].rotation
	var tween: Tween = get_tree().create_tween()
	tween.parallel().tween_property(card, "position", hand_markers[card.hand_position].global_position, 0.2)
	tween.parallel().tween_property(card, "scale", Vector2(0,1), 0.2)
	tween.tween_callback(card.set_front_texture)
	tween.tween_property(card, "scale", Vector2(1,1), 0.1)
	await tween.finished
	set_hand_pickable(true)

func animate_card_to_limbo(card: Card) -> void:
	set_hand_pickable(false)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(card, "global_position", limbo.global_position, 0.2)
	tween.parallel().tween_property(card, "scale", Card.LIMBO_SIZE, 0.2)
	await tween.finished
	set_hand_pickable(true)
	
func animate_card_from_limbo_to_deck(card: Card) -> void:
	set_hand_pickable(false)
	var tween: Tween = get_tree().create_tween()
	tween.parallel().tween_property(card, "global_position", deck.global_position, 0.2)
	tween.parallel().tween_property(card, "scale", Vector2(0,1), 0.2)
	tween.parallel().tween_property(card, "rotation", 0, 0.2)
	tween.tween_callback(card.set_back_texture)
	tween.tween_property(card, "scale", Vector2(1,1), 0.1)
	await tween.finished
	set_hand_pickable(true)
