extends Control

class_name MainMenu

const MAIN = preload("uid://bqghirh8g0ov4")

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_packed(MAIN)
