extends Node2D

class_name NightmarePanel

@onready var button_discard_deck: RoundButton = $ButtonDiscardDeck
@onready var button_discard_door: RoundButton = $ButtonDiscardDoor
@onready var button_discard_hand: RoundButton = $ButtonDiscardHand
@onready var button_discard_key: RoundButton = $ButtonDiscardKey

var buttons: Array[RoundButton] = []

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
		
func set_panel_enabled(enabled: bool) -> void:
	visible = enabled
	if visible:
		process_mode = Node.PROCESS_MODE_INHERIT
	else:
		process_mode = Node.PROCESS_MODE_DISABLED
