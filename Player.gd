extends "res://CharacterController.gd"

onready var game_manager = get_node("/root/World")

var control

func _ready():
	re_assign_control()
	set_fixed_process(true)

func re_assign_control():
	if get_parent().get_name() == "Blue":
		control = game_manager.player_1_controls
	elif get_parent().get_name() == "Red":
		control = game_manager.player_2_controls
	elif get_parent().get_name() == "Green":
		control = game_manager.player_3_controls
	elif get_parent().get_name() == "Purple":
		control = game_manager.player_4_controls

func _fixed_process(delta):
	if !is_controllable:
		return
	
	if (Input.is_key_pressed(control["right"]) or Input.is_joy_button_pressed(control["id"], control["right_pad"])) && not Input.is_key_pressed(control["left"]) && not Input.is_key_pressed(control["up"])  && not Input.is_key_pressed(control["down"]) :
		input.x = 1
	elif not Input.is_key_pressed(control["right"])  && (Input.is_key_pressed(control["left"]) or Input.is_joy_button_pressed(control["id"], control["left_pad"]))  && not Input.is_key_pressed(control["up"])  && not Input.is_key_pressed(control["down"]) :
		input.x = -1
	elif not Input.is_key_pressed(control["right"])  && not Input.is_key_pressed(control["left"])  && (Input.is_key_pressed(control["up"])  or Input.is_joy_button_pressed(control["id"], control["up_pad"]))  && not Input.is_key_pressed(control["down"]) :
		input.y = -1
	elif not Input.is_key_pressed(control["right"])  && not Input.is_key_pressed(control["left"])  && not Input.is_key_pressed(control["up"])  && (Input.is_key_pressed(control["down"])  or Input.is_joy_button_pressed(control["id"], control["down_pad"]) ) :
		input.y = 1
	
	try_to_move()