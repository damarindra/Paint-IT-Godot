extends Node2D

export var max_game_time = 240
export var time_to_claim_score = 8
export(NodePath) var timer_label_path

export(NodePath) var blue_score_path
export(NodePath) var red_score_path
export(NodePath) var green_score_path
export(NodePath) var purple_score_path

onready var timer = Timer.new()
#2 Blue, 3 Red, 4 Green, 5 Purple
var scores = {
	2 : 0,
	3 : 0,
	4 : 0,
	5 : 0
	}

var player_counts = 0
var bot_counts = 1
var is_game_over = true

var player_1_controls = {
	"left" : 16777231,
	"down" : 16777234,
	"right" : 16777233,
	"up" : 16777232
	}
var player_2_controls = {
	"left" : 83,
	"down" : 65,
	"right" : 87,
	"up" : 81
	}
var player_3_controls = {
	"left" : 75,
	"down" : 76,
	"right" : 79,
	"up" : 73
	}
var player_4_controls = {
	"left" : 16777351,
	"down" : 16777352,
	"right" : 16777355,
	"up" : 16777354
	}

onready var timer_label = get_node(timer_label_path)
onready var blue_score_label = get_node(blue_score_path)
onready var red_score_label = get_node(red_score_path)
onready var green_score_label = get_node(green_score_path)
onready var purple_score_label = get_node(purple_score_path)

onready var board_manager = get_node("/root/Global").board_manager
onready var character_manager = get_node("CharacterManager")

func _ready():
	add_child(timer)
	timer.one_shot = true
	timer.connect("timeout", self, "game_over")
	set_process(true)
	set_fixed_process(true)

func _process(delta):
	if is_game_over:
		return
	timer_label.text = translate_float_to_time(timer.get_time_left())

func _fixed_process(delta):
	if is_game_over:
		return
	update_score()

func start_timer():
	timer.wait_time = max_game_time
	timer.start()

func game_over():
	update_score()
	var winner_id = 0
	for i in scores.keys():
		if winner_id == 0:
			winner_id = i
		else:
			if scores[winner_id] < scores[i]:
				winner_id = i
	
	var txt = "Blue WINS"
	if winner_id == 3:
		txt = "Red WINS"
	elif winner_id == 4:
		txt = "Green WINS"
	elif winner_id == 5:
		txt= "Purple WINS"
	$GameOverUI.show()
	get_node("GameOverUI/Panel/Label").text = txt
	
	# ALL CHARACTER STOP!
	for i in character_manager.character_active_array:
		i.get_child(0).is_controllable = false
		board_manager.reset_weight_point_and_reconnect((i.get_child(0).current_pos_tile.x * board_manager.height) + i.get_child(0).current_pos_tile.y, i.get_child(0).current_pos_tile)
	

func translate_float_to_time(f):
	var minute = int(ceil(f)) / 60
	var seconds = int(ceil(f)) % 60
	
	var seconds_str = str(seconds)
	if seconds < 10:
		seconds_str = "0" + seconds_str
	
	return str(minute) + ":" + seconds_str

func update_score():
	blue_score_label.text = str(scores[2])
	red_score_label.text = str(scores[3])
	green_score_label.text = str(scores[4])
	purple_score_label.text = str(scores[5])

func get_tile_status():
	return board_manager.get_current_tile()

func restart_game():
	restart_without_timer()
	start_timer()
	is_game_over = false

func restart_without_timer():
	board_manager.reset_board()
	character_manager.reset_and_setup_all_characters(player_counts, bot_counts)
	# reset score
	for i in scores.keys():
		scores[i] = 0
	update_score()


