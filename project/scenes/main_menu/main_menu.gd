extends Control

class_name MainMenu

const MAIN = preload("uid://bqghirh8g0ov4")

func _ready() -> void:
	AudioManager.play_menu_music()
			
func _on_new_game_pressed() -> void:
	AudioManager.play_game_music()
	SceneManager.switch_to_game()

func _on_credits_pressed() -> void:
	SceneManager.switch_to_credits()
