extends Node2D

class_name OpenDoorPanel

var key_dragging: bool = false

var key_card: Card:
	get:
		return key_card
	set(value):
		key_card = value
		
var door_card: Card:
	get:
		return door_card
	set(value):
		door_card = value
		
@onready var door: RoundButton = $Door
@onready var limbo: RoundButton = $Limbo
@onready var key: Area2D = $Key

var buttons: Array[RoundButton] = []

func _ready() -> void:
	buttons.push_back(door)
	buttons.push_back(limbo)

func _on_control_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		key_dragging = event.pressed
		if key_dragging == false:
			if door.selected:
				SignalManager.key_open_door_selected.emit(Constants.KEY_OPEN_DOOR.DOOR, key_card, door_card)
				return
			if limbo.selected:
				SignalManager.key_open_door_selected.emit(Constants.KEY_OPEN_DOOR.LIMBO, key_card, door_card)
				return
			key.position.x = 0
		pass
	if event is InputEventScreenDrag:
		if key_dragging:
			key.position.x += event.relative.x
		pass

func _on_key_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area == door:
		door.selected = true
		return
	if area == limbo:
		limbo.selected = true
		return
		
func _on_key_area_shape_exited(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area == door:
		door.selected = false
		return
	if area == limbo:
		limbo.selected = false
		return

func set_panel_enabled(enabled: bool) -> void:
	visible = enabled
	if visible:
		process_mode = Node.PROCESS_MODE_INHERIT
	else:
		process_mode = Node.PROCESS_MODE_DISABLED
	
func reset() -> void:
	key.position = Vector2.ZERO
	key_card = null
	door_card = null
	for button in buttons:
		button.selected = false
