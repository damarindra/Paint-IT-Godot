extends Node2D

export(PackedScene) var player_scene
export(PackedScene) var ai_scene
var character_active_array = []
var player_array = []
var ai_array = []

onready var board_manager = get_node("/root/Global").board_manager

func _ready():
	create_all_characters()
	reset_and_setup_all_characters(0, 1)

func create_all_characters():
	for i in 4:
		var pl = player_scene.instance()
		if i == 0:
			pl.set_name("Blue")
		elif i == 1:
			pl.set_name("Red")
		elif i == 2:
			pl.set_name("Green")
		else:
			pl.set_name("Purple")
		add_child(pl)
		pl.hide()
		player_array.push_back(pl)
		
	for i in 4:
		var a = ai_scene.instance()
		if i == 0:
			a.set_name("Blue_bot")
		elif i == 1:
			a.set_name("Red_bot")
		elif i == 2:
			a.set_name("Green_bot")
		else:
			a.set_name("Purple_bot")
		add_child(a)
		a.hide()
		ai_array.push_back(a)

func reset_and_setup_all_characters(player, ai):
#	remove_all_characters()
	character_active_array.clear()
	for i in player_array.size():
		if i < player:
			player_array[i].show()
			player_array[i].get_child(0).is_controllable = true
			player_array[i].get_child(0).can_move = true
			character_active_array.push_back(player_array[i])
			player_array[i].get_child(0).setup_position()
		else:
			player_array[i].hide()
			player_array[i].get_child(0).is_controllable = false
			player_array[i].get_child(0).position = Vector2(0,i * -1 * 30)
	
	for i in ai_array.size():
		if i < player or i >= ai + player:
			ai_array[i].hide()
			ai_array[i].get_child(0).is_controllable = false
			ai_array[i].get_child(0).position = Vector2(-60,i * -1 * 30)
		elif i < ai + player:
			ai_array[i].show()
			ai_array[i].get_child(0).is_controllable = true
			ai_array[i].get_child(0).can_move = true
			character_active_array.push_back(ai_array[i])
			ai_array[i].get_child(0).setup_position()
	

#func gather_child():
#	character_active_array.clear()
#	for i in get_child_count():
#		character_active_array.push_back(get_child(i).get_child(0))
#		print(get_child(i).get_child(0))
#	print(get_child_count())

#func remove_all_characters():
#	for i in character_active_array.size():
#		character_active_array[i].get_parent().queue_free()
#	character_active_array.clear()

func is_tile_occupied(vec):
	for i in character_active_array.size():
		if character_active_array[i].get_child(0).current_pos_tile == vec:
			return true
		
	return false

func fix_z_order():
	for i in character_active_array.size():
		character_active_array[i].get_child(0).z = board_manager.tile_dict[character_active_array[i].get_child(0).current_pos_tile].z + 1

func re_assign_player_input(player):
	if player == 1:
		player_array[0].get_child(0).re_assign_control()
	elif player == 2:
		player_array[1].get_child(0).re_assign_control()
	elif player == 3:
		player_array[2].get_child(0).re_assign_control()
	elif player == 4:
		player_array[3].get_child(0).re_assign_control()