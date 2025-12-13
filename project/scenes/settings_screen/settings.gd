extends Control

class_name Settings

@onready var music: Button = $GUI/VBoxContainer/MainArea/MarginContainer/VBoxContainer/Music
@onready var sound_effects: Button = $GUI/VBoxContainer/MainArea/MarginContainer/VBoxContainer/SoundEffects

func _ready() -> void:
	update_labels()
			
func _on_exit_button_pressed() -> void:
	AudioManager.play_uiclick_sound()
	SceneManager.switch_to_menu()

func _on_music_pressed() -> void:
	AudioManager.play_uiclick_sound()
	if AudioManager.get_music_volume() != 0:
		AudioManager.set_music_volume(0)
	else:
		AudioManager.set_music_volume(1)
	update_labels()

func _on_sound_effects_pressed() -> void:
	AudioManager.play_uiclick_sound()
	if AudioManager.get_sound_volume() != 0:
		AudioManager.set_sound_volume(0)
	else:
		AudioManager.set_sound_volume(1)
	update_labels()

func update_labels() -> void:
	if AudioManager.get_music_volume() == 0:
		music.text = "MUSIC OFF"
	else:
		music.text = "MUSIC ON"
		
	if AudioManager.get_sound_volume() == 0:
		sound_effects.text = "SOUND EFFECTS OFF"
	else:
		sound_effects.text = "SOUND EFFECTS ON"
