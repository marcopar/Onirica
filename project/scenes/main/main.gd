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
@onready var nightmare_panel: Node2D = $NightmarePanel
@onready var discard: Discard = $Discard
@onready var labyrinth: Labyrinth = $Labyrinth
@onready var open_door_panel: OpenDoorPanel = $OpenDoorPanel
@onready var card_presentation_marker: Marker2D = $CardPresentationMarker
@onready var prophecy_panel: ProphecyPanel = $ProphecyPanel
@onready var exit_button: TextureButton = $GUI/VBoxContainer/MenuBar/ExitButton
@onready var discard_panel_container: Control = $GUI/VBoxContainer/MainArea/DiscardPanelContainer
@onready var discard_panel: DiscardPanel = $GUI/VBoxContainer/MainArea/DiscardPanelContainer/DiscardPanel
@onready var win_lose_panel_container: Control = $GUI/VBoxContainer/MainArea/WinLosePanelContainer
@onready var win_panel: Control = $GUI/VBoxContainer/MainArea/WinLosePanelContainer/WinPanel
@onready var lose_panel: Control = $GUI/VBoxContainer/MainArea/WinLosePanelContainer/LosePanel

const CARD = preload("uid://fib6nrvub15n")

var hand_markers: Array[Marker2D]

var nightmare_action_discard_selected: Constants.NIGHTMARE_DISCARD = Constants.NIGHTMARE_DISCARD.NONE
var ignore_gui_events: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var e: InputEventKey = event
		if e.as_text_keycode() == "D" and e.is_pressed():
			GameManager.dump()
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	SignalManager.card_return_to_hand.connect(card_return_to_hand)
	SignalManager.card_added_to_discard.connect(card_added_to_discard)
	SignalManager.card_added_to_labyrinth.connect(card_added_to_labyrinth)
	SignalManager.card_added_to_limbo.connect(card_added_to_limbo)
	SignalManager.door_discarded.connect(door_discarded)
	SignalManager.nightmare_action_selected.connect(nightmare_action_selected)
	SignalManager.touch_event.connect(touch_event)
	SignalManager.key_open_door_selected.connect(key_open_door_selected)
	SignalManager.deck_outline_enabled.connect(deck_outline_enabled)
	SignalManager.discard_panel_closed.connect(discard_panel_closed)
	
	hand_markers.push_back(hand_marker_1)
	hand_markers.push_back(hand_marker_2)
	hand_markers.push_back(hand_marker_3)
	hand_markers.push_back(hand_marker_4)
	hand_markers.push_back(hand_marker_5)
	#this is to handle overlapping cards properly
	get_viewport().physics_object_picking_sort = true

	recreate_game_objects()
	await draw_full_hand(false, false, false)
	
	SignalManager.new_game.emit()
	
func draw_card(nightmares_enabled: bool, doors_enabled: bool) -> Card:
	var card: Card = null
	for hand_position in range(0, GameManager.HAND_SIZE):
		if not GameManager.hand[hand_position] == null:
			continue
		while GameManager.hand[hand_position] == null:
			if GameManager.deck_model.get_number_of_cards() == 0:
				show_lose_panel()
				return null
			var card_model: CardModel = GameManager.deck_model.get_next_card()
			card = create_card(card_model, card_container, deck.position, Card.FULL_SIZE, true, Constants.DRAGGING_BASE_Z)
			#new cards are always freezed
			card.freezed = true
			card.set_back_texture()
			card.hand_position = hand_position	
			await animate_card_draw(card)
			if card_model.can_be_in_hand:
				GameManager.hand[hand_position] = card_model
				break
			else:
				if nightmares_enabled and card.card_model.type == CardManager.CARD_TYPE.NIGHTMARE:
					return card
				elif doors_enabled and card.card_model.type == CardManager.CARD_TYPE.DOOR and check_door_against_hand_keys(card):					
					return card
				else:					
					await animate_card_to_limbo(card)
					SignalManager.card_added_to_limbo.emit(card)
		return card
	return null

