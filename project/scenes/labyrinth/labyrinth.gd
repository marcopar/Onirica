extends Area2D

class_name Labyrinth

const CARD_OFFSET: int = 55
const MAX_SIZE: int = 11

@onready var card_container: Node2D = $CardContainer
@onready var start_position_marker: Marker2D = $StartPosition
@onready var highlight: PointLight2D = $Highlight

var initial_global_position: Vector2
var labyrinth_dragging: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	SignalManager.new_game.connect(new_game)
	initial_global_position = global_position
	SignalManager.card_added_to_labyrinth.connect(card_added_to_labyrinth)
	SignalManager.card_return_to_hand.connect(card_return_to_hand)

func new_game() -> void:
	global_position = initial_global_position

func card_added_to_labyrinth(card: Card) -> void:
	highlight.enabled = false
	card.set_labyrinth_size()
	card.position = start_position_marker.position
	card.position.x += CARD_OFFSET * GameManager.labyrinth.size()
	card.z_index = GameManager.labyrinth.size() + Constants.LABYRINTH_BASE_Z
	card.input_pickable = false
	card.get_parent().remove_child(card)
	card_container.add_child(card)
	if GameManager.labyrinth.size() >= MAX_SIZE:
		card_container.global_position.x = -CARD_OFFSET * (GameManager.labyrinth.size() - MAX_SIZE)
	
func _on_area_entered(area: Area2D) -> void:
	if area is Card:
		var card: Card = area
		if card.dragging:
			highlight.enabled = true

func _on_area_exited(area: Area2D) -> void:
	if area is Card:
		var card: Card = area
		if card.dragging:
			highlight.enabled = false
			
func card_return_to_hand(card: Card) -> void:
	highlight.enabled = false


func _on_scroll_input_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventScreenTouch:
		labyrinth_dragging = event.pressed
		pass
	if event is InputEventScreenDrag:
		if labyrinth_dragging:
			card_container.global_position.x += event.relative.x
		pass
