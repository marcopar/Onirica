extends Node

const A_FRIENDLY_GHOST_MINIMAL_LOOP: AudioStream = preload("uid://bmcarumq7d1wr")
const DEPTH_OF_DESPAIR: AudioStream = preload("uid://370atk33a0md")
const THE_CHAMBER_OF_CELESTIAL_PEACE_LOOP: AudioStream = preload("uid://dffeunjcddtd2")
const RAIN_IN_SPACE_LOOP: AudioStream = preload("uid://bormr4tjpapnh")
const CARD_SHUFFLE_FAST: AudioStream = preload("uid://d2ln1tkxv7o6y")
const CARD_PLAYED_CUT: AudioStream = preload("uid://8632hhr20814")
const NIGHTMARE_FOUND_SPELL: AudioStream = preload("uid://dw8v2hohco6w5")
const DOOR_FOUND_HEAL: AudioStream = preload("uid://dv7i3551q7tvh")
const UI_CLICK_7: AudioStream = preload("uid://dhnx31h21lc1g")


func _ready() -> void:
	SoundManager.set_default_music_bus("Music")
	SoundManager.set_default_sound_bus("Sound")
	SoundManager.set_default_ambient_sound_bus("Sound")
	SoundManager.set_default_ui_sound_bus("Sound")
	SignalManager.card_added_to_labyrinth.connect(card_added_to_labyrinth)
	SignalManager.card_added_to_discard.connect(card_added_to_discard)
	SignalManager.card_added_to_limbo.connect(card_added_to_limbo)
	
	SettingsManager.load_config()
	if SettingsManager.music_on:
		set_music_volume(1)
	else:
		set_music_volume(0)
	if SettingsManager.sound_on:
		set_sound_volume(1)
	else:
		set_sound_volume(0)
		
	pass
	
func set_music_volume(value: float) -> void:
	SoundManager.set_music_volume(value)

func get_music_volume() -> float:
	return SoundManager.get_music_volume()
	
func set_sound_volume(value: float) -> void:
	SoundManager.set_sound_volume(value)

func get_sound_volume() -> float:
	return SoundManager.get_sound_volume()

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
	SoundManager.play_sound(CARD_SHUFFLE_FAST)
	
func play_nightmare_sound() -> void:
	SoundManager.play_sound(NIGHTMARE_FOUND_SPELL)

func play_door_sound() -> void:
	SoundManager.play_sound(DOOR_FOUND_HEAL)
	
func play_uiclick_sound() -> void:
	SoundManager.play_sound(UI_CLICK_7)

func card_added_to_labyrinth(card: Card) -> void:
	play_card_played_sound()

func card_added_to_discard(card: Card, draw_card: bool) -> void:
	play_card_played_sound()
	
func card_added_to_limbo(card: Card) -> void:
	play_card_played_sound()
