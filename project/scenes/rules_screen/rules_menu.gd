extends Control

class_name RulesMenu

func _on_base_game_pressed() -> void:
	AudioManager.play_uiclick_sound()
	SceneManager.switch_to_rules_base()


func _on_the_glyphs_pressed() -> void:
	AudioManager.play_uiclick_sound()
	SceneManager.switch_to_rules_the_glyphs()


func _on_exit_button_pressed() -> void:
	AudioManager.play_uiclick_sound()
	SceneManager.switch_to_menu()

func _on_crossroads_and_dead_ends_pressed() -> void:
	AudioManager.play_uiclick_sound()
	SceneManager.switch_to_rules_crossroads_and_dead_ends()
