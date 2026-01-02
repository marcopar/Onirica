extends Node

func get_colorblid_symbol(card_color: CardManager.CARD_COLOR) -> String:
	match card_color:
		CardManager.CARD_COLOR.RED:
			# circle
			return "\u2b24"
		CardManager.CARD_COLOR.GREEN:
			# triangle pointing down
			return "\u25BC"
		CardManager.CARD_COLOR.BLUE:
			# square
			return "\u25A0"
		CardManager.CARD_COLOR.YELLOW:
			# diamond
			return "\u25C6"
		CardManager.CARD_COLOR.MULTI:
			# star
			return "\u2605"
		_:
			return ""

func set_colorblind_text(label: Label, card_color: CardManager.CARD_COLOR, card_type: CardManager.CARD_TYPE) -> void:
	if SettingsManager.color_blind_on == false:
		label.text = ""
		return
	label.text = get_colorblid_symbol(card_color)
			
func set_card_colorblind_properties(label: Label, card_color: CardManager.CARD_COLOR, card_type: CardManager.CARD_TYPE) -> void:
	if SettingsManager.color_blind_on == false:
		return
	# Set font size based on color
	match card_color:
		CardManager.CARD_COLOR.RED, CardManager.CARD_COLOR.GREEN, CardManager.CARD_COLOR.BLUE:
			label.label_settings.font_size = 30
		CardManager.CARD_COLOR.MULTI, CardManager.CARD_COLOR.YELLOW:
			label.label_settings.font_size = 38
		_:
			return
	# Set position based on card type
	match card_type:
		CardManager.CARD_TYPE.DOOR:
			label.position.x = -25
			label.position.y = 100
		_:
			label.position.x = -98
			label.position.y = -100
			# Adjust Y position for yellow cards
			if card_color == CardManager.CARD_COLOR.MULTI or card_color == CardManager.CARD_COLOR.YELLOW:
				label.position.y = -100
			
func set_doors_button_colorblind_properties(label: Label, card_color: CardManager.CARD_COLOR, card_type: CardManager.CARD_TYPE) -> void:
	if SettingsManager.color_blind_on == false:
		return
	
	match card_color:
		CardManager.CARD_COLOR.RED, CardManager.CARD_COLOR.GREEN, CardManager.CARD_COLOR.BLUE:
			label.position.x = 90
			label.position.y = 270
			label.label_settings.font_size = 70
		CardManager.CARD_COLOR.MULTI, CardManager.CARD_COLOR.YELLOW:
			label.position.x = 90
			label.position.y = 255
			label.label_settings.font_size = 100
