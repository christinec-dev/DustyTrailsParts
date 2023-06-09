####DialogPopup.gd

extends Popup

#get/set values
var npc_name : set = npc_name_set
var message: set = message_set
var response: set = response_set

#reference to NPC
var npc

#sets the npc name with the value received from NPC
func npc_name_set(new_value):
	npc_name = new_value
	$Dialog/NPC.text = new_value

#sets the message with the value received from NPC
func message_set(new_value):
	message = new_value
	$Dialog/Message.text = new_value
	
#sets the response with the value received from NPC
func response_set(new_value):
	response = new_value
	$Dialog/Response.text = new_value

#no input on hidden
func _ready():
	set_process_input(false)

#opens the dialog
func open():
	get_tree().paused = true
	popup()
	$"../../AnimationPlayer".play("typewriter")
	$"../..".set_physics_process(false)
	
func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_A:	
			npc.dialog("A")
		elif event.pressed and event.keycode == KEY_B:
			npc.dialog("B")
			
#closes the dialog	
func close():
	set_process_input(false)
	get_tree().paused = false
	hide()
	$"../..".set_physics_process(true)
	
func _on_animation_player_animation_finished(anim_name):
	set_process_input(true)
	
