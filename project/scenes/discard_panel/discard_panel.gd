extends TextureRect

class_name DiscardPanel

@onready var red_sun: DiscardPanelCounter = $VBoxContainer/Red/RedSun
@onready var red_moon: DiscardPanelCounter = $VBoxContainer/Red/RedMoon
@onready var red_key: DiscardPanelCounter = $VBoxContainer/Red/RedKey
@onready var red_glyph: DiscardPanelCounter = $VBoxContainer/Red/RedGlyph
@onready var green_sun: DiscardPanelCounter = $VBoxContainer/Green/GreenSun
@onready var green_moon: DiscardPanelCounter = $VBoxContainer/Green/GreenMoon
@onready var green_key: DiscardPanelCounter = $VBoxContainer/Green/GreenKey
@onready var green_glyph: DiscardPanelCounter = $VBoxContainer/Green/GreenGlyph
@onready var blue_sun: DiscardPanelCounter = $VBoxContainer/Blue/BlueSun
@onready var blue_moon: DiscardPanelCounter = $VBoxContainer/Blue/BlueMoon
@onready var blue_key: DiscardPanelCounter = $VBoxContainer/Blue/BlueKey
@onready var blue_glyph: DiscardPanelCounter = $VBoxContainer/Blue/BlueGlyph
@onready var yellow_sun: DiscardPanelCounter = $VBoxContainer/Yellow/YellowSun
@onready var yellow_moon: DiscardPanelCounter = $VBoxContainer/Yellow/YellowMoon
@onready var yellow_key: DiscardPanelCounter = $VBoxContainer/Yellow/YellowKey
@onready var yellow_glyph: DiscardPanelCounter = $VBoxContainer/Yellow/YellowGlyph
@onready var multi_sun: DiscardPanelCounter = $VBoxContainer/Multi/MultiSun
@onready var multi_moon: DiscardPanelCounter = $VBoxContainer/Multi/MultiMoon
@onready var multi_key: DiscardPanelCounter = $VBoxContainer/Multi/MultiKey

@onready var multi: HBoxContainer = $VBoxContainer/Multi

@onready var red_label: Label = $VBoxContainer/Red/RedLabel
@onready var green_label: Label = $VBoxContainer/Green/GreenLabel
@onready var blue_label: Label = $VBoxContainer/Blue/BlueLabel
@onready var yellowlabel: Label = $VBoxContainer/Yellow/Yellowlabel
@onready var multi_label: Label = $VBoxContainer/Multi/MultiLabel

var counters: Dictionary[CardManager.CARD_TYPE, Variant]

func _ready() -> void:
	pass
	
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		SignalManager.discard_panel_closed.emit()
	
func clear_counters() -> void:
	counters = {
	CardManager.CARD_TYPE.SUN: {
		CardManager.CARD_COLOR.RED: 0,
		CardManager.CARD_COLOR.BLUE: 0,
		CardManager.CARD_COLOR.GREEN: 0,
		CardManager.CARD_COLOR.YELLOW: 0
	},
	CardManager.CARD_TYPE.MOON: {
		CardManager.CARD_COLOR.RED: 0,
		CardManager.CARD_COLOR.BLUE: 0,
		CardManager.CARD_COLOR.GREEN: 0,
		CardManager.CARD_COLOR.YELLOW: 0
	},
	CardManager.CARD_TYPE.KEY: {
		CardManager.CARD_COLOR.RED: 0,
		CardManager.CARD_COLOR.BLUE: 0,
		CardManager.CARD_COLOR.GREEN: 0,
		CardManager.CARD_COLOR.YELLOW: 0
	},
	CardManager.CARD_TYPE.GLYPH: {
		CardManager.CARD_COLOR.RED: 0,
		CardManager.CARD_COLOR.BLUE: 0,
		CardManager.CARD_COLOR.GREEN: 0,
		CardManager.CARD_COLOR.YELLOW: 0
	}
}

func setup() -> void:	
	for card in GameManager.discard:
		var type: CardManager.CARD_TYPE = card.card_model.type
		var color: CardManager.CARD_COLOR = card.card_model.color
		if type == CardManager.CARD_TYPE.SUN or type == CardManager.CARD_TYPE.MOON or \
			type == CardManager.CARD_TYPE.KEY or type == CardManager.CARD_TYPE.GLYPH:
				var counter = counters[type][color]
				counters[type][color] = counter + 1
	
	red_sun.set_number(counters[CardManager.CARD_TYPE.SUN][CardManager.CARD_COLOR.RED])
	red_moon.set_number(counters[CardManager.CARD_TYPE.MOON][CardManager.CARD_COLOR.RED])
	red_key.set_number(counters[CardManager.CARD_TYPE.KEY][CardManager.CARD_COLOR.RED])
	red_glyph.set_number(counters[CardManager.CARD_TYPE.GLYPH][CardManager.CARD_COLOR.RED])
	green_sun.set_number(counters[CardManager.CARD_TYPE.SUN][CardManager.CARD_COLOR.GREEN])
	green_moon.set_number(counters[CardManager.CARD_TYPE.MOON][CardManager.CARD_COLOR.GREEN])
	green_key.set_number(counters[CardManager.CARD_TYPE.KEY][CardManager.CARD_COLOR.GREEN])
	green_glyph.set_number(counters[CardManager.CARD_TYPE.GLYPH][CardManager.CARD_COLOR.GREEN])
	blue_sun.set_number(counters[CardManager.CARD_TYPE.SUN][CardManager.CARD_COLOR.BLUE])
	blue_moon.set_number(counters[CardManager.CARD_TYPE.MOON][CardManager.CARD_COLOR.BLUE])
	blue_key.set_number(counters[CardManager.CARD_TYPE.KEY][CardManager.CARD_COLOR.BLUE])
	blue_glyph.set_number(counters[CardManager.CARD_TYPE.GLYPH][CardManager.CARD_COLOR.BLUE])
	yellow_sun.set_number(counters[CardManager.CARD_TYPE.SUN][CardManager.CARD_COLOR.YELLOW])
	yellow_moon.set_number(counters[CardManager.CARD_TYPE.MOON][CardManager.CARD_COLOR.YELLOW])
	yellow_key.set_number(counters[CardManager.CARD_TYPE.KEY][CardManager.CARD_COLOR.YELLOW])
	yellow_glyph.set_number(counters[CardManager.CARD_TYPE.GLYPH][CardManager.CARD_COLOR.YELLOW])
	
