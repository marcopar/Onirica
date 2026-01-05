extends Node

const SQUARE: Texture2D = preload("res://assets/sprites/icons/square_outline.svg")
const STAR: Texture2D = preload("res://assets/sprites/icons/star_outline.svg")
const DIAMOND: Texture2D = preload("res://assets/sprites/icons/diamond_outline.svg")
const CIRCLE: Texture2D = preload("res://assets/sprites/icons/circle_outline.svg")
const TRIANGLE: Texture2D = preload("res://assets/sprites/icons/triangle_outline.svg")

func get_colorblid_symbol(card_color: CardManager.CARD_COLOR) -> Texture2D:
	if SettingsManager.color_blind_on == false:
		return null
	match card_color:
		CardManager.CARD_COLOR.RED:
			# circle
			return CIRCLE
		CardManager.CARD_COLOR.GREEN:
			# triangle pointing down
			return TRIANGLE
		CardManager.CARD_COLOR.BLUE:
			# square
			return SQUARE
		CardManager.CARD_COLOR.YELLOW:
			# diamond
			return DIAMOND
		CardManager.CARD_COLOR.MULTI:
			# star
			return STAR
		_:
			return null
