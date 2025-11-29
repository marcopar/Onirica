extends Node

const A_FRIENDLY_GHOST_MINIMAL_LOOP = preload("uid://bmcarumq7d1wr")
const DEPTH_OF_DESPAIR = preload("uid://370atk33a0md")
const THE_CHAMBER_OF_CELESTIAL_PEACE_LOOP = preload("uid://dffeunjcddtd2")
const RAIN_IN_SPACE_LOOP = preload("uid://bormr4tjpapnh")


func _ready() -> void:
	pass
	
func play_menu_music() -> void:
	SoundManager.play_music(A_FRIENDLY_GHOST_MINIMAL_LOOP, 1)
	
func play_game_music() -> void:
	SoundManager.play_music_from_position(THE_CHAMBER_OF_CELESTIAL_PEACE_LOOP, 8, 2)
	
func play_game_victory_music() -> void:
	SoundManager.play_music(RAIN_IN_SPACE_LOOP, 1)
	
func play_game_defeat_music() -> void:
	SoundManager.play_music(DEPTH_OF_DESPAIR, 1)
