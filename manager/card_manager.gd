extends Node

enum CARD_COLOR {RED, GREEN, BLUE, YELLOW, MULTI, NONE}
var CARD_COLOR_TEXT: Dictionary = {
		CARD_COLOR.RED: "red",
		CARD_COLOR.BLUE: "blue",
		CARD_COLOR.GREEN: "green",
		CARD_COLOR.YELLOW: "yellow",
		CARD_COLOR.MULTI: "multi",
		CARD_COLOR.NONE: "none"
}

enum CARD_TYPE {SUN, MOON, KEY, GLYPH, DOOR, DREAM, DEADEND}
var CARD_TYPE_TEXT: Dictionary = {
		CARD_TYPE.SUN: "sun",
		CARD_TYPE.MOON: "moon",
		CARD_TYPE.KEY: "key",
		CARD_TYPE.GLYPH: "glyph",
		CARD_TYPE.DOOR: "door",
		CARD_TYPE.DREAM: "dream",
		CARD_TYPE.DEADEND: "deadend"
}

const BASE_DECK = {
	CARD_TYPE.SUN: {
		CARD_COLOR.RED: 9,
		CARD_COLOR.BLUE: 8,
		CARD_COLOR.GREEN: 7,
		CARD_COLOR.YELLOW: 6
	},
	CARD_TYPE.MOON: {
		CARD_COLOR.RED: 4,
		CARD_COLOR.BLUE: 4,
		CARD_COLOR.GREEN: 4,
		CARD_COLOR.YELLOW: 4
	},
	CARD_TYPE.KEY: {
		CARD_COLOR.RED: 3,
		CARD_COLOR.BLUE: 3,
		CARD_COLOR.GREEN: 3,
		CARD_COLOR.YELLOW: 3
	},
	CARD_TYPE.DOOR: {
		CARD_COLOR.RED: 2,
		CARD_COLOR.BLUE: 2,
		CARD_COLOR.GREEN: 2,
		CARD_COLOR.YELLOW: 2
	},
	CARD_TYPE.DREAM: {
		CARD_COLOR.NONE: 10
	}
}

const BOAT_EXPANSION_DECK = {
	CARD_TYPE.GLYPH: {
		CARD_COLOR.RED: 2,
		CARD_COLOR.BLUE: 2,
		CARD_COLOR.GREEN: 2,
		CARD_COLOR.YELLOW: 2
	},
	CARD_TYPE.DOOR: {
		CARD_COLOR.RED: 1,
		CARD_COLOR.BLUE: 1,
		CARD_COLOR.GREEN: 1,
		CARD_COLOR.YELLOW: 1
	}
}

const FIRSTCLASS_AND_LUGGAGE_EXPANSION_DECK = {
	CARD_TYPE.SUN: {
		CARD_COLOR.MULTI: 3
	},
	CARD_TYPE.MOON: {
		CARD_COLOR.MULTI: 2
	},
	CARD_TYPE.KEY: {
		CARD_COLOR.MULTI: 1
	},
	CARD_TYPE.DEADEND: {
		CARD_COLOR.NONE: 10
	},
}

func create_card(type: CARD_TYPE, color: CARD_COLOR) -> CardModel:
	var sprite_base: String = "res://assets/sprites/cards/"
	var sprite_name: String
	if color == CARD_COLOR.MULTI or color == CARD_COLOR.NONE:
		sprite_name = "%s%s.png" % [sprite_base, CARD_TYPE_TEXT[type]]
	else:
		sprite_name = "%s%s_%s.png" % [sprite_base, CARD_COLOR_TEXT[color], CARD_TYPE_TEXT[type]]
	var cm: CardModel = CardModel.new()
	cm.type = type
	cm.color = color
	cm.sprite_name = sprite_name
	return cm

func create_base_deck() -> Array[CardModel]:
	var deck: Array[CardModel] = []
	for type in BASE_DECK.keys():
		for color in BASE_DECK[type]:
			var qty: int = BASE_DECK[type][color]
			for i in range(0, qty):
				var card: CardModel = create_card(type, color)
				deck.append(card)
	return deck
	
