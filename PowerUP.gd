extends Sprite

var current_pos_tile = Vector2(0,0)

onready var board_manager = get_node("/root/Global").board_manager
onready var character_manager = get_node("/root/Global").character_manager

var sfx = null

func randomize_position():
	current_pos_tile = Vector2(randi() % board_manager.width, randi() % board_manager.height)
	if(character_manager.is_tile_occupied(current_pos_tile) and !board_manager.is_pu_at(current_pos_tile)):
		randomize_position()
	else:
		position = board_manager.translate_tile_to_position(current_pos_tile)

func do_power_up(id):
	if board_manager.pu_active_array.size() == board_manager.max_pu_at_board:
		board_manager.restart_timer_spawn_pu()
	var i = board_manager.pu_active_array.find_last(self)
	if i != -1:
		board_manager.pu_active_array.remove(i)