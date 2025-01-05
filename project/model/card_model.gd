extends Node

class_name CardModel

var type: CardManager.CARD_TYPE:
	get:
		return type
	set(value):
		type = value
	
var color: CardManager.CARD_COLOR:
	get:
		return color
	set(value):
		color = value

var can_be_in_hand: bool:
	get:
		return type == CardManager.CARD_TYPE.DEADEND or type == CardManager.CARD_TYPE.SUN or \
			type == CardManager.CARD_TYPE.MOON or type == CardManager.CARD_TYPE.KEY or \
			type == CardManager.CARD_TYPE.GLYPH
	
var can_play: bool:
	get:
		return type == CardManager.CARD_TYPE.SUN or type == CardManager.CARD_TYPE.MOON or \
			type == CardManager.CARD_TYPE.KEY or type == CardManager.CARD_TYPE.GLYPH

var can_discard: bool:
	get:
		return type == CardManager.CARD_TYPE.SUN or type == CardManager.CARD_TYPE.MOON or \
			type == CardManager.CARD_TYPE.KEY or type == CardManager.CARD_TYPE.GLYPH
		
var sprite_name: String:
	get:
		return sprite_name
	set(value):
		sprite_name = value
