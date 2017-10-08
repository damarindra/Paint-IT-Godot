extends Sprite

export var auto_setup_by_name = true
# 0 = blue, 1 = red, 2 = green, 3 = purple
export var char_id = 0
export var move_time = .5
export var jump_height = 15

export var frame_left = 21
export var frame_up = 10
export var frame_right = 11
export var frame_down = 20

export(AudioStream) var jump_sfx

#0 bottom, 1 top, 2 left, 3 right
export(int, 0, 3) var start_position = 0
export var offset_position = Vector2(17, 12)

onready var target_jump_pos = get_parent().position + Vector2(0, -1) * jump_height
onready var target_fall_pos = get_parent().position
onready var audio_player = get_node("audio")


onready var board_manager = get_node("/root/Global").board_manager

var input = Vector2(0,0)
var can_move = true
var current_pos_tile = Vector2(0,0)
var is_controllable = false

func _ready():
	auto_setup_character()
	$TweenJump.connect("tween_completed", self, "fall_tween")
	setup_position()
	set_fixed_process(true)

func auto_setup_character():
	if auto_setup_by_name:
		if get_parent().get_name() == "Blue" || get_parent().get_name() == "Blue_bot":
			char_id = 0
			frame_left = 21
			frame_up = 10
			frame_right = 11
			frame_down = 20
			start_position = 0
		elif get_parent().get_name() == "Red" || get_parent().get_name() == "Red_bot":
			char_id = 1
			frame_left = 23
			frame_up = 12
			frame_right = 13
			frame_down = 22
			start_position = 1
		elif get_parent().get_name() == "Green" || get_parent().get_name() == "Green_bot":
			char_id = 2
			frame_left = 25
			frame_up = 14
			frame_right = 15
			frame_down = 24
			start_position = 2
		elif get_parent().get_name() == "Purple" || get_parent().get_name() == "Purple_bot":
			char_id = 3
			frame_left = 27
			frame_up = 16
			frame_right = 17
			frame_down = 26
			start_position = 3

func _fixed_process(delta):
	if !is_controllable:
		return
	area_2d_collision()

func area_2d_collision():
	var areas = $Area2D.get_overlapping_areas()
	if areas.size() != 0 && areas.size() < 2:
		if areas[0].get_parent().get_script() == get_node("/root/Global").arrow_pu_class:
			areas[0].get_parent().do_power_up(char_id + 2)
			if areas[0].get_parent().sfx != null:
				play_sfx(areas[0].get_parent().sfx)
			
	elif areas.size() > 1:
		print("SOMETHING WHEN WRONG : WHY DETECTED AREAS MORE THAN 1???!")

func try_to_move():
	if !is_controllable:
		return false
	var result = false
	var motion = Vector2(0,0)
	if input.x == 1:
		input.x = 1
		motion = (board_manager.tileSize - board_manager.tileOffset) / 2
		motion.y *= -1
	elif input.x == -1:
		motion = (board_manager.tileSize - board_manager.tileOffset) / 2
		motion.x *= -1
	elif input.y == -1:
		motion = (board_manager.tileSize - board_manager.tileOffset) / 2
		motion.x *= -1
		motion.y *= -1
	elif input.y == 1:
		motion = (board_manager.tileSize - board_manager.tileOffset) / 2
	else: input = Vector2(0,0)
	
	if input != Vector2(0,0):
		if can_move:
			if current_pos_tile.x + input.x > board_manager.width - 1 or current_pos_tile.x + input.x < 0 or current_pos_tile.y + input.y > board_manager.height - 1 or current_pos_tile.y + input.y < 0:
				#Do Nothing
				pass
			else:
				result = move(motion)
#				play_sfx(jump_sfx)
				
				#create timer for disabling moving time
				can_move = false
				var timer = get_tree().create_timer(move_time)
				timer.connect("timeout", self, "enable_move")
		#reset input
		input = Vector2(0,0)
	
	return result

