extends Control

class_name Rules

func _on_exit_button_pressed() -> void:	
	AudioManager.play_uiclick_sound()
	SceneManager.switch_to_menu()
	
