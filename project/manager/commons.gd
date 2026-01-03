extends Node

const SQUARE: Texture2D = preload("res://assets/sprites/icons/square.svg")
const STAR: Texture2D = preload("res://assets/sprites/icons/star.svg")
const DIAMOND: Texture2D = preload("res://assets/sprites/icons/diamond.svg")
const CIRCLE: Texture2D = preload("res://assets/sprites/icons/circle.svg")
const TRIANGLE: Texture2D = preload("res://assets/sprites/icons/triangle.svg")

func get_colorblid_symbol(card_color: CardManager.CARD_COLOR) -> Texture2D:
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
			# return DIAMOND
			return STAR
		CardManager.CARD_COLOR.MULTI:
			# star
			return STAR
		_:
			return null
