extends Node

const GROUP_CARDS: String = "cards"
const GROUP_LABYRINTH: String = "labyrinth"
const GROUP_DISCARD: String = "discard"
const GROUP_LIMBO: String = "limbo"
const GROUP_PROPHECY_CARDS: String = "prophecy_cards"

const DRAGGING_BASE_Z: int = 200
const HAND_BASE_Z: int = 100
const LABYRINTH_BASE_Z: int = 1
const DISCARD_BASE_Z: int = 1
const LIMBO_BASE_Z: int = 1

enum NIGHTMARE_DISCARD {HAND, DECK, DOOR, KEY, NONE}

enum KEY_OPEN_DOOR {LIMBO, DOOR}

const RAIN_IN_SPACE_LOOP = preload("uid://cm1m3qxvgvd8n")
const DEPTH_OF_DESPAIR = preload("uid://0f5p0ho02rdq")
const A_FRIENDLY_GHOST_MINIMAL_LOOP = preload("uid://dgdxm3uet14ff")
const THE_CHAMBER_OF_CELESTIAL_PEACE_LOOP = preload("uid://bsuxeu02y5m2m")
