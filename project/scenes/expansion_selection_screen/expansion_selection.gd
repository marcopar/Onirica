extends Control

class_name ExpansionSelection

@onready var the_glyphs: Button = $"GUI/VBoxContainer/MainArea/MarginContainer/VBoxContainer/TheGlyphs"
@onready var crossroads_and_ded_ends: Button = $GUI/VBoxContainer/MainArea/MarginContainer/VBoxContainer/CrossroadsAndDedEnds
@onready var intersections: Button = $GUI/VBoxContainer/MainArea/MarginContainer/VBoxContainer/Intersections

func _ready() -> void:
	update_labels()
			
func _on_exit_button_pressed() -> void:	
	AudioManager.play_uiclick_sound()
	SceneManager.switch_to_menu()

func _on_the_glyphs_pressed() -> void:
	AudioManager.play_uiclick_sound()
	if GameManager.the_glyphs_on:
		GameManager.the_glyphs_on = false
	else:
		GameManager.the_glyphs_on = true
	update_labels()
	
func _on_crossroads_and_ded_ends_pressed() -> void:
	AudioManager.play_uiclick_sound()
	if GameManager.crossroads_and_dead_ends_on:
		GameManager.crossroads_and_dead_ends_on = false
		GameManager.intersections_on = false
	else:
		GameManager.crossroads_and_dead_ends_on = true
	update_labels()

func _on_intersections_pressed() -> void:
	AudioManager.play_uiclick_sound()
	if GameManager.intersections_on:
		GameManager.intersections_on = false
	else:
		GameManager.intersections_on = true
	update_labels()
	
func update_labels() -> void:
	if GameManager.the_glyphs_on == false:
		the_glyphs.modulate.v = 0.7
	else:
		the_glyphs.modulate.v = 1
		
	if GameManager.crossroads_and_dead_ends_on == false:
		crossroads_and_ded_ends.modulate.v = 0.7
		intersections.visible = false
	else:
		crossroads_and_ded_ends.modulate.v = 1
		intersections.visible = true
		
	if GameManager.intersections_on == false:
		intersections.modulate.v = 0.7
	else:
		intersections.modulate.v = 1
	
func _on_start_game_pressed() -> void:
	AudioManager.play_uiclick_sound()
	GameManager.new_game()
	SceneManager.switch_to_game()
