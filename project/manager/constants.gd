extends Node

const GROUP_CARDS: String = "cards"
const GROUP_LABYRINTH: String = "labyrinth"
const GROUP_DISCARD: String = "discard"
const GROUP_LIMBO: String = "limbo"
const GROUP_PROPHECY_CARDS: String = "prophecy_cards"
const GROUP_INCANTATION_CARDS: String = "incantation_cards"

const DRAGGING_BASE_Z: int = 200
const HAND_BASE_Z: int = 100
const LABYRINTH_BASE_Z: int = 1
const DISCARD_BASE_Z: int = 1
const LIMBO_BASE_Z: int = 1

enum NIGHTMARE_DISCARD {HAND, DECK, DOOR, KEY, NONE}

enum KEY_OPEN_DOOR {LIMBO, DOOR}
