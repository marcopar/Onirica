extends Node

const A_FRIENDLY_GHOST_MINIMAL_LOOP: AudioStream = preload("uid://bmcarumq7d1wr")
const DEPTH_OF_DESPAIR: AudioStream = preload("uid://370atk33a0md")
const THE_CHAMBER_OF_CELESTIAL_PEACE_LOOP: AudioStream = preload("uid://dffeunjcddtd2")
const RAIN_IN_SPACE_LOOP: AudioStream = preload("uid://bormr4tjpapnh")
const CARD_SHUFFLE_SAND: AudioStream = preload("uid://c8pe42meocepm")
const CARD_PLAYED_CUT: AudioStream = preload("uid://8632hhr20814")


func _ready() -> void:
	SignalManager.card_added_to_labyrinth.connect(card_added_to_labyrinth)
	pass
	
func play_menu_music() -> void:
	SoundManager.play_music(A_FRIENDLY_GHOST_MINIMAL_LOOP, 1)
	
func play_game_music() -> void:
	SoundManager.play_music_from_position(THE_CHAMBER_OF_CELESTIAL_PEACE_LOOP, 8, 2)
	
func play_game_victory_music() -> void:
	SoundManager.play_music(RAIN_IN_SPACE_LOOP, 1)
	
func play_game_defeat_music() -> void:
	SoundManager.play_music(DEPTH_OF_DESPAIR, 1)

func play_card_played_sound() -> void:
	SoundManager.play_sound(CARD_PLAYED_CUT)
	
func play_shuffle_sound() -> void:
	SoundManager.play_sound(CARD_SHUFFLE_SAND)

func card_added_to_labyrinth(card: Card) -> void:
	play_card_played_sound()
