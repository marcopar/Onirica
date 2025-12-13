extends Control

class_name Credits

func _on_exit_button_pressed() -> void:
	AudioManager.play_uiclick_sound()
	SceneManager.switch_to_menu()

func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	AudioManager.play_uiclick_sound()
	OS.shell_open(str(meta))
