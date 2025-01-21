extends Node2D

class_name DoorsPanel

@onready var door_container: Node2D = $Background/DoorContainer

const RED_DOOR = preload("res://assets/sprites/cards/red_door.png")
const GREEN_DOOR = preload("res://assets/sprites/cards/green_door.png")
const BLUE_DOOR = preload("res://assets/sprites/cards/blue_door.png")
const YELLOW_DOOR = preload("res://assets/sprites/cards/yellow_door.png")

const DOOR_TEXTURES: Dictionary = {
	CardManager.CARD_COLOR.RED: RED_DOOR,
	CardManager.CARD_COLOR.GREEN: GREEN_DOOR,
	CardManager.CARD_COLOR.BLUE: BLUE_DOOR,
	CardManager.CARD_COLOR.YELLOW: YELLOW_DOOR,
}
const DOOR_COLORS_8: Array = [
	CardManager.CARD_COLOR.RED, CardManager.CARD_COLOR.RED, 
	CardManager.CARD_COLOR.GREEN, CardManager.CARD_COLOR.GREEN, 
	CardManager.CARD_COLOR.BLUE, CardManager.CARD_COLOR.BLUE, 
	CardManager.CARD_COLOR.YELLOW, CardManager.CARD_COLOR.YELLOW
]
const DOOR_COLORS_12: Array = [
	CardManager.CARD_COLOR.RED, CardManager.CARD_COLOR.RED, CardManager.CARD_COLOR.RED, 
	CardManager.CARD_COLOR.GREEN, CardManager.CARD_COLOR.GREEN, CardManager.CARD_COLOR.GREEN, 
	CardManager.CARD_COLOR.BLUE, CardManager.CARD_COLOR.BLUE, CardManager.CARD_COLOR.BLUE, 
	CardManager.CARD_COLOR.YELLOW, CardManager.CARD_COLOR.YELLOW, CardManager.CARD_COLOR.YELLOW
]

const MAX_DOORS: int = 12
var doors: int

func setup(doors: int):
	self.doors = doors
	
	for i in range(1, MAX_DOORS):
		var node: Sprite2D = door_container.find_child(str("D", i))
		node.visible = false
		
	if doors == 8:
		var first_door: int = 3
		for i in range(first_door, MAX_DOORS - 1):
			var node: Sprite2D = door_container.find_child(str("D", i))
			node.visible = true
			node.texture = DOOR_TEXTURES[DOOR_COLORS_8[i-first_door]]
	
	if doors == 12:
		var first_door: int = 1
		for i in range(first_door, MAX_DOORS + 1):
			var node: Sprite2D = door_container.find_child(str("D", i))
			node.visible = true
			node.texture = DOOR_TEXTURES[DOOR_COLORS_12[i-first_door]]
		
		
func set_doors_found(color: CardManager.CARD_COLOR, door_count: int, value: bool):
	if doors == 8:
		var first_door: int = 3 + DOOR_COLORS_8.find(color) - 1
		for i in range(first_door, first_door + door_count):
			var node: Sprite2D = door_container.find_child(str("D", i))
			node.self_modulate = Color(1,1,1,1)
		pass
	if doors == 12:
		var first_door: int = 1
		pass
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
