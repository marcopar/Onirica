extends Area2D

class_name Discard

@onready var card_container: Node2D = $CardContainer
@onready var highlight: PointLight2D = $Highlight

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.card_return_to_hand.connect(card_return_to_hand)
	SignalManager.card_added_to_discard.connect(card_added_to_discard)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
		
func card_added_to_discard(card: Card) -> void:
	highlight.enabled = false
	card.hand_position = -1
	card.set_discard_size()
	card.position = Vector2.ZERO
	card.z_index = GameManager.discard.size() + Constants.DISCARD_BASE_Z
	card.input_pickable = false
	card.get_parent().remove_child(card)
	card_container.add_child(card)


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
