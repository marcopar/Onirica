extends Node2D

class_name NightmarePanel

@onready var button_discard_deck: NightmareButton = $ButtonDiscardDeck
@onready var button_discard_door: NightmareButton = $ButtonDiscardDoor
@onready var button_discard_hand: NightmareButton = $ButtonDiscardHand
@onready var button_discard_key: NightmareButton = $ButtonDiscardKey

var buttons: Array[NightmareButton] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buttons.push_back(button_discard_deck)
	buttons.push_back(button_discard_door)
	buttons.push_back(button_discard_hand)
	buttons.push_back(button_discard_key)
	SignalManager.nightmare_button_selected.connect(nightmare_button_selected)
	
func nightmare_button_selected(type: Constants.NIGHTMARE_DISCARD, selected: bool) -> void:
	#ignore deselect signals
	if selected:
		#deselect all other buttons
		for button in buttons:
			if button.type != type:
				button.selected = false
		SignalManager.nightmare_action_selected.emit(type)
	else:
		SignalManager.nightmare_action_selected.emit(Constants.NIGHTMARE_DISCARD.NONE)

func reset() -> void:
	SignalManager.nightmare_action_selected.emit(Constants.NIGHTMARE_DISCARD.NONE)
	for button in buttons:
		button.selected = false


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass # Replace with function body.
