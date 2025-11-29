extends Node

const RAIN_IN_SPACE_LOOP = preload("uid://cm1m3qxvgvd8n")
const DEPTH_OF_DESPAIR = preload("uid://0f5p0ho02rdq")
const A_FRIENDLY_GHOST_MINIMAL_LOOP = preload("uid://dgdxm3uet14ff")
const THE_CHAMBER_OF_CELESTIAL_PEACE_LOOP = preload("uid://bsuxeu02y5m2m")

func _ready() -> void:
	pass
	
func play_menu_music() -> void:
	SoundManager.play_music(A_FRIENDLY_GHOST_MINIMAL_LOOP, 1)
	
func play_game_music() -> void:
	SoundManager.play_music(THE_CHAMBER_OF_CELESTIAL_PEACE_LOOP, 1)
	
func play_game_victory_music() -> void:
	SoundManager.play_music(RAIN_IN_SPACE_LOOP, 1)
	
func play_game_defeat_music() -> void:
	SoundManager.play_music(DEPTH_OF_DESPAIR, 1)
