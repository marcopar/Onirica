extends Node

func set_card_colorblind_label_text(label: Label, card_color: CardManager.CARD_COLOR, card_type: CardManager.CARD_TYPE) -> void:
	if SettingsManager.color_blind_on == false:
		label.text = ""
		return
		
	match card_color:
		CardManager.CARD_COLOR.RED:
			label.text = "R"
		CardManager.CARD_COLOR.GREEN:
			label.text = "G"
		CardManager.CARD_COLOR.BLUE:
			label.text = "B"
		CardManager.CARD_COLOR.YELLOW:
			label.text = "Y"
		CardManager.CARD_COLOR.MULTI:
			label.text = "M"
		_:
			label.text = ""

func set_card_colorblind_label_position(label: Label,  card_color: CardManager.CARD_COLOR, card_type: CardManager.CARD_TYPE) -> void:
	if SettingsManager.color_blind_on == false:
		return
		
	match card_type:
		CardManager.CARD_TYPE.DOOR:
			label.position.x = -25
			label.position.y = 100
		_:
			label.position.x = -98
			label.position.y = -100
