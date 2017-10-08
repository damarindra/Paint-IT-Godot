extends Control

onready var game_manager = get_node("..")

#0 nothing happen, 1 player 1, 2 player 2, 3 player 3, 4 player 4
var control_status = 0
var setup_counter = 0
var current_control_setup = []

func _ready():
	set_process_input(true)

func _input(event):
	if control_status == 0:
		return
	if event.is_class("InputEventKey"):
		if !current_control_setup.has(event.scancode):
			current_control_setup.push_back(event.scancode)
			if current_control_setup.size() == 0:
				get_node("Controls/Panel/Label").text = "Player " + str(control_status) + " - Press LEFT Key"
			elif current_control_setup.size() == 1:
				get_node("Controls/Panel/Label").text = "Player " + str(control_status) + " - Press RIGHT Key"
			elif current_control_setup.size() == 2:
				get_node("Controls/Panel/Label").text = "Player " + str(control_status) + " - Press UP Key"
			elif current_control_setup.size() == 3:
				get_node("Controls/Panel/Label").text = "Player " + str(control_status) + " - Press DOWN Key"
		
		if current_control_setup.size() == 4:
			#done
			if control_status == 1:
				game_manager.player_1_controls["left"] = current_control_setup[0]
				game_manager.player_1_controls["right"] = current_control_setup[1]
				game_manager.player_1_controls["up"] = current_control_setup[2]
				game_manager.player_1_controls["down"] = current_control_setup[3]
			elif control_status == 2:
				game_manager.player_2_controls["left"] = current_control_setup[0]
				game_manager.player_2_controls["right"] = current_control_setup[1]
				game_manager.player_2_controls["up"] = current_control_setup[2]
				game_manager.player_2_controls["down"] = current_control_setup[3]
			elif control_status == 3:
				game_manager.player_3_controls["left"] = current_control_setup[0]
				game_manager.player_3_controls["right"] = current_control_setup[1]
				game_manager.player_3_controls["up"] = current_control_setup[2]
				game_manager.player_3_controls["down"] = current_control_setup[3]
			elif control_status == 4:
				game_manager.player_4_controls["left"] = current_control_setup[0]
				game_manager.player_4_controls["right"] = current_control_setup[1]
				game_manager.player_4_controls["up"] = current_control_setup[2]
				game_manager.player_4_controls["down"] = current_control_setup[3]
			$"../CharacterManager".re_assign_player_input(control_status)
			current_control_setup.clear()
			control_status = 0
			
			get_node("Controls/Panel").hide()
			get_node("Controls/Controls").show()

func start_game():
	game_manager.restart_game()
	get_node("../GameUI").show()
	#show and hide character ui
	for i in 4:
		if i < game_manager.player_counts + game_manager.bot_counts:
			$"../GameUI".get_child(i).show()
		else:
			$"../GameUI".get_child(i).hide()
		

func _on_SinglePlayer_button_up():
	game_manager.player_counts = 1
	$"PlayMode".hide()
	$"Select Bot".show()
	$"Select Bot/No Bot".hide()

func _on_2_Player_button_up():
	game_manager.player_counts = 2
	$"PlayMode".hide()
	$"Select Bot/3 Bots".hide()
	$"Select Bot".show()
	$"Select Bot/No Bot".show()


func _on_3_Player_button_up():
	game_manager.player_counts = 3
	$"PlayMode".hide()
	$"Select Bot/2 Bots".hide()
	$"Select Bot/3 Bots".hide()
	$"Select Bot".show()
	$"Select Bot/No Bot".show()


func _on_4_Player_button_up():
	game_manager.player_counts = 4
	game_manager.bot_counts = 0
	$"PlayMode".hide()
	$Time.show()


func _on_Controls_button_up():
	$Controls.show()
	$PlayMode.hide()


func _on_1_Bot_button_up():
	game_manager.bot_counts = 1
	$"Select Bot".hide()
	$Time.show()


func _on_2_Bots_button_up():
	game_manager.bot_counts = 2
	$"Select Bot".hide()
	$Time.show()


func _on_3_Bots_button_up():
	game_manager.bot_counts = 3
	$"Select Bot".hide()
	$Time.show()


func _on_No_Bot_button_up():
	game_manager.bot_counts = 0
	$Time.show()


func _on_1_button_up():
	game_manager.max_game_time = 60
	$Time.hide()
	start_game()


func _on_2_button_up():
	game_manager.max_game_time = 120
	$Time.hide()
	start_game()


func _on_4_button_up():
	game_manager.max_game_time = 240
	$Time.hide()
	start_game()


func _on_Player_1_button_up():
	control_status = 1
	get_node("Controls/Panel").show()
	get_node("Controls/Panel/Label").text = "Player " + str(control_status) + " - Press LEFT Key"
	get_node("Controls/Controls").hide()
	

func _on_Player_2_button_up():
	control_status = 2
	get_node("Controls/Panel").show()
	get_node("Controls/Panel/Label").text = "Player " + str(control_status) + " - Press LEFT Key"
	get_node("Controls/Controls").hide()


func _on_Player_3_button_up():
	control_status = 3
	get_node("Controls/Panel").show()
	get_node("Controls/Panel/Label").text = "Player " + str(control_status) + " - Press LEFT Key"
	get_node("Controls/Controls").hide()


func _on_Player_4_button_up():
	control_status = 4
	get_node("Controls/Panel").show()
	get_node("Controls/Panel/Label").text = "Player " + str(control_status) + " - Press LEFT Key"
	get_node("Controls/Controls").hide()


func _on_Back_button_up():
	$PlayMode.show()
	$Controls.hide()



func _on_GoToMainMenu_button_up():
	game_manager.player_counts = 0
	game_manager.bot_counts = 1
	game_manager.restart_without_timer()
	$"../GameUI".hide()
	$"../GameOverUI".hide()
	$PlayMode.show()


func _on_BackFromTime_button_up():
	$Time.hide()
	if game_manager.player_counts == 4:
		$PlayMode.show()
	else:
		$"Select Bot".show()


func _on_BackFromBot_button_up():
	$"Select Bot".hide()
	$PlayMode.show()
