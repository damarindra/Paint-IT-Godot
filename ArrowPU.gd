extends "res://PowerUP.gd"

enum DIRECTION {
	DOWN, LEFT, UP, RIGHT, DOWN_UP, LEFT_RIGHT
}

#export var offset_position = Vector2(0,0)

export var dir = DIRECTION.DOWN


func _ready():
	sfx = preload("res://arrow.wav")

func do_power_up(id):
	.do_power_up(id)
	if dir == DIRECTION.DOWN:
		var start = current_pos_tile.y
		for i in board_manager.height - start:
			if i + start != current_pos_tile.y:
				#set tile color
				var c_pos = Vector2(current_pos_tile.x, i + start)
				board_manager.change_tile_id_at(c_pos, id)
				board_manager.tile_dict[c_pos].push_down_tween()
				board_manager.start_counting_claim_tile(c_pos, id)
	elif dir == DIRECTION.LEFT:
		var start = current_pos_tile.x
		for i in start:
			if i != current_pos_tile.x:
				#set tile color
				var c_pos = Vector2(i, current_pos_tile.y)
				board_manager.change_tile_id_at(c_pos, id)
				board_manager.tile_dict[c_pos].push_down_tween()
				board_manager.start_counting_claim_tile(c_pos, id)
	elif dir == DIRECTION.UP:
		var start = current_pos_tile.y
		for i in start:
			if i != current_pos_tile.y:
			#set tile color
				var c_pos = Vector2(current_pos_tile.x, i)
				board_manager.change_tile_id_at(c_pos, id)
				board_manager.tile_dict[c_pos].push_down_tween()
				board_manager.start_counting_claim_tile(c_pos, id)
	elif dir == DIRECTION.RIGHT:
		var start = current_pos_tile.x
		for i in board_manager.width - start:
			if i + start != current_pos_tile.x:
				#set tile color
				var c_pos = Vector2(i + start, current_pos_tile.y)
				board_manager.change_tile_id_at(c_pos, id)
				board_manager.tile_dict[c_pos].push_down_tween()
				board_manager.start_counting_claim_tile(c_pos, id)
	elif dir == DIRECTION.DOWN_UP:
		for i in board_manager.height:
			if i != current_pos_tile.y:
				var c_pos = Vector2(current_pos_tile.x, i)
				board_manager.change_tile_id_at(c_pos, id)
				board_manager.tile_dict[c_pos].push_down_tween()
				board_manager.start_counting_claim_tile(c_pos, id)
	elif dir == DIRECTION.LEFT_RIGHT:
		for i in board_manager.width:
			if i != current_pos_tile.x:
				var c_pos = Vector2(i, current_pos_tile.y)
				board_manager.change_tile_id_at(c_pos, id)
				board_manager.tile_dict[c_pos].push_down_tween()
				board_manager.start_counting_claim_tile(c_pos, id)
			
		
	
	queue_free()

func randomize_position():
	.randomize_position()
	random_direction()

func random_direction():
	var candidate = []
	
	#RIGHT
	if current_pos_tile.x < 5:
		candidate.push_back(3)
	#LEFT
	if current_pos_tile.x >= 5:
		candidate.push_back(1)
	#RIGHT LEFT
	if current_pos_tile.x > 3 and current_pos_tile.x < 6:
		candidate.push_back(5)
	#DOWN
	if current_pos_tile.y < 5:
		candidate.push_back(0)
	#UP
	if current_pos_tile.y >= 5:
		candidate.push_back(2)
	#DOWN UP
	if current_pos_tile.y > 3 and current_pos_tile.y < 6:
		candidate.push_back(4)
	
	dir = candidate[randi() % candidate.size()]
	
	frame += dir



	