extends Area2D

class_name DraggableSprite

@onready var sprite_2d: Sprite2D = $Sprite2D

const DEAD_ZONE: float = 20

var freezed: bool = false:
	get:
		return freezed
	set(value):
		freezed = value
		
var dragging: bool = false
var drag_start: Vector2 = Vector2.INF

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func set_outline(enabled: bool) -> void:
	##the shader has an instance parameter to enable it or not on the single card
	sprite_2d.set_instance_shader_parameter("enabled", enabled)
	
func _notification(what : int):
	if dragging and what == NOTIFICATION_WM_MOUSE_EXIT:
		abort_dragging_action()

func _input(event: InputEvent) -> void:
	if dragging and event is InputEventScreenTouch:
		get_viewport().set_input_as_handled()
		var touch_event: InputEventScreenTouch = event
		handle_dragging_touch_event(touch_event)
		
	if dragging and event is InputEventScreenDrag:
		get_viewport().set_input_as_handled()
		var drag_event: InputEventScreenDrag = event
		if drag_event.index > 0:
			return
		if not get_viewport_rect().has_point(drag_event.position):
			abort_dragging_action()
			return
		if not drag_start.is_finite():
			drag_start = drag_event.position
		handle_position_update(drag_event)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventScreenTouch:
		get_viewport().set_input_as_handled()
		var touch_event: InputEventScreenTouch = event
		handle_dragging_touch_event(touch_event)

func is_no_movement() -> bool:
	var delta: Vector2 = abs(drag_start - position)
	return (not drag_start.is_finite() or delta.length() < DEAD_ZONE) and not dragging
	
func can_drag() -> bool:
	return true
	
func abort_dragging_action() -> void:
	dragging = false
	drag_start = Vector2.INF

func touch_action() -> void:
	return

func handle_overlapping_areas() -> bool:
	return false

func handle_position_update(drag_event: InputEventScreenDrag) -> void:
	z_index = Constants.DRAGGING_BASE_Z
	global_position = drag_event.position
	rotation = 0

func handle_dragging_touch_event(touch_event: InputEventScreenTouch) -> void:
	if touch_event.index > 0:
		return
	if dragging and touch_event.pressed:
		return
	dragging = touch_event.pressed and can_drag() and not freezed
	if(not touch_event.pressed):
		if is_no_movement():
			if not freezed:
				# a freezed card is typically the nightmare card currently being resolved
				# it's not dragging for sure and it should not go back in hand as abort_dragging dose
				abort_dragging_action()
			touch_action()
			return
		if handle_overlapping_areas():
			return
		abort_dragging_action()