func move(motion):
	if !is_controllable:
		return false
	
	#swap sprite
	if input.x == 1 and input.y == 0 and frame != frame_right:
		frame = frame_right
	elif input.x == -1 and input.y == 0 and frame != frame_left:
		frame = frame_left
	elif input.x == 0 and input.y == -1 and frame != frame_up:
		frame = frame_up
	elif input.x == 0 and input.y == 1 and frame != frame_down:
		frame = frame_down
	
	#TO-DO : Handle colliding between other character using checking current_pos_tile
	if $"../..".is_tile_occupied(current_pos_tile + input):
		#Do Nothing
		return false
	else:
		$Tween.interpolate_property(self, "position", position, position + motion, move_time, Tween.TRANS_CUBIC, Tween.EASE_IN)
		$Tween.start()
		
		$TweenJump.interpolate_property(get_parent(), "position", get_parent().position, target_jump_pos, move_time * 0.7, Tween.TRANS_CIRC, Tween.EASE_IN)
		$TweenJump.start()
		
		#remove and add point with lower weight to the current position
		board_manager.reset_weight_point_and_reconnect((current_pos_tile.x * board_manager.height) + current_pos_tile.y, current_pos_tile)
		#reconnect current position
#		board_manager.reconnect_point((current_pos_tile.x * board_manager.height) + current_pos_tile.y)
		#start claiming when character leaving the tile
		board_manager.start_counting_claim_tile(current_pos_tile, char_id + 2)
		
		current_pos_tile += input
		
		#remove and add point with different weight to the new position
		board_manager.reset_weight_point_and_reconnect((current_pos_tile.x * board_manager.height) + current_pos_tile.y, current_pos_tile, board_manager.width * board_manager.height)
		#disconnect current point because of tile is currently occupied by character
#		board_manager.disconnect_point((current_pos_tile.x * board_manager.height) + current_pos_tile.y)
		
		$"../..".fix_z_order()
		
	return true
	

func fall_tween(object, key):
	$TweenFall.interpolate_property(get_parent(), "position", get_parent().position, target_fall_pos, move_time * 0.3, Tween.TRANS_CIRC, Tween.EASE_OUT)
	$TweenFall.start()
	board_manager.tile_dict[current_pos_tile].push_down_tween()

func enable_move():
	can_move = true
	#set tile color
	#when restart the game, all object still active and script still running, and that means, 
	#this tween still running and when restarting the game with tween running, the tile will automatically 
	#change the color, this is the prevention
	if is_controllable:
		board_manager.change_tile_id_at(current_pos_tile, char_id + 2)
		board_manager.tile_dict[current_pos_tile].force_stop_timer()

func setup_position():
	#Reset tween if needed
	if $Tween.is_active():
		$Tween.remove_all()
	if $TweenFall.is_active():
		$TweenFall.remove_all()
	
	if start_position == 0:
		current_pos_tile = Vector2(0, board_manager.height-1)
		frame = frame_up
	elif start_position == 1:
		current_pos_tile = Vector2(board_manager.width - 1, 0)
		frame = frame_down
	elif start_position == 2:
		current_pos_tile = Vector2(0, 0)
		frame = frame_right
	elif start_position == 3:
		current_pos_tile = Vector2(board_manager.width - 1, board_manager.height-1)
		frame = frame_left
	
	set_position_reference_tile_dict(current_pos_tile)
	position = position
	
	#set the tile color
	board_manager.change_tile_id_at(current_pos_tile, char_id + 2)
	#remove and add point with different weight to the new position
	board_manager.reset_weight_point_and_reconnect((current_pos_tile.x * board_manager.height) + current_pos_tile.y, current_pos_tile, board_manager.width * board_manager.height)

func set_position_reference_tile_dict(vec):
	var target_spr = board_manager.tile_dict[Vector2(vec.x, vec.y)]
	position = target_spr.position + Vector2(abs(offset_position.x), abs(offset_position.y) * -1)

func play_sfx(aud):
	if !board_manager.get_parent().is_game_over:
		if audio_player.get_stream() != aud:
			audio_player.set_stream(aud)
		audio_player.play()