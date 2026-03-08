extends Area2D

class_name Limbo

@onready var card_container: Node2D = $CardContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.card_added_to_limbo.connect(card_added_to_limbo)
	SignalManager.card_removed_from_limbo.connect(card_removed_from_limbo)

func card_added_to_limbo(card: Card) -> void:
	card.set_limbo_size()
	card.hand_position = -1
	card.position = Vector2.ZERO
	card.z_index = GameManager.limbo.size() + Constants.LIMBO_BASE_Z
	card.input_pickable = false
	card.get_parent().remove_child(card)
	card_container.add_child(card)

func card_removed_from_limbo(card: Card) -> void:
	card_container.remove_child(card)
