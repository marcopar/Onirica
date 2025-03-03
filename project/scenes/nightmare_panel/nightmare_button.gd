extends Node2D

@onready var icon: Sprite2D = $Icon

@export var texture: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	icon.texture = texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
