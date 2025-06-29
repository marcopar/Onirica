extends RoundButton

class_name NightmareButton

@export var type: Constants.NIGHTMARE_DISCARD

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	super._on_input_event(viewport, event, shape_idx)
	if not enabled:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			SignalManager.nightmare_button_selected.emit(type, selected)
