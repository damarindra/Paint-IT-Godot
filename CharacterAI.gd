extends "res://CharacterController.gd"

# can be set as a difficulty level
var max_turn_wait_time =  .8
var is_waiting = false
var wait_time_counter = 0.0
var wait_time_needed = 0.0

var priority_movement = {
	"left" : true, "right" : true, "up" : true, "down" : true
	}

func _ready():
	
	set_fixed_process(true)

func setup_position():
	.setup_position()
	if start_position == 0:
		priority_movement["down"] = false
		priority_movement["left"] = false
	elif start_position == 1:
		priority_movement["up"] = false
		priority_movement["right"] = false
	elif start_position == 2:
		priority_movement["up"] = false
		priority_movement["left"] = false
	elif start_position == 3:
		priority_movement["right"] = false
		priority_movement["down"] = false

func _fixed_process(delta):
#	print(is_controllable)
#	print("MOVE" + str(can_move))
	if !is_controllable:
		return
	
	# make a priority move, next move priority is unoccupied tile
	# 0 = vertical or 1 = horizontal
	if can_move and is_waiting == false:
		var rand_array = []
		if priority_movement["right"]:
			rand_array.push_back(0)
		if priority_movement["left"]:
			rand_array.push_back(1)
		if priority_movement["up"]:
			rand_array.push_back(2)
		if priority_movement["down"]:
			rand_array.push_back(3)

		var move_id = 4
		if rand_array.size() != 0:
			var r = randi() % rand_array.size()
			move_id = rand_array[r]

		if move_id == 0:
			input.x = 1
		elif move_id == 1:
			input.x = -1
		elif move_id == 2:
			input.y = -1
		elif move_id == 3:
			input.y = 1
		else:
			get_nearest_direction()
	
		if(try_to_move()):
			get_neighbors()
		
		
		var timer = get_tree().create_timer(randf() * max_turn_wait_time)
		timer.connect("timeout", self, "wait_to_move")
		
		is_waiting = true
		

func wait_to_move():
	is_waiting = false

func get_nearest_direction():
	var nearest_tile = find_nearest_unoqupied_tile()
	var points = board_manager.aStar.get_point_path((current_pos_tile.x * board_manager.height) + current_pos_tile.y, (nearest_tile.x * board_manager.height)  + nearest_tile.y)
	var next_pos = points[1]
	var next_pos_v2 = Vector2(next_pos.x, next_pos.y)
	input = next_pos_v2 - current_pos_tile

func find_nearest_unoqupied_tile():
	var nearest_distance = INF
	var nearest_tile = Vector2(0,0)
	for t in board_manager.tile_dict.keys():
		if t != current_pos_tile and board_manager.tile_dict[t].tile_id != char_id + 2 and $"../..".is_tile_occupied(t) == false:
			var distance = t.distance_to(current_pos_tile)
			if nearest_distance > distance:
				nearest_distance = distance
				nearest_tile = t
	return nearest_tile

func get_neighbors():
	#reset
	priority_movement["right"] = false
	priority_movement["left"] = false
	priority_movement["up"] = false
	priority_movement["down"] = false
	# right
	if current_pos_tile.x + 1 < board_manager.width:
		if board_manager.tile_dict[current_pos_tile + Vector2(1, 0)].tile_id != char_id + 2 and $"../..".is_tile_occupied(current_pos_tile + Vector2(1, 0)) == false:
			priority_movement["right"] = true
	# left
	if current_pos_tile.x - 1 >= 0:
		if board_manager.tile_dict[current_pos_tile + Vector2(-1, 0)].tile_id != char_id + 2 and $"../..".is_tile_occupied(current_pos_tile + Vector2(-1, 0)) == false:
			priority_movement["left"] = true
	# up
	if current_pos_tile.y - 1 >= 0:
		if board_manager.tile_dict[current_pos_tile + Vector2(0, -1)].tile_id != char_id + 2 and $"../..".is_tile_occupied(current_pos_tile + Vector2(0, -1)) == false:
			priority_movement["up"] = true
	# down
	if current_pos_tile.y + 1 < board_manager.height:
		if board_manager.tile_dict[current_pos_tile + Vector2(0, 1)].tile_id != char_id + 2 and $"../..".is_tile_occupied(current_pos_tile + Vector2(0, 1)) == false:
			priority_movement["down"] = true