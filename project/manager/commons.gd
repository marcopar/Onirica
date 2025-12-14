extends Node

func set_card_colorblind_label(label: Label, card_model: CardModel) -> void:
	match card_model.type:
		CardManager.CARD_TYPE.DOOR:
			label.position.x = -25
			label.position.y = 100
		_:
			label.position.x = -98
			label.position.y = -100
	match card_model.color:
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
