extends Control

class_name MainMenu

const MAIN = preload("uid://bqghirh8g0ov4")

func _on_new_game_pressed() -> void:
	SceneManager.switch_to_game()
