extends Node2D

export(Texture) var sprite
export(Vector2) var tileSize = Vector2(66,35)
export var tileOffset = Vector2(1, 2)
export var width = 10
export var height = 10

export var min_pu_time = 8
export var max_pu_time = 20
export var max_pu_at_board = 8

export(PackedScene) var arrow_pu_scene

onready var aStar = AStar.new()
#register all Power UP here
onready var power_ups = [arrow_pu_scene]
var pu_active_array = []

#Key : x,y
#Value : node
var tile_dict = {
	"Key" : "Color"
}

func _ready():
	setup_board()
	$Timer.connect("timeout", self, "restart_pu_timer")
	$Timer.one_shot = true
	$Timer.wait_time = min_pu_time + (randf() * (max_pu_time - min_pu_time))
	$Timer.start()

func restart_pu_timer():
	var r = randi() % power_ups.size()
	var pu = power_ups[r].instance()
	add_child(pu)
	pu.randomize_position()
	pu_active_array.push_back(pu)
	if pu_active_array.size() < max_pu_at_board:
		$Timer.wait_time = min_pu_time + (randf() * (max_pu_time - min_pu_time))
		$Timer.start()

func restart_timer_spawn_pu():
	$Timer.wait_time = min_pu_time + (randf() * (max_pu_time - min_pu_time))
	$Timer.start()

func is_pu_at(vec):
	for i in pu_active_array:
		if i.current_pos_tile == vec:
			return true
	
	return false

func translate_tile_to_position(tile_vec):
	return tile_dict[tile_vec].position

func setup_board():
	tile_dict.clear()
	var aStarPoints = []
	var start_pos = Vector2(round((get_node("/root").size.x / 2) - ((width + height) * .5) * tileSize.x * .5) ,round(get_node("/root").size.y / 2))
	for x in range(width):
		for y in range(height):
			var idx = 0
			if (x+y) % 2 == 1:
				idx = 1
			var next_pos = start_pos + (Vector2(round((tileSize.x - tileOffset.x) / 2), round((tileSize.y - tileOffset.y) /2)) * y)
			tile_dict[Vector2(x,y)] = create_tile(next_pos, idx)
			#set z
			tile_dict[Vector2(x,y)].z = y - x - height
			tile_dict[Vector2(x,y)].tile_pos = Vector2(x,y)
#			var pos = tile_dict[Vector2(x,y)].position
#			var vec3 = Vector3(pos.x, pos.y, 0)
			aStar.add_point((x* height) +y, Vector3(x, y, 0))
			aStarPoints.push_back((x* height) +y)
		
		start_pos.x += round((tileSize.x - tileOffset.x) / 2)
		start_pos.y -= round((tileSize.y - tileOffset.y) / 2)
	
	for p in aStarPoints.size():
		if p % (height - 1) != 0 or p == 0:
			aStar.connect_points(p, p+1)
		if p + height < width * height:
			aStar.connect_points(p, p + height)

func reset_board():
	reset_board_id()
	for i in pu_active_array:
		i.queue_free()
	
	pu_active_array.clear()

func reset_board_id():
	for i in tile_dict.values():
		i.set_tile_id(0)
		i.push_down_tween()

func disconnect_point(id):
	if id - 1 >= 0:
		aStar.disconnect_points(id, id-1)
	if int(id + 1) % height != 0:
		aStar.disconnect_points(id, id+1)
	if id + height < width * height:
		aStar.disconnect_points(id, id+height)
	if id - height >= 0:
		aStar.disconnect_points(id, id-height)

func reconnect_point(id):
	if id - 1 >= 0:
		aStar.connect_points(id, id-1)
	if int(id + 1) % height != 0:
		aStar.connect_points(id, id+1)
	if id + height < width * height:
		aStar.connect_points(id, id+height)
	if id - height >= 0:
		aStar.connect_points(id, id-height)

func reset_weight_point_and_reconnect(id, pos, weight = 1):
	aStar.remove_point(id)
	aStar.add_point(id, Vector3(pos.x, pos.y, 0), weight)
	if id - 1 >= 0:
		aStar.connect_points(id, id-1)
	if int(id + 1) % height != 0:
		aStar.connect_points(id, id+1)
	if id + height < width * height:
		aStar.connect_points(id, id+height)
	if id - height >= 0:
		aStar.connect_points(id, id-height)

func create_tile(pos, idx):
	var spr = Sprite.new()
	spr.texture = sprite
	spr.centered = false
	spr.region_enabled = true
	spr.region_rect = Rect2(tileSize.x * idx, 0, tileSize.x, tileSize.y)
#	spr.hframes = 10
#	spr.vframes = 10
#	spr.frame = idx
	spr.position = pos
	spr.set_script(preload("res://TileHelper.gd"))
	spr.region_origin = spr.region_rect
	
	self.add_child(spr)
	return spr

func change_tile_id_at(vec, id):
	tile_dict[vec].set_tile_id(id)

func start_counting_claim_tile(vec, id):
	tile_dict[vec].start_counting_claim_tile(id )

func get_current_tile():
	var result = { 
	"NA" : 0,
	"Blue" : 0,
	"Red" : 0,
	"Green" : 0,
	"Purple" : 0
	}
	
	for i in tile_dict.values():
		if i.tile_id == 0:
			result["NA"] += 1
		elif i.tile_id == 2:
			result["Blue"] += 1
		elif i.tile_id == 3:
			result["Red"] += 1
		elif i.tile_id == 4:
			result["Green"] += 1
		elif i.tile_id == 5:
			result["Purple"] += 1
	
	
	return result