func create_card(model: CardModel, parent: Node2D, pposition: Vector2, pscale: Vector2, pickable: bool, pz_index: int) -> Card:
	var card: Card = CARD.instantiate()	
	card.card_model = model
	card.position = pposition
	card.input_pickable = pickable
	card.z_index = pz_index
	parent.add_child(card)
	#after add_child because card._ready is called and it resets scale
	card.scale = pscale
	return card

func find_card_node(card_model: CardModel) -> Card:
	for child in card_container.get_children():
		var card: Card = child
		if card.card_model == card_model:
			return card
	for child in limbo.card_container.get_children():
		var card: Card = child
		if card.card_model == card_model:
			return card
	return null

func draw_full_hand(empty_limbo_for_each_card: bool, nightmares_enabled: bool, doors_enabled: bool):
	set_hand_freezed(true)
	while true:
		var card: Card = await draw_card(nightmares_enabled, doors_enabled)
		if card == null:
			break
		if nightmares_enabled and card.card_model.type == CardManager.CARD_TYPE.NIGHTMARE:
			AudioManager.play_nightmare_sound()
			await animate_nightmare(card)
			nightmare_panel.set_panel_enabled(true)
			exit_button.visible = false
			return
		if doors_enabled and card.card_model.type == CardManager.CARD_TYPE.DOOR:
			var key: Card = check_door_against_hand_keys(card)
			if key != null:
				await animate_door_to_open_decision(card)
				open_door_panel.key_card = key
				open_door_panel.door_card = card
				open_door_panel.set_panel_enabled(true)
				return
	if not GameManager.limbo.is_empty():
		await empty_limbo()
	set_hand_freezed(false)
	GameManager.save_game()
		
func check_door_against_hand_keys(door: Card) -> Card:
	for card_model in GameManager.hand:
		if card_model != null && card_model.type == CardManager.CARD_TYPE.KEY && card_model.color == door.card_model.color:
			return find_card_node(card_model)
	return null

func shuffle() -> void:
	AudioManager.play_shuffle_sound()
	await animate_shuffle()
	GameManager.shuffle()
	
func empty_limbo() -> void:
	var limbo_copy: Array[CardModel]
	limbo_copy.append_array(GameManager.limbo)
	#remove cards from the top one, it's visually nicer
	limbo_copy.reverse()
	for card_model in limbo_copy:
		var card: Card = find_card_node(card_model)
		await animate_card_from_limbo_to_deck(card)
		GameManager.deck_model.add_card_back(card_model)
		SignalManager.card_removed_from_limbo.emit(card)
		GameManager.limbo.erase(card_model)
		card.queue_free()
	await shuffle()
	
func card_return_to_hand(card: Card) -> void:
	card.position = hand_markers[card.hand_position].global_position
	card.rotation = hand_markers[card.hand_position].rotation
	card.z_index = card.hand_position + Constants.HAND_BASE_Z

func door_found(door_card: Card) -> void:
	AudioManager.play_door_sound()
	await animate_door_found(door_card, true)
	
func card_added_to_labyrinth(card: Card) -> void:
	GameManager.card_added_to_labyrinth(card.card_model)
	var card_model: CardModel = GameManager.check_door_found()
	if card_model != null:
		set_hand_freezed(true)
		var door_card: Card = create_card(card_model, card_container, deck.position, Card.FULL_SIZE, false, Constants.DRAGGING_BASE_Z)
		door_card.set_back_texture()		
		await door_found(door_card)
		doors_panel.set_doors_found(door_card.card_model.color, GameManager.found_doors[door_card.card_model.color].size())
		if GameManager.check_won_game():
			show_win_panel()
			return
		else:
			await shuffle()
			await draw_full_hand(true, true, true)
	else:
		await draw_full_hand(true, true, true)

func card_added_to_discard(card: Card, pdraw_card: bool) -> void:
	GameManager.card_added_to_discard(card.card_model)
	card.set_outline(false)
	if not prophecy_panel.visible and not open_door_panel.visible and not nightmare_panel.visible and card.card_model.type == CardManager.CARD_TYPE.KEY:
		open_prophecy_panel()
		return
	if pdraw_card:
		await draw_full_hand(true, true, true)

