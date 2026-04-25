extends TextureRect

class_name CardCounterPanel

@onready var nightmares: DiscardPanelCounter = $VBoxContainer/Generic/Nighmares
@onready var dead_ends: DiscardPanelCounter = $VBoxContainer/Generic/DeadEnds

@onready var red_sun: DiscardPanelCounter = $VBoxContainer/Red/RedSun
@onready var red_moon: DiscardPanelCounter = $VBoxContainer/Red/RedMoon
@onready var red_key: DiscardPanelCounter = $VBoxContainer/Red/RedKey
@onready var red_glyph: DiscardPanelCounter = $VBoxContainer/Red/RedGlyph
@onready var red_door: DiscardPanelCounter = $VBoxContainer/Red/RedDoor

@onready var green_sun: DiscardPanelCounter = $VBoxContainer/Green/GreenSun
@onready var green_moon: DiscardPanelCounter = $VBoxContainer/Green/GreenMoon
@onready var green_key: DiscardPanelCounter = $VBoxContainer/Green/GreenKey
@onready var green_glyph: DiscardPanelCounter = $VBoxContainer/Green/GreenGlyph
@onready var green_door: DiscardPanelCounter = $VBoxContainer/Green/GreenDoor

@onready var blue_sun: DiscardPanelCounter = $VBoxContainer/Blue/BlueSun
@onready var blue_moon: DiscardPanelCounter = $VBoxContainer/Blue/BlueMoon
@onready var blue_key: DiscardPanelCounter = $VBoxContainer/Blue/BlueKey
@onready var blue_glyph: DiscardPanelCounter = $VBoxContainer/Blue/BlueGlyph
@onready var blue_door: DiscardPanelCounter = $VBoxContainer/Blue/BlueDoor

@onready var yellow_sun: DiscardPanelCounter = $VBoxContainer/Yellow/YellowSun
@onready var yellow_moon: DiscardPanelCounter = $VBoxContainer/Yellow/YellowMoon
@onready var yellow_key: DiscardPanelCounter = $VBoxContainer/Yellow/YellowKey
@onready var yellow_glyph: DiscardPanelCounter = $VBoxContainer/Yellow/YellowGlyph
@onready var yellow_door: DiscardPanelCounter = $VBoxContainer/Yellow/YellowDoor

@onready var multi_sun: DiscardPanelCounter = $VBoxContainer/Multi/MultiSun
@onready var multi_moon: DiscardPanelCounter = $VBoxContainer/Multi/MultiMoon
@onready var multi_key: DiscardPanelCounter = $VBoxContainer/Multi/MultiKey

@onready var multi: HBoxContainer = $VBoxContainer/Multi

@onready var red_label: TextureRect = $VBoxContainer/Red/RedLabel
@onready var green_label: TextureRect = $VBoxContainer/Green/GreenLabel
@onready var blue_label: TextureRect = $VBoxContainer/Blue/BlueLabel
@onready var yellow_label: TextureRect = $VBoxContainer/Yellow/YellowLabel
@onready var multi_label: TextureRect = $VBoxContainer/Multi/MultiLabel

var counters: Dictionary[CardManager.CARD_TYPE, Variant]

func _ready() -> void:
	red_label.visible = SettingsManager.color_blind_on
	green_label.visible = SettingsManager.color_blind_on
	blue_label.visible = SettingsManager.color_blind_on
	yellow_label.visible = SettingsManager.color_blind_on
	multi_label.visible = SettingsManager.color_blind_on
	
	red_label.texture = Commons.get_colorblid_symbol(CardManager.CARD_COLOR.RED)
	green_label.texture = Commons.get_colorblid_symbol(CardManager.CARD_COLOR.GREEN)
	blue_label.texture = Commons.get_colorblid_symbol(CardManager.CARD_COLOR.BLUE)
	yellow_label.texture = Commons.get_colorblid_symbol(CardManager.CARD_COLOR.YELLOW)
	multi_label.texture = Commons.get_colorblid_symbol(CardManager.CARD_COLOR.MULTI)

	
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		SignalManager.counter_panel_closed.emit(self)
	
func clear_counters() -> void:
	counters = {
	CardManager.CARD_TYPE.NIGHTMARE: {
		CardManager.CARD_COLOR.NONE: 0
	},
	CardManager.CARD_TYPE.DEAD_END: {
		CardManager.CARD_COLOR.NONE: 0
	},
	CardManager.CARD_TYPE.SUN: {
		CardManager.CARD_COLOR.RED: 0,
		CardManager.CARD_COLOR.BLUE: 0,
		CardManager.CARD_COLOR.GREEN: 0,
		CardManager.CARD_COLOR.YELLOW: 0,
		CardManager.CARD_COLOR.MULTI: 0
	},
	CardManager.CARD_TYPE.MOON: {
		CardManager.CARD_COLOR.RED: 0,
		CardManager.CARD_COLOR.BLUE: 0,
		CardManager.CARD_COLOR.GREEN: 0,
		CardManager.CARD_COLOR.YELLOW: 0,
		CardManager.CARD_COLOR.MULTI: 0
	},
	CardManager.CARD_TYPE.KEY: {
		CardManager.CARD_COLOR.RED: 0,
		CardManager.CARD_COLOR.BLUE: 0,
		CardManager.CARD_COLOR.GREEN: 0,
		CardManager.CARD_COLOR.YELLOW: 0,
		CardManager.CARD_COLOR.MULTI: 0
	},
	CardManager.CARD_TYPE.GLYPH: {
		CardManager.CARD_COLOR.RED: 0,
		CardManager.CARD_COLOR.BLUE: 0,
		CardManager.CARD_COLOR.GREEN: 0,
		CardManager.CARD_COLOR.YELLOW: 0
	},
	CardManager.CARD_TYPE.DOOR: {
		CardManager.CARD_COLOR.RED: 0,
		CardManager.CARD_COLOR.BLUE: 0,
		CardManager.CARD_COLOR.GREEN: 0,
		CardManager.CARD_COLOR.YELLOW: 0
	}
}

