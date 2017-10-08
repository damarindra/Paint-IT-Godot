extends Node

onready var board_manager = get_parent().get_node("World").get_node("BoardManager")
onready var character_manager = get_parent().get_node("World").get_node("CharacterManager")
const arrow_pu_class = preload("res://ArrowPU.gd")