func open_prophecy_panel() -> void:
	set_hand_freezed(true)
	exit_button.visible = false
	
	#first 5 cards filling with nulls at the beginning if there aren't enough cards
	var null_cards: Array[CardModel] = [null, null, null, null, null]
	var first_5_cards: Array[CardModel] = null_cards + GameManager.deck_model.deck.slice(0, min(5,  GameManager.deck_model.get_number_of_cards()))
	first_5_cards = first_5_cards.slice(first_5_cards.size() - 5, first_5_cards.size())
	
	prophecy_panel.card_models = first_5_cards
	prophecy_panel.set_panel_enabled(true)
	var all_doors: bool = true
	for card_model in first_5_cards:
		if card_model == null:
			continue
		if card_model.type != CardManager.CARD_TYPE.DOOR:
			all_doors = false
			break
	if all_doors:
		show_lose_panel()
	
func card_added_to_limbo(card: Card) -> void:
	GameManager.card_added_to_limbo(card.card_model)

func set_hand_freezed(value: bool) -> void:
	exit_button.visible = !value
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
	if nightmare_panel.visible and nightmare_action_discard_selected != Constants.NIGHTMARE_DISCARD.NONE:
		# nightmare action was selected so we check if we should activate the action
		await handle_nightmare_action(nightmare_action_discard_selected, object)
		return
	if prophecy_panel.visible and object is Deck:
		await handle_prophecy_action()		
		return
	pass

func handle_prophecy_action() -> void:
	if ignore_gui_events:
		return
	ignore_gui_events = true
	#reorder cards and close the prophecy panel
	var card_models: Array[CardModel] = prophecy_panel.card_models
	var prophecy_cards: Array[ProphecyCard] = prophecy_panel.prophecy_cards
	
	#can't discard doors and deadends, etc
	if not card_models[4].can_discard:
		ignore_gui_events = false
		return
		
	#execute the animations
	#in this order for animation purposes
	for i in range(4, -1, -1):
		#model in the i position as ordered in the panel
		var card_model: CardModel = card_models[i]
		if card_model == null:
			#skip the empty slots
			continue
		#remove the card from the deck
		GameManager.deck_model.get_next_card()
		#let the placholder card disappear before animation
		#we don't want to animate prophecy cards that are to be used only in the panel
		prophecy_cards[i].queue_free()
		if i < 4:
			#thhe first 4 cardds from the panel go to the deck
			#create a fake card showing the back texturre moving to the deck
			var card: Card = create_card(card_model, card_container, prophecy_panel.card_markers[i].global_position, Card.FULL_SIZE, false, Constants.DRAGGING_BASE_Z)
			card.set_back_texture()
			await animate_card_to_deck(card)
			card.queue_free()
		else:
			#fifth card from the panel is to be discarded
			#we don't queue free because we keep the discarded cards visible
			var card: Card = create_card(card_model, card_container, prophecy_panel.card_position_5.global_position, Card.FULL_SIZE, false, Constants.DRAGGING_BASE_Z)
			card.set_front_texture()
			await animate_card_to_discard(card)
			SignalManager.card_added_to_discard.emit(card, false)
	
	#execute the actual deck manipulation
	#remove the discarded card from the cards to be added back to the deck
	card_models.pop_at(4)
	#add them back in the selected order in the panel
	card_models.reverse()
	for card_model in card_models:
		if card_model == null:
			continue
		GameManager.deck_model.add_card_front(card_model)
		
	prophecy_panel.set_panel_enabled(false)
	prophecy_panel.reset()
	exit_button.visible = true
	deck.set_outline(false)
	await draw_full_hand(false, true, true)
	ignore_gui_events = false
	return
	
