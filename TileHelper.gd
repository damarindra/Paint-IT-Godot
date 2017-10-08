extends Sprite

var tile_id = 0 setget set_tile_id, get_tile_id
var tile_pos = Vector2(0,0)
onready var timer = Timer.new()
onready var timer_spr = Sprite.new()
var timer_spr_offset = Vector2(28,11)
var timer_spr_start_frame = 68
var timer_spr_frame_count = 8

onready var game_manager = get_node("/root/World")
onready var board_manager = get_node("/root/Global").board_manager
onready var tween = Tween.new()
var push_down_length = 8
var region_origin
var position_origin
var timer_reconnect_push_down = true

func _ready():
	add_child(timer)
	timer.connect("timeout", self, "claim_score")
	timer.one_shot = true
	timer.wait_time = game_manager.time_to_claim_score
	add_child(timer_spr)
	timer_spr.texture = texture
	timer_spr.hframes = 20
	timer_spr.vframes = 10
	timer_spr.frame = timer_spr_start_frame
	timer_spr.position = timer_spr_offset
	timer_spr.centered = false
	timer_spr.visible = false
	add_child(tween)
	position_origin = position
	set_process(true)
	

func _process(delta):
	# Timer Sprite Calculation
	if timer.get_time_left() != 0 and timer_spr.visible:
		var percentage = (timer.wait_time - timer.get_time_left()) / timer.wait_time
		var frame_delta = floor(percentage * timer_spr_frame_count)
		if timer_spr.frame != timer_spr_start_frame + frame_delta:
			timer_spr.frame = timer_spr_start_frame + frame_delta

func claim_score():
	game_manager.scores[tile_id] += 1
	set_tile_id(0)
	timer_spr.visible = false

func start_counting_claim_tile(id):
	stop_timer_if_needed(id)
	timer_spr.visible = true
	timer.start()

func stop_timer_if_needed(id):
	if timer.get_time_left() != 0.0 && id != tile_id:
		timer.stop()
		timer_spr.visible = false

func force_stop_timer():
	timer.stop()
	timer_spr.visible = false

func push_down_tween():
	tween.remove_all()
	if position != position_origin:
		position = position_origin
	
	tween.interpolate_property(self, "position", position, position + Vector2(0, push_down_length), 0.2, Tween.TRANS_BACK, Tween.EASE_IN)
	if timer_reconnect_push_down:
		tween.connect("tween_completed", self, "auto_push_up_tween")
		timer_reconnect_push_down = false
	tween.start()

func auto_push_up_tween(obj, key):
	tween.interpolate_property(self, "position", position, position + Vector2(0, -push_down_length), 0.3, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.disconnect("tween_completed", self, "auto_push_up_tween")
	tween.connect("tween_completed", self, "fix_origin_position")
	timer_reconnect_push_down = true
	tween.start()

func fix_origin_position(obj, key):
	position = position_origin
	tween.disconnect("tween_completed", self, "fix_origin_position")

func set_tile_id(id):
	stop_timer_if_needed(id)
	var rect_pos = region_rect.position
	rect_pos.x = board_manager.tileSize.x * id
	if id == 0:
		rect_pos.x = region_origin.position.x
	region_rect.position = rect_pos
	tile_id = id

func get_tile_id():
	return tile_id