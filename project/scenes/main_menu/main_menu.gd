extends Control

class_name MainMenu

@onready var resume_game: Button = $VBoxContainer/ResumeGame

func _ready() -> void:	
	AudioManager.play_menu_music()
	resume_game.visible = GameManager.save_file_exists()
			
func _on_new_game_pressed() -> void:
	AudioManager.play_uiclick_sound()
	GameManager.new_game()
	AudioManager.play_game_music()
	SceneManager.switch_to_game()
	
func _on_resume_game_pressed() -> void:
	AudioManager.play_uiclick_sound()
	GameManager.load_game()
	AudioManager.play_game_music()
	SceneManager.switch_to_game()

func _on_credits_pressed() -> void:
	AudioManager.play_uiclick_sound()
	SceneManager.switch_to_credits()

func _on_settings_pressed() -> void:
	AudioManager.play_uiclick_sound()
	SceneManager.switch_to_settings()