func setup(car_models: Array[CardModel], show_all: bool) -> void:
	red_glyph.visible = GameManager.the_glyphs_on
	green_glyph.visible = GameManager.the_glyphs_on
	blue_glyph.visible = GameManager.the_glyphs_on
	yellow_glyph.visible = GameManager.the_glyphs_on	
	
	multi.visible = GameManager.crossroads_and_dead_ends_on
	dead_ends.visible= GameManager.crossroads_and_dead_ends_on
	
	red_door.visible = show_all
	green_door.visible = show_all
	blue_door.visible = show_all
	yellow_door.visible = show_all
	
	for card_model in car_models:
		var type: CardManager.CARD_TYPE = card_model.type
		var color: CardManager.CARD_COLOR = card_model.color
		var counter: int = counters[type][color]
		counters[type][color] = counter + 1
	
	nightmares.set_number(counters[CardManager.CARD_TYPE.NIGHTMARE][CardManager.CARD_COLOR.NONE] as int)
	dead_ends.set_number(counters[CardManager.CARD_TYPE.DEAD_END][CardManager.CARD_COLOR.NONE] as int)
	
	red_sun.set_number(counters[CardManager.CARD_TYPE.SUN][CardManager.CARD_COLOR.RED] as int)
	red_moon.set_number(counters[CardManager.CARD_TYPE.MOON][CardManager.CARD_COLOR.RED] as int)
	red_key.set_number(counters[CardManager.CARD_TYPE.KEY][CardManager.CARD_COLOR.RED] as int)
	red_glyph.set_number(counters[CardManager.CARD_TYPE.GLYPH][CardManager.CARD_COLOR.RED] as int)
	red_door.set_number(counters[CardManager.CARD_TYPE.DOOR][CardManager.CARD_COLOR.RED] as int)
	
	green_sun.set_number(counters[CardManager.CARD_TYPE.SUN][CardManager.CARD_COLOR.GREEN] as int)
	green_moon.set_number(counters[CardManager.CARD_TYPE.MOON][CardManager.CARD_COLOR.GREEN] as int)
	green_key.set_number(counters[CardManager.CARD_TYPE.KEY][CardManager.CARD_COLOR.GREEN] as int)
	green_glyph.set_number(counters[CardManager.CARD_TYPE.GLYPH][CardManager.CARD_COLOR.GREEN] as int)
	green_door.set_number(counters[CardManager.CARD_TYPE.DOOR][CardManager.CARD_COLOR.GREEN] as int)
	
	blue_sun.set_number(counters[CardManager.CARD_TYPE.SUN][CardManager.CARD_COLOR.BLUE] as int)
	blue_moon.set_number(counters[CardManager.CARD_TYPE.MOON][CardManager.CARD_COLOR.BLUE]  as int)
	blue_key.set_number(counters[CardManager.CARD_TYPE.KEY][CardManager.CARD_COLOR.BLUE] as int)
	blue_glyph.set_number(counters[CardManager.CARD_TYPE.GLYPH][CardManager.CARD_COLOR.BLUE] as int)
	blue_door.set_number(counters[CardManager.CARD_TYPE.DOOR][CardManager.CARD_COLOR.BLUE] as int)
	
	yellow_sun.set_number(counters[CardManager.CARD_TYPE.SUN][CardManager.CARD_COLOR.YELLOW] as int)
	yellow_moon.set_number(counters[CardManager.CARD_TYPE.MOON][CardManager.CARD_COLOR.YELLOW] as int)
	yellow_key.set_number(counters[CardManager.CARD_TYPE.KEY][CardManager.CARD_COLOR.YELLOW] as int)
	yellow_glyph.set_number(counters[CardManager.CARD_TYPE.GLYPH][CardManager.CARD_COLOR.YELLOW] as int)
	yellow_door.set_number(counters[CardManager.CARD_TYPE.DOOR][CardManager.CARD_COLOR.YELLOW] as int)
	
	multi_sun.set_number(counters[CardManager.CARD_TYPE.SUN][CardManager.CARD_COLOR.MULTI] as int)
	multi_moon.set_number(counters[CardManager.CARD_TYPE.MOON][CardManager.CARD_COLOR.MULTI] as int)
	multi_key.set_number(counters[CardManager.CARD_TYPE.KEY][CardManager.CARD_COLOR.MULTI] as int)
	
