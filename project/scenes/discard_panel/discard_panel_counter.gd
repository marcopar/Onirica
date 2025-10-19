extends Control

class_name DiscardPanelCounter

@onready var label: Label = $HBoxContainer/Label

func set_number(value: int)	-> void:
	label.text = "%d" % value