func handle_nightmare_action(type: Constants.NIGHTMARE_DISCARD, object: Variant) -> void:
	if ignore_gui_events:
		return
	ignore_gui_events = true
	if type == Constants.NIGHTMARE_DISCARD.HAND and object is Card:
		for card_model in GameManager.hand:
			if card_model != null:
				var card: Card = find_card_node(card_model)
				await animate_card_to_discard(card)
				SignalManager.card_added_to_discard.emit(card, false)				
		await discard_nightmare_card()
		#draw with the same logic as starting the game (nightmares are not resolved, doors are not open)
		await draw_full_hand(false, false, false)
		ignore_gui_events = false
	if type == Constants.NIGHTMARE_DISCARD.KEY and object is Card:
		var card: Card = object
		if card.card_model.type == CardManager.CARD_TYPE.KEY:
			await animate_card_to_discard(card)
			SignalManager.card_added_to_discard.emit(card, false)
			await discard_nightmare_card()
			await draw_full_hand(false, true, true)
		ignore_gui_events = false
	if type == Constants.NIGHTMARE_DISCARD.DECK and object is Deck:
		for i in range(0, 5):
			if GameManager.deck_model.get_number_of_cards() == 0:
				show_lose_panel()
				return
			var card_model: CardModel = GameManager.deck_model.get_next_card()
			var card: Card = create_card(card_model, card_container, deck.position, Card.NO_SIZE, false, Constants.DRAGGING_BASE_Z)
			card.set_front_texture()
			if card_model.can_be_in_hand:
				await animate_card_to_discard(card)
				SignalManager.card_added_to_discard.emit(card, false)
			else:
				await animate_card_to_limbo(card)
				SignalManager.card_added_to_limbo.emit(card)
		await discard_nightmare_card()
		await draw_full_hand(false, true, true)
		ignore_gui_events = false
	if type == Constants.NIGHTMARE_DISCARD.DOOR and object is DoorsButton:
		var doors_button: DoorsButton = object
		var color: CardManager.CARD_COLOR = doors_button.color
		if doors_button.is_lighted() and GameManager.found_doors[color].size() > 0:
			var card_model = GameManager.found_doors[color].pop_back()
			var card: Card = create_card(card_model, card_container, Vector2(door_found_marker.position.x, doors_panel.position.y), Card.NO_SIZE, false, Constants.DRAGGING_BASE_Z)
			card.set_front_texture()
			await animate_door_discarded(card)
			SignalManager.card_added_to_limbo.emit(card)
			doors_panel.set_doors_found(color, GameManager.found_doors[color].size())
			await discard_nightmare_card()			
			await draw_full_hand(false, true, true)
		ignore_gui_events = false

func find_nightmare_card() -> Card:
	for child in card_container.get_children():
		var card: Card = child
		if card.card_model.type == CardManager.CARD_TYPE.NIGHTMARE:
			return card
	return null

func discard_nightmare_card() -> void:
	doors_panel.set_outline(false)
	nightmare_panel.reset()
	nightmare_panel.set_panel_enabled(false)
	exit_button.visible = true
	
	var card: Card = find_nightmare_card()
	await animate_card_to_discard(card)
	SignalManager.card_added_to_discard.emit(card, false)
	
func set_hand_outline(enabled: bool) -> void:
	set_cards_outline(enabled, false)

func set_keys_outline(enabled: bool) -> void:
	set_cards_outline(enabled, true)
	
func set_cards_outline(enabled: bool, keys_only: bool) -> void:
	for child in card_container.get_children():
		var card: Card = child
		if GameManager.hand.has(card.card_model):
			if not keys_only or card.card_model.type == CardManager.CARD_TYPE.KEY:
				card.set_outline(enabled)

