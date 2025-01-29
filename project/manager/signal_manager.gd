extends Node

signal new_game
signal card_drawed(card: Card)
signal card_added_to_labyrinth(card: Card)
signal card_added_to_discard(card: Card)
signal card_added_to_limbo(card: Card)
signal card_removed_from_limbo(card: Card)
signal card_return_to_hand(card: Card)
signal door_discarded(color: CardManager.CARD_COLOR)
