extends Node

func switch_to_game() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
	
func switch_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")

func switch_to_credits() -> void:
	get_tree().change_scene_to_file("res://scenes/credits_screen/credits.tscn")
	
func switch_to_settings() -> void:
	get_tree().change_scene_to_file("res://scenes/settings_screen/settings.tscn")
	
func switch_to_rules_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/rules_screen/rules_menu.tscn")
	
func switch_to_rules_base() -> void:
	get_tree().change_scene_to_file("res://scenes/rules_screen/rules_base.tscn")

func switch_to_rules_the_glyphs() -> void:
	get_tree().change_scene_to_file("res://scenes/rules_screen/rules_the_glyphs.tscn")
	
func switch_to_rules_crossroads_and_dead_ends() -> void:
	get_tree().change_scene_to_file("res://scenes/rules_screen/rules_crossroads_and_dead_ends.tscn")
	
func switch_to_expansion_selection() -> void:
	get_tree().change_scene_to_file("res://scenes/expansion_selection_screen/expansion_selection.tscn")
