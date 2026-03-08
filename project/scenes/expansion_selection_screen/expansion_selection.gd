extends Control

class_name ExpansionSelection

@onready var the_glyphs: Button = $"GUI/VBoxContainer/MainArea/MarginContainer/VBoxContainer/The Glyphs"

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
	
func update_labels() -> void:
	if GameManager.the_glyphs_on == false:
		the_glyphs.text = "THE GLYPHS OFF"
	else:
		the_glyphs.text = "THE GLYPHS ON"
	
func _on_start_game_pressed() -> void:
	AudioManager.play_uiclick_sound()
	GameManager.new_game()
	SceneManager.switch_to_game()
