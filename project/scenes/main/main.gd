extends Node2D

@onready var hand_marker_1: Marker2D = $HandMarkers/HandMarker1
@onready var hand_marker_2: Marker2D = $HandMarkers/HandMarker2
@onready var hand_marker_3: Marker2D = $HandMarkers/HandMarker3
@onready var hand_marker_4: Marker2D = $HandMarkers/HandMarker4
@onready var hand_marker_5: Marker2D = $HandMarkers/HandMarker5
@onready var deck: Deck = $Deck
@onready var limbo: Limbo = $Limbo
@onready var card_container: Node2D = $CardContainer

const CARD = preload("res://scenes/card/card.tscn")

var hand_markers: Array[Marker2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.card_return_to_hand.connect(card_return_to_hand)
	SignalManager.card_added_to_discard.connect(card_added_to_discard)
	SignalManager.card_added_to_labyrinth.connect(card_added_to_labyrinth)
	hand_markers.push_back(hand_marker_1)
	hand_markers.push_back(hand_marker_2)
	hand_markers.push_back(hand_marker_3)
	hand_markers.push_back(hand_marker_4)
	hand_markers.push_back(hand_marker_5)
	get_viewport().physics_object_picking_sort = true
	GameManager.new_game()
	while await draw_card(false):
		pass
	if not GameManager.limbo.is_empty():
		empty_limbo()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func draw_card(empty_limbo_enabled: bool) -> bool:
	var card_drawn: bool = false
	for hand_position in range(0, GameManager.HAND_SIZE):
		if not GameManager.hand[hand_position] == null:
			continue
		while GameManager.hand[hand_position] == null:
			if GameManager.deck_model.get_number_of_cards() == 0:
				return false
			var card_model: CardModel = GameManager.deck_model.get_next_card()
			var card: Card = CARD.instantiate()
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
				await animate_card_to_limbo(card)
				SignalManager.card_added_to_limbo.emit(card)
		if empty_limbo_enabled and not GameManager.limbo.is_empty():
			empty_limbo()
		return card_drawn
	return false

func empty_limbo() -> void:
	var limbo_copy: Array[Card]
	limbo_copy.append_array(GameManager.limbo)
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
	draw_card(true)

func card_added_to_discard(card: Card) -> void:
	draw_card(true)

func animate_shuffle() -> void:
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
	
func animate_card_from_limbo_to_deck(card: Card) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.parallel().tween_property(card, "global_position", deck.global_position, 0.2)
	tween.parallel().tween_property(card, "scale", Vector2(0,1), 0.2)
	tween.parallel().tween_property(card, "rotation", 0, 0.2)
	tween.tween_callback(card.set_back_texture)
	tween.tween_property(card, "scale", Vector2(1,1), 0.1)
	await tween.finished