func key_open_door_selected(type: Constants.KEY_OPEN_DOOR, key: Card, door: Card) -> void:
	if ignore_gui_events:
		return
	ignore_gui_events = true
	if type == Constants.KEY_OPEN_DOOR.DOOR:
		await animate_card_to_discard(key)
		SignalManager.card_added_to_discard.emit(key, false)
		door.z_index = Constants.DRAGGING_BASE_Z
		await door_found(door)
		GameManager.set_door_as_found(door.card_model)
		doors_panel.set_doors_found(door.card_model.color, GameManager.found_doors[door.card_model.color].size())
		open_door_panel.reset()
		open_door_panel.set_panel_enabled(false)
		if GameManager.check_won_game():
			show_win_panel()
			ignore_gui_events = false
			return
		await draw_full_hand(false, false, false)
	if type == Constants.KEY_OPEN_DOOR.LIMBO:
		await animate_card_to_limbo(door)
		SignalManager.card_added_to_limbo.emit(door)
		open_door_panel.reset()
		open_door_panel.set_panel_enabled(false)
		await draw_full_hand(false, true, true)
	ignore_gui_events = false

func deck_outline_enabled(enabled: bool) -> void:
	deck.set_outline(enabled)

func show_win_panel() -> void:
	AudioManager.play_game_victory_music()
	win_panel.visible = true
	lose_panel.visible = false
	win_lose_panel_container.visible = true
	exit_button.visible = true

func show_lose_panel() -> void:
	AudioManager.play_game_defeat_music()
	win_panel.visible = false
	lose_panel.visible = true
	win_lose_panel_container.visible = true
	exit_button.visible = true
	
####################################################
####################################################
####################################################
### Animations
####################################################
####################################################
####################################################

func animate_nightmare(card: Card) -> void:
	card.z_index = Constants.DRAGGING_BASE_Z
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(card, "position", card_presentation_marker.position, 0.2)
	tween.parallel().tween_property(card, "rotation_degrees", 360, 0.2)
	tween.parallel().tween_property(card, "scale", Vector2(1.3,1.3), 0.2)
	await tween.finished
	
func animate_door_found(card: Card, from_deck: bool) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(card, "position", door_found_marker.position, 0.5)
	if from_deck:
		tween.tween_property(card, "scale", Vector2(0,1), 0.2)
	if not from_deck:
		tween.parallel().tween_property(card, "rotation_degrees", 0, 0.2)
	tween.tween_callback(card.set_front_texture)
	tween.tween_property(card, "scale", Vector2(1.5,1.5), 0.1)
	tween.tween_interval(0.5)
	tween.tween_property(card, "position", Vector2(door_found_marker.position.x, doors_panel.position.y), 0.1)
	tween.parallel().tween_property(card, "scale", Vector2(0, 0), 0.1)
	await tween.finished
	card.queue_free()
	
func animate_door_to_open_decision(card: Card) -> void:
	card.z_index = Constants.DRAGGING_BASE_Z
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(card, "position", card_presentation_marker.position, 0.3)
	tween.parallel().tween_property(card, "scale", Vector2(1.2,1.2), 0.3)
	tween.parallel().tween_property(card, "rotation_degrees", 0, 0.3)
	await tween.finished

func animate_door_discarded(card: Card) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(card, "position", door_found_marker.position, 0.2)
	tween.parallel().tween_property(card, "scale", Vector2(1.5,1.5), 0.2)
	tween.tween_interval(0.5)
	await tween.finished
	await animate_card_to_limbo(card)
		
func animate_shuffle() -> void:
	var cards: Array[Card]
	#we should have at least one card
	#we could use a fake model here as we only use the back texture
	var card_model: CardModel = GameManager.deck_model.deck[0]
	#move randomnly some cards
	for i in range(0, 4):
		var card: Card = create_card(card_model, deck, Vector2.ZERO, Card.FULL_SIZE, false, 1)
		card.set_back_texture()
		cards.push_back(card)
	var tweens: Array[Tween]
	for card in cards:
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
		tween.tween_property(card, "position", Vector2(randf_range(-offset,offset),randf_range(-offset,offset)), duration)
		tween.tween_property(card, "position", Vector2.ZERO, duration)
		tweens.push_back(tween)
	for tween in tweens:
		await tween.finished
	for card in cards:
		card.queue_free()
	
