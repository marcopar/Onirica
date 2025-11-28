extends Control

class_name MainMenu

const MAIN = preload("uid://bqghirh8g0ov4")

func _ready() -> void:
	SoundManager.play_music(Constants.A_FRIENDLY_GHOST_MINIMAL_LOOP, 2)
			
func _on_new_game_pressed() -> void:
	SoundManager.play_music(Constants.THE_CHAMBER_OF_CELESTIAL_PEACE_LOOP, 2)
	SceneManager.switch_to_game()

func _on_credits_pressed() -> void:
	SceneManager.switch_to_credits()
