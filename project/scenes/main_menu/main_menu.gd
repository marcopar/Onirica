extends Control

class_name MainMenu

func _ready() -> void:	
	AudioManager.play_menu_music()
			
func _on_new_game_pressed() -> void:
	AudioManager.play_uiclick_sound()
	AudioManager.play_game_music()
	SceneManager.switch_to_game()

func _on_credits_pressed() -> void:
	AudioManager.play_uiclick_sound()
	SceneManager.switch_to_credits()

func _on_settings_pressed() -> void:
	AudioManager.play_uiclick_sound()
	SceneManager.switch_to_settings()
