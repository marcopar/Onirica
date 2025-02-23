extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var texture: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_2d.texture = texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
