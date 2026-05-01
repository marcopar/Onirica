extends RoundButton

class_name EscapeButton

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not enabled:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			SignalManager.escape_selected.emit()