func animate_card_draw(card: Card) -> void:
	card.z_index = card.hand_position + Constants.HAND_BASE_Z
	card.position = deck.position
	card.rotation = hand_markers[card.hand_position].rotation
	var tween: Tween = get_tree().create_tween()
	tween.parallel().tween_property(card, "position", hand_markers[card.hand_position].global_position, 0.2)
	tween.parallel().tween_property(card, "scale", Vector2(0,1), 0.2)
	tween.tween_callback(card.set_front_texture)
	tween.tween_property(card, "scale", Vector2(1,1), 0.1)
	await tween.finished

func animate_card_to_limbo(card: Card) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(card, "global_position", limbo.global_position, 0.2)
	tween.parallel().tween_property(card, "scale", Card.LIMBO_SIZE, 0.2)
	await tween.finished

func animate_card_to_discard(card: Card) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(card, "global_position", discard.global_position, 0.2)
	tween.parallel().tween_property(card, "scale", Card.DISCARD_SIZE, 0.2)
	await tween.finished
	
func animate_card_from_limbo_to_deck(card: Card) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.parallel().tween_property(card, "global_position", deck.global_position, 0.2)
	tween.parallel().tween_property(card, "scale", Vector2(0,1), 0.2)
	tween.parallel().tween_property(card, "rotation", 0, 0.2)
	tween.tween_callback(card.set_back_texture)
	tween.tween_property(card, "scale", Vector2(1,1), 0.1)
	await tween.finished
	
func animate_card_to_deck(card: Card) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(card, "global_position", deck.global_position, 0.2)
	await tween.finished

func _on_discard_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventScreenTouch:
		discard_panel.clear_counters()
		discard_panel.setup()
		discard_panel_container.visible = true

func discard_panel_closed() -> void:
	discard_panel_container.visible = false

func _on_exit_button_pressed() -> void:
	AudioManager.play_uiclick_sound()
	if win_panel.visible or lose_panel.visible:
		GameManager.delete_save_file()
	else:
		GameManager.save_game()
	SceneManager.switch_to_menu()

func recreate_game_objects() -> void:
	for child in card_container.get_children():
		child.queue_free()
	for child in limbo.card_container.get_children():
		child.queue_free()
	for child in discard.card_container.get_children():
		child.queue_free()
	for child in $Labyrinth/CardContainer.get_children():
		child.queue_free()
		
	doors_panel.setup(GameManager.doors_to_be_found)
	for color in GameManager.found_doors.keys():
		doors_panel.set_doors_found(color, GameManager.found_doors[color].size())
		
	for i in range(GameManager.hand.size()):
		var c_model = GameManager.hand[i]
		if c_model != null:
			var card = create_card(c_model, card_container, hand_markers[i].global_position, Card.FULL_SIZE, true, i + Constants.HAND_BASE_Z)
			card.set_front_texture()
			card.hand_position = i
			card.rotation = hand_markers[i].rotation
			card.freezed = false
			
	for i in range(GameManager.limbo.size()):
		var c_model = GameManager.limbo[i]
		var card = create_card(c_model, limbo.card_container, Vector2.ZERO, Card.LIMBO_SIZE, false, i + Constants.LIMBO_BASE_Z)
		card.set_front_texture()

	for i in range(GameManager.discard.size()):
		var c_model = GameManager.discard[i]
		var card = create_card(c_model, discard.card_container, Vector2.ZERO, Card.DISCARD_SIZE, false, i + Constants.DISCARD_BASE_Z)
		card.set_front_texture()

	labyrinth.card_container.global_position.x = 0
	for i in range(GameManager.labyrinth.size()):
		var c_model = GameManager.labyrinth[i]
		var card = create_card(c_model, labyrinth.card_container, labyrinth.start_position_marker.position + Vector2(i * labyrinth.CARD_OFFSET, 0), Card.LABYRINTH_SIZE, false, i + Constants.LABYRINTH_BASE_Z)
		card.set_front_texture()
	if GameManager.labyrinth.size() >= labyrinth.MAX_SIZE:
		labyrinth.card_container.global_position.x = -labyrinth.CARD_OFFSET * (GameManager.labyrinth.size() - labyrinth.MAX_SIZE)
		
	SignalManager.deck_updated.emit()
