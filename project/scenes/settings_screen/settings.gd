extends Control

class_name Settings

@onready var music: Button = $GUI/VBoxContainer/MainArea/MarginContainer/VBoxContainer/Music
@onready var sound_effects: Button = $GUI/VBoxContainer/MainArea/MarginContainer/VBoxContainer/SoundEffects
@onready var color_blind: Button = $GUI/VBoxContainer/MainArea/MarginContainer/VBoxContainer/ColorBlind

func _ready() -> void:
	update_labels()
			
func _on_exit_button_pressed() -> void:	
	SettingsManager.save_config()
	AudioManager.play_uiclick_sound()
	SceneManager.switch_to_menu()

func _on_music_pressed() -> void:
	AudioManager.play_uiclick_sound()
	if SettingsManager.music_on:
		SettingsManager.music_on = false
		AudioManager.set_music_volume(0)
	else:
		SettingsManager.music_on = true
		AudioManager.set_music_volume(1)
	update_labels()

func _on_sound_effects_pressed() -> void:
	AudioManager.play_uiclick_sound()
	if SettingsManager.sound_on:
		SettingsManager.sound_on = false
		AudioManager.set_sound_volume(0)
	else:
		SettingsManager.sound_on = true
		AudioManager.set_sound_volume(1)
	update_labels()

func _on_color_blind_pressed() -> void:
	AudioManager.play_uiclick_sound()
	if SettingsManager.color_blind_on:
		SettingsManager.color_blind_on = false
	else:
		SettingsManager.color_blind_on = true
	update_labels()
	
func update_labels() -> void:
	if SettingsManager.music_on == false:
		music.text = "MUSIC OFF"
	else:
		music.text = "MUSIC ON"
		
	if SettingsManager.sound_on == false:
		sound_effects.text = "SOUND EFFECTS OFF"
	else:
		sound_effects.text = "SOUND EFFECTS ON"

	if SettingsManager.color_blind_on == false:
		color_blind.text = "COLOR BLIND OFF"
	else:
		color_blind.text = "COLOR BLIND ON"
		
