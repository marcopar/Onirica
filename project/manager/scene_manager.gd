extends Node

func switch_to_game() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
	
func switch_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")

func switch_to_credits() -> void:
	get_tree().change_scene_to_file("res://scenes/credits_screen/credits.tscn")
